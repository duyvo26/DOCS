# Skill: DuyVo26 — Cấu trúc Dự án Tiêu chuẩn & Hướng dẫn Phát triển

## Mục tiêu

Quy định cấu trúc thư mục chuẩn và các nguyên tắc phát triển bắt buộc áp dụng cho mọi dự án tích hợp AI (FastAPI + AI Engine + Frontend). Giúp AI Agent và lập trình viên dễ dàng định vị mã nguồn, hiểu rõ kiến trúc, và tuân thủ các luồng xử lý kỹ thuật đã được đóng gói thành "Skill".

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
├── utils/                      # [STORAGE] Thư mục lưu trữ tập trung
│   ├── download/               # File export, logo, favicon...
│   ├── upload_temp/            # File tải lên đang chờ xử lý
│   ├── data_vector/            # Nơi lưu trữ FAISS Index thực tế
│   └── logs/                   # File log ứng dụng (xem skill_logging_monitoring.md)
├── test/                       # Unit tests (pytest, vitest)
├── deploy/                     # Cấu hình deploy (nginx.conf, systemd service)
├── .env                        # Biến môi trường (KHÔNG push lên Git)
├── .env.example                # File mẫu biến môi trường (push lên Git)
├── .gitignore                  # Quy tắc bỏ qua file nhạy cảm (xem skill_env_configuration.md)
└── requirements.txt            # Danh sách thư viện Python
```

---

## 2. Bảng tra cứu Kỹ thuật (Skill Directory)

Các luồng xử lý nghiệp vụ phức tạp đã được đúc kết thành các tài liệu "Skill". Lập trình viên và AI **PHẢI** tham chiếu các file này trước khi code tính năng tương ứng.

### Nhóm AI & RAG (Trí tuệ Nhân tạo)
*   [**Kỹ thuật AI RAG Workflow (Standard)**](./skill_ai_rag_workflow.md): Cấu trúc luồng đồ thị LangGraph, định tuyến câu hỏi, bộ lọc tài liệu và quản lý chi phí token.
*   [**Kiến trúc Module Chatbot & LLM**](./skill_chatbot_architecture.md): Quy định chuẩn hóa thư mục, cách khởi tạo LLM, quản lý Prompt và xây dựng Agent.
*   [**Kết nối OpenRouter (Đa nền tảng AI)**](./skill_openrouter_integration.md): Hướng dẫn tích hợp OpenRouter để dùng nhiều model AI (GPT, Claude, Gemini, Llama...) qua 1 API key duy nhất, cấu hình toggle trong Settings.
*   [**Kỹ thuật Parser (DOCX to MD)**](./skill_docx_to_md_parser.md): Quy trình chuyển đổi báo cáo phức tạp thành cấu trúc Markdown theo Headings để nạp vào AI.

### Nhóm Xác thực, Môi trường & Bảo mật
*   [**Cấu hình Môi trường (.env & .gitignore)**](./skill_env_configuration.md): Chuẩn file `.env`, đầy đủ mẫu `.gitignore`, quy tắc `.env.example` và Pydantic Settings.
*   [**Viết SQL Đa nền tảng (MySQL & SQLite)**](./skill_sql_compatibility.md): Kỹ thuật dùng Raw SQL tương thích đa driver, chống SQL Injection bằng Parameter Binding.
*   [**Quản lý Thư viện (Dependencies)**](./skill_dependencies_management.md): Danh sách package (FastAPI, LangGraph, JWT, zustand, zod...) cần cài đặt để chạy các Skill.
*   [**Xác thực và Bảo mật Toàn diện**](./skill_security_authentication.md): JWT Stateless, bcrypt hash mật khẩu, RBAC Admin, chống Path Traversal, và Frontend Security checklist.
*   [**Đăng nhập Google OAuth (Redirect Flow)**](./skill_google_oauth_redirect.md): Luồng đăng nhập mượt mà qua Backend Redirect, không làm lộ JSON thô.
*   [**Đăng nhập Hybrid App (Cloud-Sync Polling)**](./skill_hybrid_app_login.md): Giải pháp đăng nhập cho App Mobile (Flutter/React Native) sử dụng WebView kết hợp Polling DB.

### Nhóm Tác vụ & Thanh toán
*   [**Tác vụ Bất đồng bộ & Polling**](./skill_async_task_polling.md): Cơ chế Background Tasks của FastAPI kết hợp Polling phía Frontend để xử lý tác vụ AI nặng.
*   [**Hệ thống Thanh toán Tự động (Polling & Sync)**](./skill_payment_polling_sync.md): Thuật toán đối soát giao dịch ngân hàng qua SePay tự động không cần Webhook.

### Nhóm Tối ưu Frontend & Giao diện
*   [**Kiến trúc Frontend & API Setup**](./skill_frontend_architecture.md): Quản lý API tập trung (`api.ts`), JWT Interceptor, button loading state, và bảo mật JWT phía Frontend.
*   [**Chia nhỏ Components, Pages & Domain Routing**](./skill_frontend_routing_components.md): Kiến trúc domain-based với React Router v6, lazy loading, ProtectedRoute/AdminRoute, nguyên tắc tách component.
*   [**Quản lý SEO Động (Dynamic SEO)**](./skill_dynamic_seo_manager.md): Kỹ thuật thay thế trực tiếp Meta Tag trong file tĩnh `index.html` của React giúp chia sẻ link hiệu quả.

### Nhóm Quy tắc Viết Code & Tài liệu
*   [**Tiêu chuẩn Viết Code & Đặt tên (Coding Conventions)**](./skill_coding_conventions.md): Đặt tên, Type Hinting, Docstring, cấm emoji, và Git Workflow (Conventional Commits, branching strategy).
*   [**Quy tắc Thực thi Bắt buộc (Execution Rules)**](./skill_execution_rules.md): 8 quy tắc cứng về Router, Service, Import, File Splitting, OOP — không được vi phạm.
*   [**Hướng dẫn Viết README.md Chuẩn**](./skill_readme_writing.md): Cấu trúc 7 phần bắt buộc, mẫu README đầy đủ, quy tắc `.env.example`, checklist trước khi commit.
*   [**Logging & Monitoring Chuẩn**](./skill_logging_monitoring.md): Cấu hình Python logging có cấu trúc, RotatingFileHandler, quy tắc log level, cấm dùng `print()` trong production.
*   [**Chuẩn API Response (Standard Response Format)**](./skill_api_response_standard.md): JSON thống nhất cho mọi Endpoint: ApiSuccess, ApiError, PaginatedData, Global Exception Handler.
*   [**Codebase Mapper (Map.md)**](./skill_codebase_mapper.md): Phân tích codebase, tạo Header Documentation, duy trì file `map.md` để điều hướng AI.

---

## 3. Nguyên tắc phát triển cốt lõi (Core Principles)

1. **Tuân thủ Cấu trúc Modular**: Tuyệt đối không code logic AI (LangChain/LangGraph) vào trong các file `router` của FastAPI. Backend API (`app/`) chỉ nhận request và gọi các hàm xử lý bên trong module `chatbot/` hoặc `ingestion/`.
2. **Chatbot Module Chuyên biệt**: Thư mục `chatbot/` chỉ được phép chứa code liên quan đến AI, LLM, Prompts và Agents. KHÔNG để code nạp dữ liệu (Ingestion), Database model, hay logic nghiệp vụ thông thường vào đây.
3. **Khôi phục trạng thái (Resilience)**: Mọi tác vụ nặng phải có cơ chế Polling. Người dùng F5 (tải lại trang) không được làm gián đoạn tiến trình. (Xem `skill_async_task_polling.md`).
4. **An toàn Bí mật (Secrets)**: Các API Key (OpenAI, Gemini, SePay) và Secret Key (JWT) luôn đặt ở `.env` Backend. Dùng `.env.example` để commit mẫu lên Git. KHÔNG bao giờ commit file `.env` thật. (Xem `skill_env_configuration.md`).
5. **Phản hồi Rõ ràng**: Mọi Endpoint giao tiếp với Frontend phải trả về JSON định dạng chuẩn `ApiSuccess` / `ApiError`. (Xem `skill_api_response_standard.md`).
6. **Logging thay vì Print**: Mọi file module phải khai báo `logger = get_logger(__name__)`. Cấm tuyệt đối dùng `print()` trong code production. (Xem `skill_logging_monitoring.md`).
7. **Comment giải thích**: Mọi hàm phức tạp phải có Docstring (Python) hoặc JSDoc (TypeScript). Comment phải trả lời "Tại sao viết thế này?" chứ không phải "Code này làm gì?". (Xem `skill_coding_conventions.md`).
8. **Cấm Emoji**: Không dùng emoji trong bất kỳ file code, markdown, hay comment nào. (Xem `skill_coding_conventions.md`).
9. **File Header & Docstring Bắt buộc**: Mọi file mới hoặc sửa phải có Header mô tả và Docstring cho từng hàm. (Xem Mục 6 bên dưới).
10. **Hướng Đối tượng & Chia nhỏ File**: Code phải viết theo OOP, mỗi class một file riêng. File > 300 dòng BẮT BUỘC tách. (Xem `skill_execution_rules.md` Rule 8).

---

## 4. Hướng dẫn Môi trường & Quản lý File

1. **Môi trường ảo (Virtual Environment)**:
   - Tất cả các dự án Python bắt buộc phải chạy trong môi trường ảo (Virtual Env) để tránh xung đột thư viện với hệ thống.
   - Luôn khởi tạo môi trường bằng lệnh: `python -m venv .venv`
   - Nhớ kích hoạt `.venv` (ví dụ: `source .venv/bin/activate` hoặc `.venv\Scripts\activate`) và cài đặt thư viện qua `pip install -r requirements.txt` trước khi lập trình hoặc chạy app.

2. **Xác định Thư mục Gốc (Root Directory) qua `.env`**:
   - Hệ thống không sử dụng đường dẫn tương đối (kiểu `../../`) vốn rất dễ gây lỗi khi đổi thư mục chạy script.
   - Thay vào đó, trong file `app/config.py`, hệ thống sẽ tự động tìm kiếm vị trí của file `.env`. Thư mục chứa file `.env` sẽ được định nghĩa là **`DIR_ROOT`** (Thư mục gốc tuyệt đối). Mọi thao tác đọc/ghi file trong dự án đều phải dựa trên `DIR_ROOT` này.

3. **OpenRouter — Đa nền tảng AI**:
   - Hệ thống hỗ trợ chuyển đổi linh hoạt giữa **OpenAI** và **OpenRouter** qua toggle trong Settings.
   - Khi bật OpenRouter, `LlmFactory.get_llm()` dùng `base_url="https://openrouter.ai/api/v1"` và model do người dùng chọn.
   - Có thể cấu hình qua Settings UI hoặc biến môi trường trong `.env`:
     ```env
     OPENROUTER_API_KEY=sk-or-...
     OPENROUTER_MODEL=openai/gpt-oss-120b:free
     ```

4. **Quy hoạch Thư mục Lưu trữ (`utils/`)**:
   - Thư mục `utils/` nằm ở ngoài cùng (Root level) được dùng làm không gian lưu trữ vật lý tập trung của dự án.
   - Nơi đây chứa các file do người dùng tải lên (`utils/upload_temp`), các file kết xuất/tải về (`utils/download`), cũng như hệ thống cơ sở dữ liệu Vector cục bộ (`utils/data_vector`).
   - Việc quy hoạch tập trung giúp code sạch hơn và cực kỳ thuận tiện khi cần Backup dữ liệu hoặc thiết lập Mount Volume khi deploy bằng Docker.

---

## 5. Docstring & File Header Bắt buộc

Quy tắc này áp dụng cho **cả Backend (Python) và Frontend (TypeScript/React)**.

### 5.1. File Header — Mọi file phải có Header mô tả

Mọi file `.py`, `.ts`, `.tsx` **mới tạo hoặc sửa** PHẢI có Header block ở đầu file.

**Định dạng chung:**
```
File: tên_file.xxx
Chức năng: Mô tả chức năng chính của file này
Vai trò: Mô tả vai trò trong hệ thống (VD: router / service / agent / component / util / config)
File liên quan: (nếu có) danh sách file khác tương tác với file này
```

**Ví dụ Backend (Python):**
```python
"""
File: chat_router.py
Chức năng: Định nghĩa endpoint API cho module chat, tiếp nhận request và gọi service
Vai trò: Router — tiếp nhận request từ Frontend, validate, dispatch xuống chatbot service
File liên quan: chatbot/services/chat_service.py, app/schemas/chat_schema.py
"""
```

```python
"""
File: rag_chat_service.py
Chức năng: Workflow LangGraph cho luồng hỏi đáp RAG, điều phối các agent
Vai trò: Service — chứa toàn bộ logic AI, gọi các agent trong chatbot/utils/
File liên quan: chatbot/utils/document_grader_agent.py, chatbot/utils/llm.py, ingestion/retriever.py
"""
```

**Ví dụ Frontend (TypeScript/React):**
```typescript
/**
 * File: ChatPage.tsx
 * Chức năng: Trang chat chính, hiển thị lịch sử hỏi đáp và form nhập tin nhắn
 * Vai trò: Page component — quản lý state tin nhắn, phối hợp các component con
 * File liên quan: components/ChatHistory.tsx, components/ChatInput.tsx, services/api.ts
 */
