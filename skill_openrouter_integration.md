# Skill: Kết nối OpenRouter (Đa nền tảng AI)

## Mục tiêu

Tích hợp OpenRouter để dùng nhiều model AI (GPT, Claude, Gemini, Llama, Mistral...) qua 1 API key duy nhất, có cấu hình toggle trong Settings.

---

## 1. OpenRouter là gì?

[OpenRouter](https://openrouter.ai) là cổng API cho phép truy cập nhiều mô hình AI khác nhau chỉ với 1 API key, không cần đăng ký từng nhà cung cấp.

Lấy key tại: https://openrouter.ai/keys

---

## 2. Cấu hình

### Cách 1: Qua Settings UI
Settings -> Cấu hình AI -> Bật toggle OpenRouter -> Nhập Key -> Chọn Model

### Cách 2: Qua file .env
```env
OPENROUTER_API_KEY=sk-or-...
OPENROUTER_MODEL=openai/gpt-oss-120b:free
```

---

## 3. Cách hoạt động trong code

```python
# chatbot/utils/llm.py
ChatOpenAI(
    model=openrouter_model,
    api_key=openrouter_api_key,
    base_url="https://openrouter.ai/api/v1",
    default_headers={
        "HTTP-Referer": "https://github.com/your-project",
        "X-OpenRouter-Title": "Your App",
    },
)
```

**Luồng dữ liệu:**
```
Settings UI -> POST /api/settings (luu DB) -> LlmFactory.get_llm() -> OpenRouter API -> response
```

---

## 4. Danh sách Model phổ biến

| Model | Phí |
|-------|-----|
| `openai/gpt-oss-120b:free` | Free |
| `openrouter/free` | Free (chọn model free tốt nhất) |
| `openai/gpt-4o-mini` | Trả phí |
| `google/gemini-2.0-flash-exp:free` | Free |
| `meta-llama/llama-3.3-70b-instruct:free` | Free |

---

## Quy tắc bắt buộc

1. Luôn dùng `LlmFactory.get_llm()` để khởi tạo, không khởi tạo trực tiếp `ChatOpenAI`.
2. Cấu hình OpenRouter lưu trong DB để người dùng tự toggle.
3. Có thể test API trong Settings trước khi lưu.
4. Model free có thể bị giới hạn rate limit.

---

## File liên quan

- [AI RAG Workflow](./skill_ai_rag_workflow.md)
- [Kiến trúc Chatbot & LLM](./skill_chatbot_architecture.md)
- [Cấu hình Môi trường (.env)](./skill_env_configuration.md)
- [Cấu trúc Dự án Tiêu chuẩn (Skill DuyVo26)](./skill_project_structure.md)
