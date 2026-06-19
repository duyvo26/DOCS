# Skill: Ket noi OpenRouter (Da nen tang AI)

## Muc tieu

Tich hop OpenRouter de dung nhieu model AI (GPT, Claude, Gemini, Llama, Mistral...) qua 1 API key duy nhat, co cau hinh toggle trong Settings.

---

## 1. OpenRouter la gi?

[OpenRouter](https://openrouter.ai) la cong API cho phep truy cap nhieu mo hinh AI khac nhau chi voi 1 API key, khong can dang ky tung nha cung cap.

Lay key tai: https://openrouter.ai/keys

---

## 2. Cau hinh

### Cach 1: Qua Settings UI
Settings -> Cau hinh AI -> Bat toggle OpenRouter -> Nhap Key -> Chon Model

### Cach 2: Qua file .env
```env
OPENROUTER_API_KEY=sk-or-...
OPENROUTER_MODEL=openai/gpt-oss-120b:free
```

---

## 3. Cach hoat dong trong code

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

**Luong du lieu:**
```
Settings UI -> POST /api/settings (luu DB) -> LlmFactory.get_llm() -> OpenRouter API -> response
```

---

## 4. Danh sach Model pho bien

| Model | Phi |
|-------|-----|
| `openai/gpt-oss-120b:free` | Free |
| `openrouter/free` | Free (chon model free tot nhat) |
| `openai/gpt-4o-mini` | Tra phi |
| `google/gemini-2.0-flash-exp:free` | Free |
| `meta-llama/llama-3.3-70b-instruct:free` | Free |

---

## Quy tac bat buoc

1. Luon dung `LlmFactory.get_llm()` de khoi tao, khong khoi tao truc tiep `ChatOpenAI`.
2. Cau hinh OpenRouter luu trong DB de nguoi dung tu toggle.
3. Co the test API trong Settings truoc khi luu.
4. Model free co the bi gioi han rate limit.

---

## File lien quan

- [AI RAG Workflow](./skill_ai_rag_workflow.md)
- [Kien truc Chatbot & LLM](./skill_chatbot_architecture.md)
- [Cau hinh Moi truong (.env)](./skill_env_configuration.md)
- [Cau truc Du an Tieu chuan (Skill DuyVo26)](./skill_project_structure.md)