```

```typescript
/**
 * File: api.ts
 * Chức năng: Axios instance, interceptor JWT, và tất cả hàm gọi API
 * Vai trò: Service — tập trung mọi API call, xử lý lỗi 401 toàn cục
 * File liên quan: contexts/AuthContext.tsx, domains/*/router.tsx
 */
```

### 5.2. Docstring (Python) / JSDoc (TypeScript) — Mọi hàm bắt buộc phải có

**Quy tắc:** Mọi **hàm mới** hoặc **hàm được sửa** PHẢI có docstring. Đây là quy tắc **cứng**, không phải đề xuất.

**AI khi vào chỉnh code:** Nếu phát hiện hàm thiếu docstring, AI PHẢI tự động thêm docstring đầy đủ.

Docstring phải bao gồm:
- Mô tả chức năng chính của hàm
- **Giải thích logic code**: các dòng code chính làm gì, tại sao làm thế
- **Giải thích call hàm**: mỗi hàm con được gọi có chức năng gì, trả về gì
- Args, Returns, Raises

**Python — Google Style Docstring (kèm giải thích logic):**
```python
def process_chat_message(user_id: int, message: str, session_id: str) -> dict:
    """
    Xử lý tin nhắn chat qua luồng RAG: retrieve -> grade -> generate.
    Dùng LangGraph StateGraph để quản lý trạng thái qua các node.

    Logic:
      - Bước 1: Gọi retrieve_node() để truy vấn FAISS, lấy top-K tài liệu
      - Bước 2: Gọi grade_node() để lọc tài liệu không liên quan
      - Bước 3: Gọi generate_node() để LLM sinh câu trả lời từ tài liệu đã lọc
      - Bước 4: Gọi update_usage() để trừ token của user

    Args:
        user_id (int): ID người dùng, dùng để kiểm tra balance và log
        message (str): Câu hỏi của người dùng, được gửi vào LLM
        session_id (str): Mã phiên chat, dùng để truy vấn lịch sử

    Returns:
        dict: { "answer": str, "sources": list, "credits": float }
              - answer: câu trả lời từ AI
              - sources: danh sách tài liệu nguồn được dùng
              - credits: số token đã tiêu thụ

    Raises:
        ValueError: Nếu message rỗng hoặc user không đủ balance
    """
    if not message.strip():
        raise ValueError("Tin nhắn không được để trống")
    # retrieve_node: gọi FAISS search, trả về List[Document]
    docs = retrieve_node(question=message, top_k=5)
    # grade_node: lọc docs, giữ lại docs có score > 0.7
    relevant_docs = grade_node(question=message, documents=docs)
    # generate_node: LLM sinh câu trả lời từ relevant_docs
    answer = generate_node(question=message, documents=relevant_docs)
    # update_usage: trừ credit, ghi log
    update_usage(user_id=user_id, tokens_used=count_tokens(message))
    return {"answer": answer, "sources": relevant_docs, "credits": 12.5}
