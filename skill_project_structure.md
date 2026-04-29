# Cấu trúc Dự án Tiêu chuẩn & Hướng dẫn Lập trình (Standard Project Structure)

Tài liệu này quy định cấu trúc thư mục chuẩn và các nguyên tắc phát triển bắt buộc áp dụng cho mọi dự án tích hợp AI (FastAPI + AI Engine + Frontend) của chúng ta. 

Mục tiêu của tài liệu là giúp các AI Agent và lập trình viên dễ dàng định vị mã nguồn, hiểu rõ kiến trúc, và tuân thủ các luồng xử lý kỹ thuật đã được đóng gói thành "Skill".

---

## 1. Cấu trúc Thư mục Hệ thống (Project Overview)

Mọi dự án cần tuân thủ bộ khung thư mục dưới đây để đảm bảo tính nhất quán:

```text
project_root/
├── app/                        # [BACKEND CORE] Mã nguồn API (FastAPI)
│   ├── main.py                 # Điểm khởi đầu ứng dụng (Khởi tạo, CORS, Middleware)
│   ├── config.py               # Quản lý cấu hình (Load từ .env)
│   ├── models/                 # Chứa cấu trúc Database (SQLite/PostgreSQL) và Pydantic schemas
│   │   └── base_db.py          # Kết nối và các Query cơ bản
│   ├── routers/                # Các Endpoints API chia theo module (auth, payment, base)
│   ├── security/               # Logic bảo mật (JWT, Hashing)
│   └── utils/                  # Hàm tiện ích dùng chung cho API
├── chatbot/                    # [AI ENGINE] Logic xử lý AI cốt lõi
│   ├── services/               # Chứa các luồng workflow LangGraph (vd: files_rag_multiple_chat_agent.py)
│   └── utils/                  # Các Agent nhỏ (Document Grader, Answer Generator, Validator)
├── ingestion/                  # [DATA PIPELINE] Logic nạp dữ liệu vào Vector Store
│   ├── rag_multi_class_ingest.py # Xử lý tách chunk đặc thù (Domain-Specific Splitting)
│   ├── retriever.py            # Logic tìm kiếm FAISS
│   └── vector_data_builder.py  # Xây dựng và cập nhật Vector Database
├── scoring/                    # [EVALUATION] (Tùy chọn) Framework chấm điểm AI và RAG
├── frontend/                   # [FRONTEND] Giao diện người dùng (React/Vite/TypeScript)
│   └── src/
│       ├── main.tsx            # Entry point — chỉ mount App + Providers
│       ├── App.tsx             # Root: bọc Providers, gắn RootRouter
│       ├── router/
│       │   └── index.tsx       # RootRouter: gom tất cả domain routers
│       ├── contexts/
│       │   └── AuthContext.tsx # Global Auth State (JWT, user info)
│       ├── services/
│       │   └── api.ts          # Axios instance + tất cả API functions
│       ├── hooks/              # Custom hooks (useAsyncAction...)
│       ├── components/         # Shared UI (ProtectedRoute, AdminRoute, Layout)
│       ├── domains/            # Mỗi thư mục = 1 domain nghiệp vụ độc lập
│       │   ├── auth/           # Domain xác thực: router, pages, components
│       │   ├── chat/           # Domain chatbot AI
│       │   ├── payment/        # Domain thanh toán
│       │   └── admin/          # Domain quản trị
│       └── types/
│           └── index.ts        # Shared TypeScript types
├── utils/                      # [STORAGE] Thu muc luu tru tap trung
│   ├── download/               # File export, logo, favicon...
│   ├── upload_temp/            # File tai len dang cho xu ly
│   ├── data_vector/            # Noi luu tru FAISS Index thuc te
│   └── logs/                   # File log ung dung (xem skill_logging_monitoring.md)
├── test/                       # Unit tests (pytest, vitest)
├── deploy/                     # Cau hinh deploy (nginx.conf, systemd service)
├── .env                        # Bien moi truong (KHONG push len Git)
├── .env.example                # File mau bien moi truong (push len Git)
├── .gitignore                  # Quy tac bo qua file nhay cam (xem skill_env_configuration.md)
└── requirements.txt            # Danh sach thu vien Python
```

