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
│   ├── database.py             # Kết nối Database (Engine, SessionLocal, Base)
│   ├── models/                 # Chứa các bảng Database (SQLAlchemy Models)
│   │   ├── user_model.py       # Tách riêng theo domain/module
│   │   └── chat_model.py
│   ├── schemas/                # Chứa Pydantic schemas (Data Validation)
│   │   ├── user_schema.py      # Tách riêng theo domain/module
│   │   └── chat_schema.py
│   ├── routers/                # Các Endpoints API chia theo module (auth, payment, base)
│   ├── security/               # Logic bảo mật (JWT, Hashing)
│   └── utils/                  # Hàm tiện ích dùng chung cho API
├── chatbot/                    # [AI ENGINE] Logic xử lý AI cốt lõi (Chỉ chứa code AI/LLM)
│   ├── services/               # Chứa các luồng workflow LangGraph (Xử lý logic AI đa bước)
│   └── utils/                  # Thành phần AI đơn lẻ (Agents, Prompt, LLM Factory)
│       ├── llm.py              # Class khởi tạo LLM đa nền tảng
│       ├── prompt.py           # Class quản lý Prompt Templates tập trung
│       ├── graph_state.py      # Định nghĩa State cho LangGraph
│       └── {name}_agent.py     # Các Agent đơn chức năng (grader, generator...)
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
*   [**Kiến trúc Module Chatbot & LLM**](./skill_chatbot_architecture.md): Quy định chuẩn hóa thư mục, cách khởi tạo LLM, quản lý Prompt và xây dựng Agent.
*   [**Kết nối OpenRouter (Đa nền tảng AI)**](./skill_openrouter_integration.md): Hướng dẫn tích hợp OpenRouter để dùng nhiều model AI (GPT, Claude, Gemini, Llama...) qua 1 API key duy nhất, cấu hình toggle trong Settings.
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
2. **Chatbot Module Chuyên biệt**: Thư mục `chatbot/` chỉ được phép chứa code liên quan đến AI, LLM, Prompts và Agents. KHÔNG để code nạp dữ liệu (Ingestion), Database model, hay logic nghiệp vụ thông thường vào đây.
3. **Kho phuc trang thai (Resilience)**: Moi tac vu nang phai co co che Polling. Nguoi dung F5 (tai lai trang) khong duoc lam gian doan tien trinh. (Xem `skill_async_task_polling.md`).
4. **An toan Bi mat (Secrets)**: Cac API Key (OpenAI, Gemini, SePay) va Secret Key (JWT) luon dat o `.env` Backend. Dung `.env.example` de commit mau len Git. KHONG bao gio commit file `.env` thuc. (Xem `skill_env_configuration.md`).
5. **Phan hoi Ro rang**: Moi Endpoint giao tiep voi Frontend phai tra ve JSON dinh dang chuan `ApiSuccess` / `ApiError`. (Xem `skill_api_response_standard.md`).
6. **Logging thay vi Print**: Moi file module phai khai bao `logger = get_logger(__name__)`. Cam tuyet doi dung `print()` trong code production. (Xem `skill_logging_monitoring.md`).
7. **Comment giai thich**: Moi ham phuc tap phai co Docstring (Python) hoac JSDoc (TypeScript). Comment phai tra loi "Tai sao viet the nay?" chu khong phai "Code nay lam gi?". (Xem `skill_coding_conventions.md`).
8. **Cam Emoji**: Khong dung emoji trong bat ky file code, markdown, hay comment nao. (Xem `skill_coding_conventions.md` Muc 7).

---

## 4. Hướng dẫn Môi trường & Quản lý File (Environment & Storage)

