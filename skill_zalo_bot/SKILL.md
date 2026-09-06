---
name: zalo-bot
description: "Cấu hình & vận hành Zalo Bot (webhook, lấy Zalo ID, phân quyền, lưu lịch sử chat). Actions: setup, configure, implement, review, fix, optimize. Keywords: Zalo bot, webhook, Zalo ID, myid, groupid, chat history, RBAC, n8n proxy"
argument-hint: "[action] [component]"
metadata:
  author: duyvo26
  version: "1.0.0"
---

# Skill: Zalo Bot (Cấu hình & Vận hành)

## Mục tiêu

Hướng dẫn cấu hình và vận hành Zalo Bot: đăng ký webhook, lấy Zalo ID người dùng/nhóm, phân quyền truy cập, lưu lịch sử chat, và luồng xử lý tin nhắn. Áp dụng cho bot trong repo `chatbot_zalo` (FastAPI + SQLite + n8n proxy).

---

## 1. Kiến trúc tổng quan

```
Zalo Cloud ──POST──▶ n8n Webhook (public URL)
                        │ Forward + X-Bot-Api-Secret-Token
                        ▼
              POST http://<LAN-IP>:8000/webhooks
                        │ Bot xử lý (quyền → lệnh/LLM/in ấn)
                        ▼
              Zalo Bot API (gửi tin nhắn trả lời)
```

- **n8n chỉ là proxy thuần túy** (`deploy/n8n_workflow.json`): nhận webhook công khai, forward nguyên body tới bot nội bộ kèm header `X-Bot-Api-Secret-Token` và `Content-Type: application/json`.
- **Mọi logic nằm ở bot**: endpoint `POST /webhooks` (`app/routers/webhook.py`).

## 2. Cấu hình (.env)

| Biến | Ví dụ | Dùng ở đâu |
|------|-------|-----------|
| `BOT_TOKEN` | `43063...` | `app/services/zalo_api.py` → `BASE_URL = {ZALO_API_BASE}{BOT_TOKEN}` |
| `WEBHOOK_SECRET` | `0xLcVW...` | `app/routers/webhook.py` — đối chiếu header `X-Bot-Api-Secret-Token` |
| `ZALO_API_BASE` | `https://bot-api.zapps.me/bot` | Base URL Zalo Bot API |
| `N8N_WEBHOOK_URL` | `https://n8n.../webhook/zalo/...` | Chỉ để tài liệu; forward thật cấu hình trong n8n |
| `PRINT_API_URL` / `PRINT_API_KEY` | `http://duyvo26.com:5326` | `app/services/print_service.py` |
| `LLM_BASE_URL` / `LLM_API_KEY` / `LLM_MODEL` | `http://172.16.10.21:20128/v1` / `combo` | `app/services/llm_service.py` (ưu tiên DB `llm_settings`) |
| `OPENAI_API_KEY` | `sk-proj-...` | Fallback provider `gpt-5-nano` |
| `UPLOAD_BASE_URL` | tunnel URL / rỗng | `app/config.py`; startup nạp đè từ DB |

**Đăng ký webhook KHÔNG nằm trong code** — thực hiện ngoài: Zalo Developer Portal → URL n8n công khai. Chỉ có endpoint kiểm tra: `GET /api/webhook-info` (`getWebhookInfo`), `POST /api/test-webhook` (`testWebhook`) trong `app/routers/zalobot.py`.

**Chạy bot:**
```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

---

## 3. Lấy Zalo ID (`/myid`, `/groupid`)

| Lệnh | Kết quả | Ghi chú |
|------|---------|---------|
| `/myid` | `**Zalo ID của bạn:** \`{from.id}\`` + tên hiển thị | Chạy được cả PRIVATE lẫn GROUP |
| `/groupid` | `Group ID: \`{chat_id}\`` | Chỉ trong GROUP; ngoài nhóm trả "Lệnh này chỉ hoạt động trong nhóm." |

Code: `app/services/command_service.py` (normalize + handler), liệt kê trong `/help`.

**Utility bypass:** `app/routers/webhook.py` bỏ qua kiểm tra quyền và group allow-list cho `("/myid", "/groupid")` — user **chưa được duyệt vẫn lấy được ID** để gửi cho admin.

**Quy trình cấp quyền:**
1. User/nhóm mới nhắn → bot tự ghi vào `pending_users` / `pending_groups` + trả lời "chưa được cấp quyền".
2. Admin mở panel `/admin` → tab Chờ cấp quyền → lấy ID.
3. Admin gọi `POST /api/users {user_id, name, role, enabled}` (hoặc `/api/groups`), rồi `DELETE /api/pending-*`.
4. Code: `app/routers/pending.py`, `users.py`, `groups.py`; bảng `pending_users` / `pending_groups` trong `app/database.py`.

## 4. Lưu lịch sử chat

- **Bảng** `chat_history(id, user_id, direction, message_text, created_at)`, DB `bot.db`, `init_db()` lúc khởi động.
- **Chỉ lưu chat PRIVATE** (`app/routers/webhook.py`): tin user và tin bot trả lời. **Nhóm không lưu.**
- **Giới hạn 20 tin/user** (`MAX_HISTORY=20`): `save_chat_message()` chèn xong xóa bản cũ nhất vượt ngưỡng.
- **Hàm dùng:** `save_chat_message()`, `get_chat_history(user_id, limit=20)` (mới nhất trước, đảo ngược khi trả), `get_all_chat_users()`, `clear_chat_history()`.
- **Mục đích:** 20 tin gần nhất được nhét vào system prompt LLM làm context (`app/services/llm_service.py`), kèm user profile.
- **Xem/xóa qua web:** `GET /chat-history` (trang), `GET /api/chat-history[?user_id]`, `DELETE /api/chat-history/{user_id}` (`app/routers/pages.py`).

