# Kỹ thuật chuyên sâu: Quản lý Thư viện (Dependencies Management)

Để các đoạn code trong các file Skill (Xác thực, RAG, Parser...) hoạt động được, hệ thống yêu cầu cài đặt chính xác các thư viện mã nguồn mở. Tài liệu này tổng hợp các nhóm thư viện cốt lõi và lệnh cài đặt tương ứng.

---

## 1. Nhóm Core API & Database
Đây là nền tảng của toàn bộ ứng dụng, sử dụng FastAPI làm API Server và kết nối Cơ sở dữ liệu.

- **fastapi** / **uvicorn**: Framework xây dựng API và ASGI server.
- **python-multipart**: Dùng để xử lý `FormData` (Ví dụ: File upload, Form Login).
- **pydantic-settings** / **python-dotenv**: Dùng để đọc và quản lý cấu hình từ file `.env`.
- **requests** / **aiohttp**: Xử lý gọi API ngoại bộ (như gọi SePay, Webhooks).
- **sqlalchemy** / **mysql-connector-python**: Thư viện ORM và Driver kết nối Database (nếu nâng cấp từ SQLite lên MySQL).

**Lệnh cài đặt:**
```bash
pip install fastapi uvicorn python-multipart pydantic-settings python-dotenv requests aiohttp sqlalchemy mysql-connector-python
```

---

## 2. Nhóm Bảo mật & Xác thực (Security & JWT)
Sử dụng cho `skill_security_authentication.md` và các luồng đăng nhập.

- **python-jose[cryptography]**: Thư viện dùng để tạo và giải mã JWT Token mã hóa cao cấp.
- **passlib[bcrypt]**: Dùng để mã hóa (Hash) mật khẩu lưu vào DB và kiểm tra so khớp mật khẩu.

**Lệnh cài đặt:**
```bash
pip install "python-jose[cryptography]" "passlib[bcrypt]"
```

---

## 3. Nhóm Trí tuệ Nhân tạo & RAG (AI Engine)
Sử dụng cho `skill_ai_rag_workflow.md`.

- **langchain** / **langgraph**: Bộ khung chính của RAG và quản lý luồng StateMachine cho AI Agent.
- **langchain-openai** / **langchain-google-genai**: Connector kết nối tới các LLM phổ biến.
- **faiss-cpu**: Thư viện quản lý Vector Database.
- **tiktoken**: Đếm số lượng Token chính xác của OpenAI.
- **crawl4ai** / **beautifulsoup4**: (Tùy chọn) Phục vụ cho Node `web_search` của AI để cào dữ liệu từ Internet.

**Lệnh cài đặt:**
```bash
pip install langchain langgraph langchain-openai langchain-google-genai faiss-cpu tiktoken crawl4ai beautifulsoup4
```

---

## 4. Nhóm Xử lý Dữ liệu & Tài liệu (Data Ingestion)
Sử dụng cho `skill_docx_to_md_parser.md` và các tác vụ nạp file lên RAG.

- **markitdown**: Thư viện siêu mạnh của Microsoft chuyển đổi DOCX, PDF sang Markdown sạch.
- **pandas** / **openpyxl**: Cực kỳ quan trọng nếu hệ thống cần đọc, xuất dữ liệu báo cáo ra file Excel (.xlsx).

**Lệnh cài đặt:**
```bash
pip install markitdown pandas openpyxl
```

---

## 5. Nhóm Frontend (React/Vite)
Sử dụng cho `skill_frontend_architecture.md`. Cài đặt qua `npm` hoặc `yarn`.

- **axios**: Goi API chuyen nghiep (ho tro Interceptor gan JWT tu dong).
- **tailwindcss**: Framework CSS tien loi.
- **react-router-dom**: Quan ly dieu huong trang (Routing).
- **lucide-react**: Thu vien Icon chuan xac va sieu nhe.
- **zustand**: Quan ly state nhe, don gian — dung khi AuthContext khong du.
- **zod**: Validate du lieu phia Frontend (form, API response schema).
- **react-hook-form**: Quan ly form phuc tap, ket hop voi zod de validate.

**Lenh cai dat:**
```bash
npm install axios react-router-dom lucide-react zustand zod react-hook-form
npm install -D tailwindcss postcss autoprefixer
```

---

## 6. Loi khuyen cho Lap trinh vien
Thay vi go tung lenh tren, ban nen gom tat ca cac thu vien Python vao mot file `requirements.txt` va cai dat mot lan qua lenh:
```bash
pip install -r requirements.txt
```

**Luu y quan trong**: Hay luon nho kich hoat moi truong ao (`.venv`) truoc khi chay lenh `pip install` de tranh lam ban moi truong Python cua he thong.