```

**TypeScript — JSDoc (kèm giải thích logic):**
```typescript
/**
 * Xử lý gửi tin nhắn chat lên API và cập nhật UI.
 * Gọi chatbotApi.sendMessage(), sau đó append tin nhắn vào danh sách.
 * Nếu lỗi, hiển thị toast thay vì làm treo UI.
 *
 * Logic:
 *   - Gọi chatbotApi.sendMessage() để gửi câu hỏi lên backend
 *   - API trả về { answer, sources } -> tạo message object mới
 *   - setMessages() append vào state -> UI tự render
 *   - Nếu lỗi 401 -> Interceptor tự redirect login
 *   - Nếu lỗi khác -> showToast() hiển thị lỗi cho người dùng
 *
 * @param {string} question - Câu hỏi người dùng nhập vào
 * @returns {Promise<void>} Không trả về, state tự cập nhật
 */
const handleSendMessage = async (question: string): Promise<void> => {
    if (isLoading) return;
    setIsLoading(true);
    try {
        // Gọi API backend, nhận câu trả lời kèm nguồn tài liệu
        const res = await chatbotApi.sendMessage(question);
        // Tạo object message để thêm vào mảng state
        const newMsg = { id: Date.now(), role: 'assistant', content: res.answer };
        setMessages(prev => [...prev, newMsg]); // Append vào danh sách
    } catch (error) {
        // showToast lấy message từ ApiError, fallback nếu không có
        showToast(error?.response?.data?.message ?? 'Có lỗi xảy ra', 'error');
    } finally {
        setIsLoading(false); // Luôn mở khoá nút bấm
    }
};
```

**TypeScript — JSDoc:**
```typescript
/**
 * Mô tả 1-2 câu về chức năng chính của hàm.
 *
 * @param {type} paramName - Mô tả tham số
 * @returns {type} Mô tả dữ liệu trả về
 */
