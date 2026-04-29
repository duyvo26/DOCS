# Kỹ thuật chuyên sâu: Cấu hình Môi trường (.env)

File `.env` đóng vai trò là "bộ não" điều khiển toàn bộ cấu hình nhạy cảm và các thông số hoạt động của dự án mà không cần sửa đổi trực tiếp vào code.

---

## 1. Các biến cấu hình tiêu chuẩn thường dùng

```env
# === 1. CAU HINH HE THONG (FastAPI) ===
SECRET_KEY=your_super_secret_jwt_key_here
API_KEY=your_api_key_for_internal_auth
ALLOW_ORIGINS=["http://localhost:5173", "https://yourdomain.com"]
TITLE_APP=Tên Ứng Dụng Của Bạn
VERSION_APP=v1

# === 2. CAU HINH AI ENGINE ===
LLM_NAME=openai # Hỗ trợ: openai, google, grok
OPENAI_LLM_MODEL_NAME=gpt-4o-mini
KEY_API_OPENAI=sk-proj-xxxxxxxxxxxxxxxxxxxxxx

EMBEDDING_MODEL_NAME=openai
NUMDOCS=5 # Số lượng tài liệu RAG lấy ra mỗi lần truy vấn
MAX_RETRIES_RAG=2 # Số lần tự động thử lại nếu RAG không tìm thấy kết quả
NUM_VOTES_VALIDATOR=3 # Số lượng phiếu biểu quyết (Voting) chống ảo giác

# === 3. CAU HINH THANH TOAN SEPAY ===
NAME_WEB=MYAPP # Tiền tố nạp tiền (VD: MYAPPNAPTOKEN123)
SEPAY_API_KEY=xxxxxxxxxxxxxxxxxxxxx
SEPAY_ACCOUNT_NUMBER=123456789
SEPAY_BANK_BRAND=MBBank

# === 4. CAU HINH GOOGLE OAUTH 2.0 ===
GOOGLE_CLIENT_ID=xxx-xxx.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=GOCSPX-xxxxxx
GOOGLE_REDIRECT_URI=http://localhost:2643/api/v1/auth/google/callback
FRONTEND_URL=http://localhost:5173
```

---

## 2. Quản lý An toàn mã nguồn (`.gitignore`) và `.env.example`

Trong thực tế, bạn không bao giờ được phép đẩy file `.env` lên Github/Gitlab vì nó chứa API Key thật và Mật khẩu Database.

### A. Cấu hình `.gitignore`
Bạn phải tạo một file **`.gitignore`** ở thư mục ngoài cùng của dự án và khai báo block các file môi trường:

```text
# Bỏ qua mọi file môi trường có chứa biến thật
.env
.env.*
!.env.example

# Bỏ qua môi trường ảo Python
.venv/
venv/
__pycache__/

# Bỏ qua thư mục Database/Files (tránh đầy Git)
utils/data_vector/
utils/download/
utils/upload_temp/
*.sqlite3
*.db
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
