# Skill: Cấu hình Môi trường (.env & .gitignore)

## Mục tiêu

Quy định chuẩn file `.env`, mẫu `.gitignore` đầy đủ, quy tắc `.env.example`, và cách nạp biến môi trường bằng Pydantic Settings. Đảm bảo bảo mật API Key và cấu hình nhất quán.

---

## 1. Các biến cấu hình tiêu chuẩn

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

## 2. Quản lý An toàn Mã nguồn

### A. .gitignore
Bắt buộc ignore: `.env`, `.venv/`, `__pycache__/`, `utils/logs/`, `utils/data_vector/`, `node_modules/`, `frontend/dist/`, `*.db`

### B. .env.example
- Giữ nguyên tên biến, xóa giá trị thật
- Giá trị placeholder mô tả (`your-...`)
- Commit được lên Git

### C. Nạp biến bằng Pydantic
```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    FRONTEND_URL: str
    SECRET_KEY: str
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

settings = Settings()
```

---

## Quy tắc bắt buộc

1. KHÔNG commit `.env` lên Git (đã ignore trong `.gitignore`).
2. Luôn có `.env.example` đi kèm.
3. `.env.example` chỉ chứa placeholder, không chứa giá trị thật.
4. Nạp biến bằng `pydantic-settings`, không dùng `python-dotenv` thuần.
5. `ENV=development` bật DEBUG log, `ENV=production` tắt DEBUG.

---

## File liên quan

- [Cấu trúc Dự án Tiêu chuẩn (Skill DuyVo26)](./skill_project_structure.md)
- [Tiêu chuẩn Viết Code (Coding Conventions)](./skill_coding_conventions.md)
- [Bảo mật & Xác thực](./skill_security_authentication.md)
- [Quản lý Thư viện (Dependencies)](./skill_dependencies_management.md)