function functionName(paramName: Type): ReturnType {
    // code
}
```

### 5.3. Checklist trước khi Commit

- [ ] **File Header**: File mới có Header block ở dòng đầu tiên không?
- [ ] **Hàm mới**: Mọi hàm mới có docstring/JSDoc không?
- [ ] **Hàm sửa**: Hàm được sửa có cập nhật lại docstring không?
- [ ] **Giải thích "Why"**: Docstring có giải thích "Tại sao làm thế này" thay vì "Code làm gì" không?

---

## 6. Hướng dẫn Khởi chạy theo Loại Dự án

### 6.1. Backend — Python (FastAPI + AI Engine)

**Khởi tạo môi trường:**
```bash
python -m venv .venv
# Kích hoạt:
# Windows:
.venv\Scripts\activate
# Linux/Mac:
source .venv/bin/activate
```

**Cài đặt thư viện:**
```bash
pip install -r requirements.txt
```

**Chạy server:**
```bash
uvicorn app.main:app --reload
```

**Khi cần thêm module AI:**

| Module | Tạo folder | Mục đích |
|--------|-----------|----------|
| Chatbot AI | `chatbot/` | Logic AI, LLM, LangGraph, Agent |
| Data Pipeline | `ingestion/` | Nạp dữ liệu, chunking, FAISS index |
| Đánh giá AI | `scoring/` | (Tùy chọn) Chấm điểm RAG, test AI |

Quy tắc: Không để code AI vào `app/`. Luôn đặt trong `chatbot/`.

**Chạy test:**
```bash
pytest test/
```

---

### 6.2. Frontend

Phần này liệt kê các loại Frontend hiện có và sẽ có. Mỗi loại có cấu trúc thư mục và cách chạy riêng.

#### 6.2.1. React / Vite / TypeScript

**Khởi tạo (dự án Python + Frontend):**
```bash
npm create vite@latest frontend -- --template react-ts
cd frontend
npm install
```

Cấu trúc sau khi tạo:
```
project_root/
├── app/               # Backend FastAPI
├── chatbot/           # AI Engine
├── frontend/          # Vite + React + TypeScript
└── ...
```

**Khởi tạo (dự án thuần Frontend):**
```bash
npm create vite@latest . -- --template react-ts
npm install
```

**Các lệnh thường dùng:**

| Mục đích | Lệnh |
|----------|------|
| Cài đặt | `npm install` |
| Chạy dev | `npm run dev` |
| Build | `npm run build` |
| Test | `npx vitest` |
| Lint | `npm run lint` |

**Thêm domain mới:**
```bash
# Tạo folder domain:
frontend/src/domains/{tên_domain}/
# VD:
frontend/src/domains/payment/   # router, pages, components
frontend/src/domains/admin/     # router, pages, components
```

**Cấu trúc thư mục:**
```text
frontend/src/
├── router/index.tsx        # Root Router
├── components/             # Shared UI
├── domains/{tên}/          # Domain độc lập
│   ├── router.tsx
│   ├── pages/
│   └── components/
├── hooks/
├── services/api.ts         # API calls
├── contexts/               # AuthContext...
└── types/
```

> Xem chi tiết: [Kiến trúc Frontend & API Setup](./skill_frontend_architecture.md), [Chia nhỏ Components & Domain Routing](./skill_frontend_routing_components.md)

#### 6.2.2. Laravel Blade (tương lai)

*Chưa có hướng dẫn chi tiết. Cấu trúc dự kiến:*

```text
project_root/
├── app/               # Backend FastAPI
├── frontend/          # Laravel + Blade
│   ├── resources/
│   │   ├── views/     # Blade templates
│   │   ├── css/
│   │   └── js/
│   ├── routes/
│   └── public/
└── ...
```

> *Khi có dự án Laravel thực tế, sẽ cập nhật hướng dẫn đầy đủ.*

#### 6.2.3. Các loại Frontend khác

Mỗi loại Frontend mới sẽ được thêm mục riêng tại đây, kèm cấu trúc thư mục và lệnh chạy tương ứng.

---

### 6.3. Quy tắc Tạo Folder Mới

1. **Kiểm tra trước**: Tra bảng Rule 4 trong `skill_execution_rules.md` xem folder đã tồn tại chưa
2. **Không tên chung chung**: Không đặt `helpers/`, `misc/`, `utils2/`, `lib/`
3. **Đặt tên có ý nghĩa**: Dùng snake_case cho Python, kebab-case cho frontend folders
4. **Chỉ tạo khi thật sự cần**: Nếu 1-2 file thì đặt vào `utils/` hiện có
5. **Cập nhật map.md**: Nếu dùng skill Codebase Mapper, cập nhật lại map.md

---

## 7. Quy tắc AI Response (AI Communication Rules)

AI (ChatGPT, Claude, etc.) khi làm việc với dự án này PHẢI tuân thủ:

1. **Không giải thích dài dòng**: Chỉ trả lời đúng trọng tâm, không thêm giải thích nếu người dùng không yêu cầu.
2. **Code = code**: Khi viết code, chỉ trả về code + đường dẫn file. Không kèm giải thích "Code này làm gì".
3. **Báo kết quả tối thiểu**: Khi hoàn thành task, báo "Done" + tóm tắt 1-2 dòng. Không liệt kê từng bước đã làm.
4. **Hỏi lại nếu cần**: Nếu thiếu thông tin, hỏi lại câu hỏi cần thiết thay vì tự ý quyết định.
5. **Không viết README/doc nếu không được yêu cầu**: Chỉ tạo tài liệu khi người dùng yêu cầu rõ ràng.
6. **KHÔNG tự ý run code**: Không chạy file `.py`, `npm install`, `npm run build`, `uvicorn`, hay bất kỳ lệnh nào khác nếu không được yêu cầu. Code là của client, chỉ chạy khi client nói "chạy thử" hoặc "test".
7. **KHÔNG tự ý cài đặt package**: Không tự ý thêm package vào `requirements.txt` hay `package.json` nếu không được yêu cầu.
8. **Chỉ sửa code, không chạy**: Nhiệm vụ chính là viết/sửa code đầy đủ. Client sẽ tự chạy và kiểm tra.

10. **Khi vào chỉnh/sửa code, KIỂM TRA và THÊM DOCSTRING**: Nếu AI được yêu cầu sửa một file, trước khi chỉnh code PHẢI rà soát toàn bộ file:
    - Hàm nào thiếu docstring/JSDoc → thêm ngay (kể cả hàm không liên quan đến phần đang sửa).
    - Hàm nào có docstring sẵn nhưng chưa giải thích logic → bổ sung giải thích các dòng code chính, các hàm con được gọi.
    - Không skip hàm nào, kể cả hàm nhỏ.
9. **Khi người dùng yêu cầu "chuẩn hoá code"**: BẮT BUỘC phải:
   - Tạo file `map.md` trong thư mục gốc dự án nếu chưa có.
   - Folder `{tên_dự_án}/` (do người dùng tạo tay) chứa các file `map_{tên_dự_án}.md` để tham khảo cấu trúc. Chỉ cần ghi chú trong file map.md dẫn đến folder này.
   - VD: folder `chatbot-luat/` chứa `map_chatbot-luat.md`
   - Nội dung file map: liệt kê các file quan trọng, chức năng, vai trò, file liên quan (xem `skill_codebase_mapper.md`).

---

## File liên quan

- [Quy tắc Thực thi Bắt buộc (Execution Rules)](./skill_execution_rules.md)
- [Tiêu chuẩn Viết Code (Coding Conventions)](./skill_coding_conventions.md)
- [Kiến trúc Chatbot & LLM](./skill_chatbot_architecture.md)
- [Codebase Mapper](./skill_codebase_mapper.md)
- [Cấu hình Môi trường (.env)](./skill_env_configuration.md)
- [Chuẩn API Response](./skill_api_response_standard.md)