1. **Môi trường ảo (Virtual Environment)**:
   - Tất cả các dự án Python bắt buộc phải chạy trong môi trường ảo (Virtual Env) để tránh xung đột thư viện với hệ thống.
   - Luôn khởi tạo môi trường bằng lệnh: `python -m venv .venv`
   - Nhớ kích hoạt `.venv` (ví dụ: `source .venv/bin/activate` hoặc `.venv\Scripts\activate`) và cài đặt thư viện qua `pip install -r requirements.txt` trước khi lập trình hoặc chạy app.

2. **Xác định Thư mục Gốc (Root Directory) qua `.env`**:
   - Hệ thống không sử dụng đường dẫn tương đối (kiểu `../../`) vốn rất dễ gây lỗi khi đổi thư mục chạy script.
   - Thay vào đó, trong file `app/config.py`, hệ thống sẽ tự động tìm kiếm vị trí của file `.env`. Thư mục chứa file `.env` sẽ được định nghĩa là **`DIR_ROOT`** (Thư mục gốc tuyệt đối). Mọi thao tác đọc/ghi file trong dự án đều phải dựa trên `DIR_ROOT` này.

3. **OpenRouter — Đa nền tảng AI**:
   - Hệ thống hỗ trợ chuyển đổi linh hoạt giữa **OpenAI** và **OpenRouter** qua toggle trong Settings.
   - Khi bật OpenRouter, `LlmFactory.get_llm()` dùng `base_url="https://openrouter.ai/api/v1"` và model do người dùng chọn (ví dụ: `openai/gpt-oss-120b:free`).
   - Có thể cấu hình qua Settings UI hoặc biến môi trường trong `.env`:
     ```env
     OPENROUTER_API_KEY=sk-or-...
     OPENROUTER_MODEL=openai/gpt-oss-120b:free
     ```
   - Xem chi tiết: [Kết nối OpenRouter](./skill_openrouter_integration.md)

4. **Quy hoạch Thư mục Lưu trữ (`utils/`)**:
   - Thư mục `utils/` nằm ở ngoài cùng (Root level) được dùng làm không gian lưu trữ vật lý tập trung của dự án.
   - Nơi đây chứa các file do người dùng tải lên (`utils/upload_temp`), các file kết xuất/tải về (`utils/download`), cũng như hệ thống cơ sở dữ liệu Vector cục bộ (`utils/data_vector`).
   - Việc quy hoạch tập trung giúp code sạch hơn và cực kỳ thuận tiện khi cần Backup dữ liệu hoặc thiết lập Mount Volume khi deploy bằng Docker.

---

## 5. Quy tắc Thực thi Bắt buộc (Execution Rules)

Phan nay la bo quy tac KHONG DUOC VI PHAM. Muc tieu la ngan chan viec tao file va thu muc sai vi tri, gay ra tinh trang code bi phan tan, kho bao tri va vi pham kien truc da quy dinh.

---

### Rule 1: Router KHONG chua Business Logic

**Dinh nghia**: File trong `app/routers/` chi duoc phep lam dung 3 viec:
1. Nhan va validate request (dung Pydantic schema)
2. Goi ham xu ly tu `service` tuong ung
3. Tra ve response theo chuan `ApiSuccess` / `ApiError`

**Vi du DUNG**:

```python
# app/routers/chat_router.py
from fastapi import APIRouter, Depends
from app.models.chat_schema import ChatRequest
from chatbot.services.chat_service import run_chat_flow
from app.utils.response import ApiSuccess, ApiError

router = APIRouter()

@router.post("/chat")
async def chat_endpoint(req: ChatRequest, user=Depends(get_current_user)):
    # Chi goi service, khong xu ly gi them
    result = await run_chat_flow(user_id=user.id, message=req.message)
    return ApiSuccess(data=result)
```

**Vi du SAI - TUYET DOI CAM**:

