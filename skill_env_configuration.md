# Skill: Cau hinh Moi truong (.env & .gitignore)

## Muc tieu

Quy dinh chuan file `.env`, mau `.gitignore` day du, quy tac `.env.example`, va cach nap bien moi truong bang Pydantic Settings. Dam bao bao mat API Key va cau hinh nhat quan.

---

## 1. Cac bien cau hinh tieu chuan

```env
# === HE THONG ===
SECRET_KEY=your_super_secret_jwt_key
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=60
ALLOW_ORIGINS=["http://localhost:5173"]
ENV=development

# === AI ENGINE ===
LLM_NAME=openai
OPENAI_LLM_MODEL_NAME=gpt-4o-mini
KEY_API_OPENAI=sk-proj-...
EMBEDDING_MODEL_NAME=openai

# === DATABASE ===
DB_TYPE=sqlite
DB_HOST=localhost
DB_PORT=3306

# === THANH TOAN SEPAY ===
SEPAY_API_KEY=...
SEPAY_ACCOUNT_NUMBER=...

# === GOOGLE OAUTH ===
GOOGLE_CLIENT_ID=...
GOOGLE_CLIENT_SECRET=...
FRONTEND_URL=http://localhost:5173
```

---

## 2. Quan ly An toan Ma nguon

### A. .gitignore
Bat buoc ignore: `.env`, `.venv/`, `__pycache__/`, `utils/logs/`, `utils/data_vector/`, `node_modules/`, `frontend/dist/`, `*.db`

### B. .env.example
- Giu nguyen ten bien, xoa gia tri that
- Gia tri placeholder mo ta (`your-...`)
- Commit duoc len Git

### C. Nap bien bang Pydantic
```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    FRONTEND_URL: str
    SECRET_KEY: str
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

settings = Settings()
```

---

## Quy tac bat buoc

1. KHONG commit `.env` len Git (da ignore trong `.gitignore`).
2. Luon co `.env.example` di kem.
3. `.env.example` chi chua placeholder, khong chua gia tri that.
4. Nap bien bang `pydantic-settings`, khong dung `python-dotenv` thuan.
5. `ENV=development` bat DEBUG log, `ENV=production` tat DEBUG.

---

## File lien quan

- [Cau truc Du an Tieu chuan (Skill DuyVo26)](./skill_project_structure.md)
- [Tieu chuan Viet Code (Coding Conventions)](./skill_coding_conventions.md)
- [Bao mat & Xac thuc](./skill_security_authentication.md)
- [Quan ly Thu vien (Dependencies)](./skill_dependencies_management.md)
