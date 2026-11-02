# DuyVo26 — AI Agent Skills Hub & Production Engineering Knowledge Base

Bộ sưu tập và hệ sinh thái kỹ năng tiêu chuẩn (**500+ AI Skills**) dành cho AI Coding Agents (Google Antigravity, Claude Code, OpenAI Codex, Cursor).

---

## ⚡ Cài đặt 1 chạm cho máy mới (1-Touch Quickstart)

Để cài đặt và kích hoạt toàn bộ 500+ kỹ năng trên bất kỳ máy macOS hoặc Linux mới nào, chỉ cần chạy một dòng lệnh duy nhất trong Terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/duyvo26/DOCS/main/install_all_skills.sh | bash
```

Hoặc chỉ cài bộ cốt lõi DuyVo26 (31 skills):

```bash
curl -fsSL https://raw.githubusercontent.com/duyvo26/DOCS/main/install_all_skills.sh | bash -s -- --core-only
```

---

## 🏛️ Kiến Trúc Hệ Sinh Thái Kỹ Năng

Hệ thống được chia thành các khối chuyên biệt, đảm bảo agent luôn tuân thủ tiêu chuẩn kỹ thuật cao nhất:

| Khối Chức Năng | Số Lượng | Mô Tả & Nhiệm Vụ |
|---|---|---|
| **1. Cốt lõi DuyVo26 Suite** | **31 Skills** | Bộ chuẩn hoá quy trình phát triển: RAG, Chatbot, 9Router, Bảo mật, Kiosk, Nginx WAF, aaPanel, Coding Conventions, Git, v.v. |
| **2. Vận hành Máy chủ aaPanel / Baota** | **8 Skills** | Tự động hoá triển khai Python, Node.js, Go, Java, Web tĩnh, Reverse Proxy, Fix 502 error, di chuyển Supervisor. |
| **3. Thiết kế & Anti-Slop Frontend** | **2 Skills** | `impeccable` (v4.8.0) và `taste-skill` (v2): Ngăn chặn giao diện AI rập khuôn, art direction chuyên nghiệp chuẩn Awwwards. |
| **4. Thuyết trình PPT Master** | **1 Skill** | Tự động tạo bài thuyết trình, slide PowerPoint và visual deck bằng AI. |
| **5. Đồ thị Codebase Graphify** | **1 Skill** | Xây dựng Knowledge Graph phân tích quan hệ file, god nodes, phát hiện cộng đồng kiến trúc codebase. |
| **6. Thư viện Kỹ năng Mở Rộng** | **460+ Skills** | Kho tri thức toàn diện: Web3, Cloud AWS/GCP, Docker/K8s, Quantitative Trading, Robotics, Game Dev, System Architecture... |

> 📖 **Xem danh mục tra cứu chi tiết toàn bộ 500+ kỹ năng:**  
> 👉 [FULL_SKILLS_MANIFEST.md](FULL_SKILLS_MANIFEST.md)

---

## 🛠️ Danh mục 31 Kỹ Năng Cốt Lõi (DuyVo26 Core)

1. **`skill: ai-rag-workflow`**: Quy trình RAG chuẩn (LangGraph, grading document, token context management).
2. **`skill: chatbot-architecture`**: Kiến trúc module Chatbot, prompt management, agent lifecycle.
3. **`skill: openrouter-integration`**: Kết nối đa nền tảng mô hình AI qua OpenRouter.
4. **`skill: 9router-integration`**: LLM Gateway chuẩn OpenAI, combo model, streaming SSE, 3-tier fallback.
5. **`skill: zalo-bot`**: Cấu hình và vận hành Zalo Bot webhook, RBAC, chat history.
6. **`skill: docx-to-md-parser`**: Trích xuất và chuyển đổi tài liệu DOCX sang Markdown có cấu trúc.
7. **`skill: env-configuration`**: Quản lý biến môi trường an toàn (.env, Pydantic Settings, .gitignore).
8. **`skill: sql-compatibility`**: Truy vấn SQL đa nền tảng (SQLite & MySQL), chống SQL Injection.
9. **`skill: dependencies-management`**: Quản lý dependencies tối ưu (FastAPI, LangGraph, JWT, zustand, zod).
10. **`skill: security-authentication`**: Bảo mật & xác thực JWT, bcrypt, RBAC, phân quyền vai trò.
11. **`skill: server-security-hardening`**: Củng cố bảo mật VPS Production (UFW, Fail2ban, chống lộ .env/.db).
12. **`skill: google-oauth-redirect`**: Đăng nhập Google OAuth qua backend redirect flow.
13. **`skill: hybrid-app-login`**: Đăng nhập ứng dụng di động Flutter/React Native qua WebView polling.
14. **`skill: async-task-polling`**: Xử lý tác vụ nền bất đồng bộ và cơ chế polling kết quả.
15. **`skill: payment-polling-sync`**: Tích hợp thanh toán tự động SePay, đồng bộ giao dịch ngân hàng.
16. **`skill: frontend-architecture`**: Khung kiến trúc React/Vite/TypeScript, Axios JWT Interceptor.
17. **`skill: frontend-routing-components`**: Phân tách component và định tuyến React Router v6.
18. **`skill: dynamic-seo-manager`**: Quản lý thẻ meta SEO động, social share preview.
19. **`skill: coding-conventions`**: Quy chuẩn viết mã sạch, type hinting, docstring, nghiêm cấm emoji.
20. **`skill: git-workflow`**: Quy trình Git tiêu chuẩn, conventional commits.
21. **`skill: execution-rules`**: 11 quy tắc thực thi bắt buộc (Router no logic, Service pattern, OOP).
22. **`skill: readme-writing`**: Hướng dẫn soạn thảo README.md 7 phần chuẩn quốc tế.
23. **`skill: logging-monitoring`**: Ghi log có cấu trúc qua RotatingFileHandler, cấm dùng `print()`.
24. **`skill: api-response-standard`**: Chuẩn hoá định dạng phản hồi API (`ApiSuccess`, `ApiError`).
25. **`skill: codebase-mapper`**: Phân tích sơ đồ codebase và tự động cập nhật map.md.
26. **`skill: server-security-hardening`**: Kiểm tra rà quét lỗ hổng và củng cố máy chủ.
27. **`skill: nginx-waf-reverse-proxy`**: Tường lửa Nginx WAF, bản đồ SOC thế giới, Stream Proxy, Proxmox LXC.
28. **`skill: aapanel-management`**: Quản trị aaPanel, triển khai dự án Python/Node/Go/Java, fix 502, fix bug core.
29. **`skill: kiosk-system`**: Hệ thống Kiosk Linux màn hình cảm ứng (Wayland, Chromium, Watchdog, Plymouth).
30. **`skill: wifi-management`**: Quản lý mạng Wi-Fi thiết bị nhúng qua NetworkManager (`nmcli`).
31. **`skill: project-structure`**: Cấu trúc dự án tổng thể. Luôn tải đầu tiên khi bắt đầu dự án mới.

---

## 📌 Cách Kích Hoạt Kỹ Năng

Trong giao diện hội thoại với AI Agent, bạn có thể gọi trực tiếp kỹ năng bằng cách gõ:

```text
skill: <tên_kỹ_năng>
```

Ví dụ:
- `skill: aapanel-management` — Yêu cầu triển khai hoặc sửa lỗi aaPanel.
- `skill: taste-skill` — Yêu cầu thiết kế giao diện web đẹp, chống nhàm chán.
- `skill: server-security-hardening` — Yêu cầu rà soát bảo mật máy chủ.