```python
# app/routers/chat_router.py  <-- SAI: LangChain nam trong router
from langchain_openai import ChatOpenAI
from langgraph.graph import StateGraph

@router.post("/chat")
async def chat_endpoint(req: ChatRequest):
    llm = ChatOpenAI(model="gpt-4o")   # CAM: khoi tao LLM trong router
    chain = llm | StrOutputParser()     # CAM: dinh nghia chain trong router
    result = chain.invoke(req.message)  # CAM: goi LangChain truc tiep
    return {"result": result}
```

---

### Rule 2: AI Logic Bat buoc Nam Trong `chatbot/services/`

**Dinh nghia**: Moi logic lien quan den LangChain, LangGraph, Prompt, RAG, Agent deu phai dat trong thu muc `chatbot/services/`.

**Quy tac dat ten file trong `chatbot/services/`**:
- Dung snake_case, ten mo ta ro chuc nang cua workflow
- Dinh dang khuyen nghi: `{chu_de}_{kieu_xu_ly}_service.py`
- Vi du hop le: `rag_chat_service.py`, `document_qa_service.py`, `multi_agent_service.py`
- **CAM** dat ten chung chung: `handler.py`, `logic.py`, `ai.py`, `process.py`

**Quy tac dat ten file trong `chatbot/utils/`**:
- Moi file la 1 Agent nho co chuc nang don le (Single Responsibility)
- Dinh dang khuyen nghi: `{chuc_nang}_agent.py` hoac `{chuc_nang}_util.py`
- **prompt.py**: File dac biet chua Class tap trung quan ly tat ca Prompt (System Prompt, Templates).
- Vi du hop le: `document_grader_agent.py`, `prompt.py`, `answer_generator_agent.py`
- **CAM** gop nhieu agent khac nhau vao 1 file

---

### Rule 3: Luong Xu ly API Chatbot Bat buoc Theo Thu Tu

Moi API endpoint lien quan den AI PHAI tuan thu luong sau:

```
[Frontend Request]
      |
      v
[app/routers/]          --> Chi validate & dispatch
      |
      v
[chatbot/services/]     --> Chua toan bo business logic, goi cac agent
      |
      v
[chatbot/utils/]        --> Cac agent don le: grade, generate, validate
      |
      v
[Response tra ve router] --> Router dong goi ApiSuccess/ApiError
```

**CAM cac loi di tat sau**:

| Loi vi pham | Dung thay the |
|---|---|
| Goi LangChain truc tiep trong `app/routers/` | Tao ham trong `chatbot/services/` va goi tu router |
| Viet logic xu ly trong app/models/ | `app/models/` chi chua SQLAlchemy model, `app/schemas/` chua Pydantic schema |
| Dat file `*_agent.py` trong `app/utils/` | Agent AI phai o `chatbot/utils/`, khong phai `app/utils/` |
| Import `chatbot/` trong `ingestion/` | `ingestion/` la pipeline doc lap, khong phu thuoc `chatbot/` |

---

### Rule 4: Bang Phan Cong File - Dat Code O Dau?

Su dung bang nay moi khi can quyet dinh dat 1 doan code vao file nao:

| Loai code can viet | Dat vao file nao |
|---|---|
| Endpoint API, route definition | `app/routers/{module}_router.py` |
| Pydantic request/response schema | `app/schemas/{module}_schema.py` |
| SQLAlchemy model (DB Table) | `app/models/{module}_model.py` |
| Database Connection (Session) | `app/database.py` |
| JWT, password hash, permission check | `app/security/` |
| Ham tien ich dung chung cho API (format date, parse string...) | `app/utils/` |
| Toan bo workflow LangGraph/LangChain | `chatbot/services/{ten}_service.py` |
| Agent nho: grader, generator, validator | `chatbot/utils/{ten}_agent.py` |
| Prompt Templates (System, Tool) | `chatbot/utils/prompt.py` (Dung Class de quan ly) |
| Khoi tao LLM (Factory) — ho tro OpenAI & OpenRouter | `chatbot/utils/llm.py` |
| Cau hinh OpenRouter (toggle, key, model) | `app/routers/settings_router.py` + `frontend/components/Settings.tsx` |
| LangGraph State Definition | `chatbot/utils/graph_state.py` |
| Ket noi va truy van FAISS | `ingestion/retriever.py` |
| Xay dung / cap nhat Vector DB | `ingestion/vector_data_builder.py` |
| Logic chia chunk dac thu theo domain | `ingestion/rag_multi_class_ingest.py` |
| Global config, bien moi truong | `app/config.py` (load tu `.env`) |
| File log output | `utils/logs/` (KHONG tao folder `logs/` noi khac) |
| File upload tam thoi tu nguoi dung | `utils/upload_temp/` |
| File export, bao cao, favicon | `utils/download/` |
| FAISS index, embedding data | `utils/data_vector/` |
| Unit test cho backend | `test/` (dung pytest) |
| Unit test cho frontend | `frontend/src/__tests__/` (dung vitest) |

