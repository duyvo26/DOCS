# Kỹ thuật chuyên sâu: Cấu hình Môi trường (.env)

File `.env` đóng vai trò là "bộ não" điều khiển toàn bộ cấu hình nhạy cảm và các thông số hoạt động của dự án mà không cần sửa đổi trực tiếp vào code.

---

## 1. Các biến cấu hình tiêu chuẩn thường dùng

```env
# === 1. CAU HINH HE THONG (FastAPI) ===
SECRET_KEY=your_super_secret_jwt_key_here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=60
API_KEY=your_api_key_for_internal_auth
ALLOW_ORIGINS=["http://localhost:5173", "https://yourdomain.com"]
TITLE_APP=Ten Ung Dung Cua Ban
VERSION_APP=v1
ENV=development
# ENV: 'development' (bat DEBUG log) hoac 'production'

# === 2. CAU HINH AI ENGINE ===
LLM_NAME=openai
# Ho tro: openai, google, grok
OPENAI_LLM_MODEL_NAME=gpt-4o-mini
KEY_API_OPENAI=sk-proj-xxxxxxxxxxxxxxxxxxxxxx
GEMINI_API_KEY=AIzaSy-xxxxxxxxxxxxxxxxxxxxxx
GEMINI_MODEL=gemini-2.0-flash

EMBEDDING_MODEL_NAME=openai
NUMDOCS=5
# So luong tai lieu RAG lay ra moi lan truy van
MAX_RETRIES_RAG=2
# So lan tu dong thu lai neu RAG khong tim thay ket qua
NUM_VOTES_VALIDATOR=3
# So luong phieu bieu quyet (Voting) chong ao giac

# === 3. CAU HINH DATABASE ===
DB_TYPE=sqlite
# sqlite (mac dinh phat trien) hoac mysql
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=
DB_NAME=myapp_db

# === 4. CAU HINH THANH TOAN SEPAY ===
NAME_WEB=MYAPP
# Tien to nap tien (VD: MYAPPNAPTOKEN123)
SEPAY_API_KEY=xxxxxxxxxxxxxxxxxxxxx
SEPAY_ACCOUNT_NUMBER=123456789
SEPAY_BANK_BRAND=MBBank

# === 5. CAU HINH GOOGLE OAUTH 2.0 ===
GOOGLE_CLIENT_ID=xxx-xxx.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=GOCSPX-xxxxxx
GOOGLE_REDIRECT_URI=http://localhost:2643/api/v1/auth/google/callback
FRONTEND_URL=http://localhost:5173
VITE_API_URL=http://localhost:2643
```

---

## 2. Quản lý An toàn mã nguồn (`.gitignore`) và `.env.example`

Trong thực tế, bạn không bao giờ được phép đẩy file `.env` lên Github/Gitlab vì nó chứa API Key thật và Mật khẩu Database.

### A. Mau .gitignore Day du (Full Template)

Tao file `.gitignore` tai thu muc goc voi noi dung sau. Day la mau chuan cho du an FastAPI + React:

```gitignore
# ============================================================
# BIEN MOI TRUONG — Tuyet doi khong push len Git
# ============================================================
.env
.env.*
!.env.example

# ============================================================
# MOI TRUONG AO PYTHON
# ============================================================
.venv/
venv/
env/

# ============================================================
# PYTHON CACHE
# ============================================================
__pycache__/
*.py[cod]
*.pyo
*.pyd
.Python
*.egg-info/
dist/
build/

# ============================================================
# DATABASE
# ============================================================
*.db
*.sqlite3
*.sqlite

# ============================================================
# STORAGE (Du lieu lon, khong push len Git)
# ============================================================
utils/data_vector/
utils/download/
utils/upload_temp/
utils/logs/
*.log

# ============================================================
# FRONTEND BUILD OUTPUT
# ============================================================
node_modules/
frontend/dist/
frontend/.next/
frontend/build/

# ============================================================
# IDE & HE DIEU HANH
# ============================================================
.vscode/
.idea/
*.swp
*.swo
.DS_Store
Thumbs.db

# ============================================================
# CERT & KEY
# ============================================================
*.pem
*.key
*.crt
```

### B. Vai trò của `.env.example`
Thay vì đẩy `.env` lên mạng, hệ thống bắt buộc bạn tạo một file tên là `.env.example`. Trong file này, bạn **giữ nguyên tên các biến**, nhưng **xóa đi giá trị thật**.

```env
# Mẫu file .env.example để commit lên Github
SECRET_KEY=
API_KEY=
LLM_NAME=openai
OPENAI_LLM_MODEL_NAME=gpt-4o-mini
KEY_API_OPENAI=
```

Khi một lập trình viên khác clone dự án về (hoặc khi deploy lên server mới), họ chỉ cần:
1. Đổi tên file `.env.example` thành `.env`.
2. Tự điền Key (Dev/Production) của riêng họ vào.

### C. Nạp biến môi trường bằng Pydantic
Để đảm bảo ứng dụng luôn nhận diện đúng biến cấu hình từ file `.env` hiện hành, bạn nên sử dụng `pydantic-settings`:

```python
# app/config.py
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    # Khai báo các trường tương ứng với file .env
    FRONTEND_URL: str
    SECRET_KEY: str

    # Pydantic sẽ tự động tìm và nạp file .env trong thư mục gốc
    model_config = SettingsConfigDict(
        env_file=".env", 
        env_file_encoding="utf-8",
        extra="ignore" # Bỏ qua lỗi nếu có biến thừa
    )

settings = Settings()
```
