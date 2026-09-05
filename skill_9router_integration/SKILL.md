---
name: 9router-integration
description: "Kết nối 9Router (LLM Gateway đa nền tảng - chuẩn OpenAI). Actions: setup, configure, implement, review, fix, optimize. Keywords: 9router, LLM gateway, combo model, model fallback, OpenAI format, streaming SSE, 9router API"
argument-hint: "[action] [component]"
metadata:
  author: duyvo26
  version: "1.0.0"
---

# Skill: Kết nối 9Router (LLM Gateway đa nền tảng)

## Mục tiêu

Tích hợp 9Router để dùng nhiều model AI (GPT, Claude, Gemini, Llama, các model nội bộ...) qua 1 cổng API chuẩn OpenAI. 9Router tự dịch payload sang đúng định dạng của backend model và tự fallback khi hết quota.

---

## 1. 9Router là gì?

[9Router](https://github.com/decolua/9router) là **LLM Gateway tự host**:
- Viết code theo chuẩn OpenAI (`/v1/chat/completions`) — 9Router tự translate cho bất kỳ backend model nào.
- **Model `combo`**: Smart 3-Tier Fallback — nếu model chính hết quota, tự rơi xuống model phụ rẻ, rồi tới free-tier, không đứt session.
- **RTK Token Saver**: nén context dài (git diff, log, directory) giảm 20-40% input token.
- Dùng cho coding assistant, chat UI, hoặc custom script/app.

---

## 2. Cấu hình

### Cách 1: Qua file .env
```env
LLM_BASE_URL=http://172.16.10.21:20128/v1
LLM_API_KEY=sk-9router-key-here
LLM_MODEL=combo
```

### Cách 2: Qua Settings UI / DB (khuyên dùng)
Lưu `base_url`, `api_key`, `model` vào DB (bảng `llm_settings`) để user tự toggle — giống cấu hình OpenRouter.

---

## 3. ⚠️ ĐIỂM MẤU CHỐT — Model combo PHẢI dùng streaming

Đây là bug thực tế đã gặp và fix trong dự án. **AI phải TUÂN THỦ:**

1. **Model `combo` CHỈ trả nội dung khi `stream: true`**.
   - Không gửi `stream` → 9router trả **SSE** (`data: {...}`) mà code dùng `resp.json()` sẽ đọc fail → lỗi parse.
   - Gửi `stream: false` → combo trả JSON hợp lệ nhưng **`content: ""` RỖNG** → vô dụng.
2. **Luôn dùng `client.stream()` + gom SSE chunks**:
   ```python
   async with client.stream(
       "POST", f"{base}/chat/completions",
       headers={"Authorization": f"Bearer {key}"},
       json={"model": model, "messages": messages, "stream": True, "max_completion_tokens": 4000},
   ) as resp:
       content_parts = []
       async for line in resp.aiter_lines():
           if not line.startswith("data:"):
               continue
           payload = line[5:].strip()
           if payload == "[DONE]":
               break
           chunk = json.loads(payload)
           delta = chunk["choices"][0].get("delta", {})
           text = delta.get("content") or ""
           if text:
               content_parts.append(text)
       content = "".join(content_parts).strip()
   ```
3. **`max_completion_tokens` ≥ 2000** — model reasoning dùng token, nếu quá nhỏ sẽ `finish_reason="length"` hoặc content rỗng.
4. **Robust JSON extract** sau khi gom content (LLM hay trả thêm text/markdown):
   ```python
   import re
   json_str = content
   m = re.search(r"```(?:json)?\s*(\{.*?\})\s*```", content, re.S)
   if m:
       json_str = m.group(1)
   elif not content.strip().startswith("{"):
       m2 = re.search(r"\{.*\}", content, re.S)
       if m2:
           json_str = m2.group(0)
   result = json.loads(json_str)
   ```

---

## 4. Model trong 9Router

| Model | Ghi chú |
|-------|---------|
| `combo` | **Khuyên dùng** — tự fallback 3 tầng, luôn stream |
| `nvidia/nemotron-3-ultra-550b-a55b` | Model cụ thể (có thể 404 nếu backend down) |
| `nvidia/parakeet-ctc-1.1b-asr` | ASR (audio) |

> Model cụ thể có thể trả `[404] page not found` — khi đó combo là phương án an toàn nhất.

---

## 5. Luồng dữ liệu

```
Settings UI / .env -> llm_service.chat_with_llm()
  -> POST {base}/chat/completions (stream:true)
  -> gom SSE data: chunks
  -> robust JSON extract
  -> {"action": "...", "params": {...}, "response": "..."}
```

---

## Quy tắc bắt buộc

1. **Luôn `stream: true`** khi gọi model `combo` — không stream = content rỗng hoặc parse lỗi.
2. Cấu hình LLM lưu trong DB (`llm_settings`) để user tự toggle, không hardcode key trong code.
3. Luôn có **OpenAI backup** (`OPENAI_API_KEY`) — combo là quick tunnel/free, không có uptime guarantee.
4. Trước khi dùng, kiểm tra reachable: `GET {base}/models` với `Authorization: Bearer {key}` (401 = key sai, 000 = không connect được).
5. Không tự ý thêm package — chỉ dùng `httpx` (async) đã có.

---

## File liên quan

- [Kết nối OpenRouter (Đa nền tảng AI)](skill: openrouter-integration)
- [Kiến trúc Chatbot & LLM](skill: chatbot-architecture)
- [Cấu hình Môi trường (.env)](skill: env-configuration)
- [Cấu trúc Dự án Tiêu chuẩn (Skill DuyVo26)](skill: project-structure)