---

### Rule 5: Quy tac Khong Tao Thu Muc Ngoai Cau Truc Chuan

**CAM** tao cac thu muc sau day o bat ky cap nao (tru khi co ly do dac biet va duoc trao doi truoc):

- `helpers/` — thay bang `utils/` da co trong chuan
- `controllers/` — FastAPI khong dung MVC kieu nay, dung `routers/` + `services/`
- `middleware/` thanh thu muc rieng — middleware khai bao trong `app/main.py`
- `constants/` — hang so dat trong `app/config.py` hoac file schema tuong ung
- `lib/` — khong co y nghia ro rang, thay bang ten muc dich cu the
- `src/` tai root level — `src/` chi ton tai ben trong `frontend/`
- `api/` tai root level — thu muc API la `app/routers/`, khong tao them `api/`

**Khi that su can them thu muc moi**:
1. Xem lai Section 1 de kiem tra lieu thu muc da ton tai hay chua
2. Neu khong co thu muc phu hop, dat code vao `app/utils/` (cho API helper) hoac `chatbot/utils/` (cho AI helper)
3. Chi tao thu muc moi khi chuc nang thuc su doc lap va khong the gop vao dau hien co

---

### Rule 6: Quy tac Import - Huong Di Mot Chieu

De tranh circular import va giu kien truc ro rang, cac module PHAI tuan thu huong import mot chieu:

```
app/routers/ --> chatbot/services/ --> chatbot/utils/
     |                |                     |
     v                v                     v
app/schemas/     app/models/         ingestion/retriever.py
     |                |
     v                v
app/security/    app/database.py
```

**CAM nguoc chieu**:
- `chatbot/` KHONG duoc import tu `app/routers/`
- `ingestion/` KHONG duoc import tu `chatbot/services/`
- `app/models/` KHONG duoc import tu `app/routers/` theo kieu vong tron
- `app/utils/` KHONG duoc import tu `chatbot/` (util API khac util AI)

**Ham dung chung thuc su** (vi du: ham doc file, format date) co the dat vao `app/utils/` va duoc import tu ca `app/` lan `chatbot/` - day la truong hop ngoai le hop le duy nhat.

---

### Rule 7: Checklist Truoc Khi Tao File Moi

Truoc khi tao bat ky file `.py` hoac `.ts` moi, bat buoc tra loi du 5 cau hoi sau:

- [ ] **1. File nay chua loai code gi?** (endpoint / schema / service / agent / util / config)
- [ ] **2. Theo bang Rule 4, no thuoc thu muc nao?** Dat vao dung thu muc do.
- [ ] **3. Da co file tuong tu trong thu muc do chua?** Neu co, xem xet mo rong file cu thay vi tao file moi.
- [ ] **4. Ten file co mo ta ro chuc nang khong?** Tuyet doi khong dat ten chung chung nhu `helper.py`, `misc.py`, `utils2.py`.
- [ ] **5. File nay co vi pham Rule Import khong?** Kiem tra huong import truoc khi viet code.