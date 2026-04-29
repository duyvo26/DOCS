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
├── frontend/                   # [FRONTEND] Giao diện người dùng (React/Vite hoặc HTML/Vanilla)
│   ├── App.tsx                 # Main Component quản lý Route & Auth State
│   ├── api.ts                  # Service Layer gọi API Backend
│   └── components/             # Thư mục UI Components chia theo chức năng
├── utils/                      # [STORAGE] Thư mục lưu trữ tạm thời
│   ├── download/               # File export, logo, favicon...
│   ├── upload_temp/            # File tải lên đang chờ xử lý
│   └── data_vector/            # Nơi lưu trữ FAISS Index thực tế
├── test/                       # Unit tests
├── .env                        # Biến môi trường (KHÔNG push lên Git)
├── .env.example                # File mẫu biến môi trường (PUSH lên Git)
├── .gitignore                  # Quy tắc bỏ qua file nhạy cảm
└── requirements.txt            # Danh sách thư viện Python
```

---

## 2. Bảng tra cứu Kỹ thuật (Skill Directory)

Các luồng xử lý nghiệp vụ phức tạp đã được đúc kết thành các tài liệu "Skill". Lập trình viên và AI **PHẢI** tham chiếu các file này trước khi code tính năng tương ứng.

### Nhóm AI & RAG (Trí tuệ Nhân tạo)
*   [**Kỹ thuật AI RAG Workflow (Standard)**](./skill_ai_rag_workflow.md): Cấu trúc luồng đồ thị LangGraph, định tuyến câu hỏi, bộ lọc tài liệu và quản lý chi phí token.
*   [**Kỹ thuật Parser (DOCX to MD)**](./skill_docx_to_md_parser.md): Quy trình chuyển đổi báo cáo phức tạp thành cấu trúc Markdown theo Headings để nạp vào AI.

### Nhóm Xác thực, Môi trường & Bảo mật
*   [**Cấu hình Môi trường (.env & .gitignore)**](./skill_env_configuration.md): Chuẩn file `.env`, cách sử dụng `.env.example` và quy tắc cấu hình Gitignore bảo mật mã nguồn.
*   [**Viết Mã SQL Đa nền tảng (MySQL & SQLite)**](./skill_sql_compatibility.md): Kỹ thuật dùng Raw SQL tương thích đa driver, chống SQL Injection bằng Parameter Binding.
*   [**Quản lý Thư viện (Dependencies)**](./skill_dependencies_management.md): Danh sách các package (FastAPI, LangGraph, JWT, MarkItDown...) cần cài đặt để chạy các Skill.
*   [**Xác thực và Bảo mật Toàn diện**](./skill_security_authentication.md): Cơ chế kiểm tra JWT Stateless, quản lý Fallback Avatar 3 lớp và chống Path Traversal.
*   [**Đăng nhập Google OAuth (Redirect Flow)**](./skill_google_oauth_redirect.md): Luồng đăng nhập mượt mà qua Backend Redirect, không làm lộ JSON thô.
*   [**Đăng nhập Hybrid App (Cloud-Sync Polling)**](./skill_hybrid_app_login.md): Giải pháp đăng nhập cho App Mobile (Flutter/React Native) sử dụng WebView kết hợp Polling DB thay thế Deep Link.

### Nhóm Tác vụ & Thanh toán
*   [**Tác vụ Bất đồng bộ & Polling**](./skill_async_task_polling.md): Cơ chế sử dụng Background Tasks của FastAPI kết hợp Polling phía Frontend để xử lý các tác vụ AI mất nhiều thời gian.
*   [**Hệ thống Thanh toán Tự động (Polling & Sync)**](./skill_payment_polling_sync.md): Thuật toán đối soát giao dịch ngân hàng qua SePay tự động không cần Webhook.

### Nhóm Tối ưu Frontend & Giao diện
*   [**Kiến trúc Frontend & API Setup**](./skill_frontend_architecture.md): Quy chuẩn quản lý gọi API tập trung (`api.ts`), định tuyến `/api/v1` với Axios, và tích hợp Tailwind CSS.
*   [**Quản lý SEO Dong (Dynamic SEO)**](./skill_dynamic_seo_manager.md): Kỹ thuật thay thế trực tiếp Meta Tag trong file tĩnh `index.html` của React giúp chia sẻ link hiệu quả.

### Nhóm Quy tắc Viết Code
*   [**Tiêu chuẩn Viết Code & Đặt tên (Coding Conventions)**](./skill_coding_conventions.md): Quy định cách đặt tên, Type Hinting, Docstring, quy tắc comment giải thích code và quản lý lỗi.

---

## 3. Nguyên tắc phát triển cốt lõi (Core Principles)

1. **Tuân thủ Cấu trúc Modular**: Tuyệt đối không code logic AI (LangChain/LangGraph) vào trong các file `router` của FastAPI. Backend API (`app/`) chỉ nhận request và gọi các hàm xử lý bên trong module `chatbot/` hoặc `ingestion/`.
2. **Khôi phục trạng thái (Resilience)**: Mọi tác vụ nặng phải có cơ chế Polling. Người dùng F5 (tải lại trang) không được làm gián đoạn tiến trình. (Xem `skill_async_task_polling.md`).
3. **An toàn Bi mật (Secrets)**: Các API Key (OpenAI, Gemini, SePay) và Secret Key (JWT, XOR) luôn đặt ở `.env` Backend. Dùng `.env.example` để commit mẫu lên Git.
4. **Phản hồi Ro ràng**: Mọi Endpoint giao tiếp với Frontend phải trả về JSON định dạng chuẩn có bẫy lỗi (`HTTPException`) minh bạch.
5. **Comment giải thích**: Mọi hàm phức tạp phải có Docstring (Python) hoặc JSDoc (TypeScript). Comment phải trả lời "Tại sao viết thế này?" chứ không phải "Code này làm gì?". (Xem `skill_coding_conventions.md`).

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