## 5. Phân quyền (RBAC)

- **Bảng:** `users(user_id, name, role, enabled)`, `groups(chat_id, name, enabled, allowed_commands JSON, mặc định `["*"]`)`, `commands(name, enabled, min_role, groups_only)`.
- **Role:** `user(0) < manager(1) < admin(2)` (`app/services/permission.py`). Lệnh mặc định: `/help /myid /groupid /xinchao /print` = user; `/status` = admin; `/intailieu` = manager + chỉ trong nhóm.
- **Admin tối cao:** `admin_zalo_id` trong bảng `settings` — `get_user_role()` trả `admin` luôn, không cần dòng trong `users`.
- **Cấp quyền:** Admin UI `POST /api/users`, `PUT /api/users/{id}`, `POST .../toggle`, `DELETE`; tương tự `/api/groups`; super-admin qua `POST /api/admin-id`.
- **Kiểm tra mỗi tin nhắn** (`has_permission`): không role/disabled → chặn; chat thường (không phải lệnh) → cho qua; lệnh tắt → chặn; role thấp hơn `min_role` → chặn; lệnh `groups_only` ngoài GROUP → chặn.
- **Group allow-list:** nhóm chưa duyệt → vào pending + chặn; lệnh không nằm trong `allowed_commands` của nhóm → chặn (`"*" `= tất cả).

## 6. Luồng xử lý webhook (`POST /webhooks`)

`app/routers/webhook.py` — thứ tự xử lý mỗi tin nhắn text (`message.text.received`, loại khác bỏ qua):

1. **Secret check:** header `X-Bot-Api-Secret-Token` so với setting `webhook_secret` (fallback `os.getenv`). Sai → `{"ok": False, "error": "Unauthorized"}`.
2. **Parse:** `event_name`, `chat.{id, chat_type}`, `text`, `from.{id, display_name}`.
3. **Lưu tin user** (chỉ PRIVATE) + bật vòng lặp `sendChatAction(typing)` mỗi 4s (tối đa 30s) để user biết bot đang xử lý.
4. **Chặn nhóm chưa duyệt** → pending + chặn. **Chặn user lạ** → pending + chào + chặn.
5. **Upsert user profile** (cá nhân hóa) + **strip `@Bot...`** đầu tin nhắn + map biến thể tiếng Việt (`normalize_command`).
6. **Bỏ qua quyền cho `/myid`, `/groupid`**; còn lại check `has_permission` + lệnh cho phép trong nhóm.
7. **Route lệnh** (`route_command`): `/help /status /myid /groupid /xinchao /intailieu /print[/print ID số_lượng]`.
8. **Nhận diện ý định upload** (regex "tải file/upload/gửi file...") → tạo token `secrets.token_urlsafe(24)`, chờ tunnel URL ≤10s, trả link `/u/<token>` hiệu lực 15 phút.
9. **Không phải lệnh** → chọn số sau xác nhận, hoặc LLM fallback (`llm_flow.handle_natural_language`); `action=upload` từ LLM → tạo link upload thật.
10. **Tắt typing**, **lưu tin bot** (chỉ PRIVATE), **gửi sticker** theo từ khóa (`da in xong`→done, `lỗi`→error, `chưa được cấp quyền`→cancel, `xin chào`→welcome), **gửi tin nhắn markdown** qua `sendMessage`.

---

## Quy tắc bắt buộc

1. **Lịch sử chỉ PRIVATE** — không bao giờ lưu tin nhắn nhóm vào `chat_history`.
2. **Secret sai → từ chối ngay** — không xử lý tiếp, không rò rỉ lý do chi tiết.
3. **`/myid`, `/groupid` luôn mở** — không chặn user chưa duyệt (họ cần ID để xin quyền).
4. **Không hardcode key/token** trong code — mọi secret qua `.env` hoặc DB `settings`/`llm_settings`.
5. **Tin nhắn user lạ/nhóm lạ → pending + chặn**, không xử lý lệnh.
6. **Giữ `MAX_HISTORY=20`** khi lưu lịch sử để context LLM không phình.
7. Upload link **hết hạn 15 phút**; tunnel URL đọc động (không cache localhost).

---

## Troubleshooting

| Triệu chứng | Nguyên nhân thường gặp | Xử lý |
|---|---|---|
| `{"ok": False, "error": "Unauthorized"}` | Secret header ≠ `WEBHOOK_SECRET`/setting | Đồng bộ secret n8n ↔ bot |
| Bot im lặng trong nhóm mới | Nhóm chưa duyệt (pending) | Admin duyệt trong tab Chờ cấp quyền |
| Upload link `localhost` | Tunnel chưa kịp bắt URL | Đợi tunnel chạy; check `GET /api/tunnel-status` |
| LLM trả rỗng | Model `combo` cần `stream: true` | Xem `skill: 9router-integration` |
| Lịch sử trống | Đang chat trong nhóm (chỉ PRIVATE mới lưu) | Chat riêng với bot |

---

## File liên quan

- [Kiến trúc Chatbot & LLM](skill: chatbot-architecture)
- [Cấu hình Môi trường (.env)](skill: env-configuration)
- [Kết nối 9Router](skill: 9router-integration)
- [Cấu trúc Dự án Tiêu chuẩn (Skill DuyVo26)](skill: project-structure)