---

## 2. Bảng tra cứu Kỹ thuật (Skill Directory)

Các luồng xử lý nghiệp vụ phức tạp đã được đúc kết thành các tài liệu "Skill". Lập trình viên và AI **PHẢI** tham chiếu các file này trước khi code tính năng tương ứng.

### Nhóm AI & RAG (Trí tuệ Nhân tạo)
*   [**Kỹ thuật AI RAG Workflow (Standard)**](./skill_ai_rag_workflow.md): Cấu trúc luồng đồ thị LangGraph, định tuyến câu hỏi, bộ lọc tài liệu và quản lý chi phí token.
*   [**Kỹ thuật Parser (DOCX to MD)**](./skill_docx_to_md_parser.md): Quy trình chuyển đổi báo cáo phức tạp thành cấu trúc Markdown theo Headings để nạp vào AI.

### Nhom Xac thuc, Moi truong & Bao mat
*   [**Cau hinh Moi truong (.env & .gitignore)**](./skill_env_configuration.md): Chuan file `.env`, day du mau `.gitignore`, quy tac `.env.example` va Pydantic Settings.
*   [**Viet Ma SQL Da nen tang (MySQL & SQLite)**](./skill_sql_compatibility.md): Ky thuat dung Raw SQL tuong thich da driver, chong SQL Injection bang Parameter Binding.
*   [**Quan ly Thu vien (Dependencies)**](./skill_dependencies_management.md): Danh sach package (FastAPI, LangGraph, JWT, zustand, zod...) can cai dat de chay cac Skill.
*   [**Xac thuc va Bao mat Toan dien**](./skill_security_authentication.md): JWT Stateless, bcrypt hash mat khau, RBAC Admin, chong Path Traversal, va Frontend Security checklist.
*   [**Dang nhap Google OAuth (Redirect Flow)**](./skill_google_oauth_redirect.md): Luong dang nhap muot ma qua Backend Redirect, khong lam lo JSON tho.
*   [**Dang nhap Hybrid App (Cloud-Sync Polling)**](./skill_hybrid_app_login.md): Giai phap dang nhap cho App Mobile (Flutter/React Native) su dung WebView ket hop Polling DB.

### Nhom Tac vu & Thanh toan
*   [**Tac vu Bat dong bo & Polling**](./skill_async_task_polling.md): Co che Background Tasks cua FastAPI ket hop Polling phia Frontend de xu ly tac vu AI nang.
*   [**He thong Thanh toan Tu dong (Polling & Sync)**](./skill_payment_polling_sync.md): Thuat toan doi soat giao dich ngan hang qua SePay tu dong khong can Webhook.

### Nhom Toi uu Frontend & Giao dien
*   [**Kien truc Frontend & API Setup**](./skill_frontend_architecture.md): Quan ly API tap trung (`api.ts`), JWT Interceptor, button loading state, va bao mat JWT phia Frontend.
*   [**Chia nho Components, Pages & Domain Routing**](./skill_frontend_routing_components.md): Kien truc domain-based voi React Router v6, lazy loading, ProtectedRoute/AdminRoute, nguyen tac tach component.
*   [**Quan ly SEO Dong (Dynamic SEO)**](./skill_dynamic_seo_manager.md): Ky thuat thay the truc tiep Meta Tag trong file tinh `index.html` cua React giup chia se link hieu qua.

### Nhom Quy tac Viet Code & Tai lieu
*   [**Tieu chuan Viet Code & Dat ten (Coding Conventions)**](./skill_coding_conventions.md): Dat ten, Type Hinting, Docstring, cam emoji, va Git Workflow (Conventional Commits, branching strategy).
*   [**Huong dan Viet README.md Chuan**](./skill_readme_writing.md): Cau truc 7 phan bat buoc, mau README day du, quy tac `.env.example`, checklist truoc khi commit.
*   [**Logging & Monitoring Chuan**](./skill_logging_monitoring.md): Cau hinh Python logging co cau truc, RotatingFileHandler, quy tac log level, cam dung `print()` trong production.
*   [**Chuan API Response (Standard Response Format)**](./skill_api_response_standard.md): JSON thong nhat cho moi Endpoint: ApiSuccess, ApiError, PaginatedData, Global Exception Handler.

