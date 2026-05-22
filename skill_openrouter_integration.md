# Hướng dẫn kết nối OpenRouter

## OpenRouter là gì?

[OpenRouter](https://openrouter.ai) là cổng API cho phép truy cập nhiều mô hình AI khác nhau (GPT, Claude, Gemini, Llama, Mistral...) chỉ với **1 API key duy nhất**, không cần đăng ký từng nhà cung cấp.

---

## Cách lấy OpenRouter API Key

1. Truy cập [https://openrouter.ai/keys](https://openrouter.ai/keys)
2. Đăng nhập / Đăng ký tài khoản
3. Click **"Create Key"**
4. Copy key (bắt đầu bằng `sk-or-...`)

> 💡 Một số model miễn phí (free) không cần thẻ tín dụng, chỉ cần tài khoản.

---

## Cấu hình trong ứng dụng

### Cách 1: Qua giao diện Settings (Khuyên dùng)

1. Vào menu **Settings** → **Cấu hình AI**
2. Bật toggle **OpenRouter** (góc phải header)
3. Nhập **OpenRouter API Key** (sk-or-...)
4. Chọn **Model** mong muốn
5. Click **Test API** để kiểm tra kết nối

### Cách 2: Qua file `.env`

Mở file `.env` ở thư mục gốc và thêm:

```env
OPENROUTER_API_KEY=sk-or-...
OPENROUTER_MODEL=openai/gpt-oss-120b:free
```

### Cách 3: Test nhanh bằng API

```bash
curl -X POST http://localhost:42683/api/settings/test-llm \
  -H "Authorization: Bearer <your_token>" \
  -d "use_openrouter=true&api_key=sk-or-...&model=openai/gpt-oss-120b:free"
```

---

## Danh sách model phổ biến

| Model | Mô tả | Phí |
|-------|-------|-----|
| `openai/gpt-oss-120b:free` | OpenAI OSS 120B | Free |
| `openrouter/free` | Tự động chọn model free tốt nhất | Free |
| `openai/gpt-4o-mini` | GPT-4o Mini (nhanh, rẻ) | Trả phí |
| `openai/gpt-4o` | GPT-4o (thông minh nhất) | Trả phí |
| `anthropic/claude-3.5-sonnet` | Claude 3.5 Sonnet | Trả phí |
| `google/gemini-2.0-flash-exp:free` | Gemini 2.0 Flash | Free |
| `meta-llama/llama-3.3-70b-instruct:free` | Llama 3.3 70B | Free |
| `mistralai/mistral-7b-instruct:free` | Mistral 7B | Free |

> Xem danh sách đầy đủ: [https://openrouter.ai/models](https://openrouter.ai/models)

---

## Cách hoạt động trong code

### `chatbot/utils/llm.py` — LlmFactory

Khi `use_openrouter=True`, `LlmFactory.get_llm()` tạo `ChatOpenAI` với:

```python
ChatOpenAI(
    model=openrouter_model,
    api_key=openrouter_api_key,
    base_url="https://openrouter.ai/api/v1",
    default_headers={
        "HTTP-Referer": "https://github.com/python_create_video",
        "X-OpenRouter-Title": "Auto Video Creator",
    },
)
```

### Luồng dữ liệu

```
Settings UI (toggle + key + model)
  → POST /api/settings (lưu DB: use_openrouter, openrouter_api_key, openrouter_model)
  → Service layer (JobService, AutopostService, ScriptService...)
    → LlmFactory.get_llm(use_openrouter=True, ...)
      → ChatOpenAI(base_url="https://openrouter.ai/api/v1")
        → OpenRouter API → response
```

### Các file liên quan

| File | Vai trò |
|------|---------|
| `chatbot/utils/llm.py` | Factory tạo LLM instance (quyết định OpenAI hay OpenRouter) |
| `app/routers/settings_router.py` | API lưu/lấy cấu hình OpenRouter |
| `chatbot/services/script_service.py` | Sinh script qua LLM |
| `app/services/autopost_service.py` | Pipeline auto-post dùng LLM |
| `app/services/job_service.py` | Job service dùng LLM |
| `frontend/components/Settings.tsx` | Giao diện toggle + key + model |
| `frontend/services/api.ts` | API calls từ frontend |

---

## Xử lý lỗi thường gặp

| Lỗi | Nguyên nhân | Cách fix |
|-----|-------------|----------|
| `HTTP 400: API Key không hợp lệ` | Key sai hoặc hết hạn | Tạo key mới trên OpenRouter |
| `HTTP 400: Rate limit bị vượt quá` | Model free bị giới hạn tần suất | Chờ 1-2 phút hoặc dùng model trả phí |
| `HTTP 400: Model không tìm thấy` | Sai tên model | Kiểm tra lại tên model trên OpenRouter |
| `HTTP 400: Connection failed: timeout` | Mạng chậm hoặc OpenRouter down | Kiểm tra internet, thử lại sau |
| `HTTP 404: Not Found` | Endpoint chưa tồn tại | Restart backend server |