---

## 3. Nguyên tắc phát triển cốt lõi (Core Principles)

1. **Tuan thu Cau truc Modular**: Tuyet doi khong code logic AI (LangChain/LangGraph) vao trong cac file `router` cua FastAPI. Backend API (`app/`) chi nhan request va goi cac ham xu ly ben trong module `chatbot/` hoac `ingestion/`.
2. **Kho phuc trang thai (Resilience)**: Moi tac vu nang phai co co che Polling. Nguoi dung F5 (tai lai trang) khong duoc lam gian doan tien trinh. (Xem `skill_async_task_polling.md`).
3. **An toan Bi mat (Secrets)**: Cac API Key (OpenAI, Gemini, SePay) va Secret Key (JWT) luon dat o `.env` Backend. Dung `.env.example` de commit mau len Git. KHONG bao gio commit file `.env` thuc. (Xem `skill_env_configuration.md`).
4. **Phan hoi Ro rang**: Moi Endpoint giao tiep voi Frontend phai tra ve JSON dinh dang chuan `ApiSuccess` / `ApiError`. (Xem `skill_api_response_standard.md`).
5. **Logging thay vi Print**: Moi file module phai khai bao `logger = get_logger(__name__)`. Cam tuyet doi dung `print()` trong code production. (Xem `skill_logging_monitoring.md`).
6. **Comment giai thich**: Moi ham phuc tap phai co Docstring (Python) hoac JSDoc (TypeScript). Comment phai tra loi "Tai sao viet the nay?" chu khong phai "Code nay lam gi?". (Xem `skill_coding_conventions.md`).
7. **Cam Emoji**: Khong dung emoji trong bat ky file code, markdown, hay comment nao. (Xem `skill_coding_conventions.md` Muc 7).

---

## 4. Hướng dẫn Môi trường & Quản lý File (Environment & Storage)

1. **Môi trường ảo (Virtual Environment)**:
   - Tất cả các dự án Python bắt buộc phải chạy trong môi trường ảo (Virtual Env) để tránh xung đột thư viện với hệ thống.
   - Luôn khởi tạo môi trường bằng lệnh: `python -m venv .venv`
   - Nhớ kích hoạt `.venv` (ví dụ: `source .venv/bin/activate` hoặc `.venv\Scripts\activate`) và cài đặt thư viện qua `pip install -r requirements.txt` trước khi lập trình hoặc chạy app.

2. **Xác định Thư mục Gốc (Root Directory) qua `.env`**:
   - Hệ thống không sử dụng đường dẫn tương đối (kiểu `../../`) vốn rất dễ gây lỗi khi đổi thư mục chạy script.
   - Thay vào đó, trong file `app/config.py`, hệ thống sẽ tự động tìm kiếm vị trí của file `.env`. Thư mục chứa file `.env` sẽ được định nghĩa là **`DIR_ROOT`** (Thư mục gốc tuyệt đối). Mọi thao tác đọc/ghi file trong dự án đều phải dựa trên `DIR_ROOT` này.

3. **Quy hoạch Thư mục Lưu trữ (`utils/`)**:
   - Thư mục `utils/` nằm ở ngoài cùng (Root level) được dùng làm không gian lưu trữ vật lý tập trung của dự án.
   - Nơi đây chứa các file do người dùng tải lên (`utils/upload_temp`), các file kết xuất/tải về (`utils/download`), cũng như hệ thống cơ sở dữ liệu Vector cục bộ (`utils/data_vector`).
   - Việc quy hoạch tập trung giúp code sạch hơn và cực kỳ thuận tiện khi cần Backup dữ liệu hoặc thiết lập Mount Volume khi deploy bằng Docker.