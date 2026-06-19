# Skill: Quy tắc Thực thi Bắt buộc (Execution Rules)

## Mục tiêu

Bộ quy tắc **KHÔNG ĐƯỢC VI PHẠM**. Ngăn chặn việc tạo file và thư mục sai vị trí, gây ra tình trạng code bị phân tán, khó bảo trì và vi phạm kiến trúc đã quy định.

---

## Rule 1: Router KHÔNG chứa Business Logic

**Định nghĩa:** File trong `app/routers/` chỉ được phép làm đúng 3 việc:
1. Nhận và validate request (dùng Pydantic schema)
2. Gọi hàm xử lý từ `service` tương ứng
3. Trả về response theo chuẩn `ApiSuccess` / `ApiError`

**Ví dụ ĐÚNG:**

```python
# app/routers/chat_router.py
from fastapi import APIRouter, Depends
from app.models.chat_schema import ChatRequest
from chatbot.services.chat_service import run_chat_flow
from app.utils.response import ApiSuccess, ApiError

router = APIRouter()

@router.post("/chat")
async def chat_endpoint(req: ChatRequest, user=Depends(get_current_user)):
    # Chỉ gọi service, không xử lý gì thêm
    result = await run_chat_flow(user_id=user.id, message=req.message)
    return ApiSuccess(data=result)
```

**Ví dụ SAI — TUYỆT ĐỐI CẤM:**

```python
# app/routers/chat_router.py  <-- SAI: LangChain nằm trong router
from langchain_openai import ChatOpenAI
from langgraph.graph import StateGraph

@router.post("/chat")
async def chat_endpoint(req: ChatRequest):
    llm = ChatOpenAI(model="gpt-4o")   # CẤM: khởi tạo LLM trong router
    chain = llm | StrOutputParser()     # CẤM: định nghĩa chain trong router
    result = chain.invoke(req.message)  # CẤM: gọi LangChain trực tiếp
    return {"result": result}
```

---

## Rule 2: AI Logic Bắt buộc Nằm Trong `chatbot/services/`

**Định nghĩa:** Mọi logic liên quan đến LangChain, LangGraph, Prompt, RAG, Agent đều phải đặt trong thư mục `chatbot/services/`.

**Quy tắc đặt tên file trong `chatbot/services/`:**
- Dùng snake_case, tên mô tả rõ chức năng của workflow
- Định dạng khuyến nghị: `{chủ_đề}_{kiểu_xử_lý}_service.py`
- Ví dụ hợp lệ: `rag_chat_service.py`, `document_qa_service.py`, `multi_agent_service.py`
- **CẤM** đặt tên chung chung: `handler.py`, `logic.py`, `ai.py`, `process.py`

**Quy tắc đặt tên file trong `chatbot/utils/`:**
- Mỗi file là 1 Agent nhỏ có chức năng đơn lẻ (Single Responsibility)
- Định dạng khuyến nghị: `{chức_năng}_agent.py` hoặc `{chức_năng}_util.py`
- **prompt.py**: File đặc biệt chứa Class tập trung quản lý tất cả Prompt (System Prompt, Templates)
- Ví dụ hợp lệ: `document_grader_agent.py`, `prompt.py`, `answer_generator_agent.py`
- **CẤM** gộp nhiều agent khác nhau vào 1 file

---

## Rule 3: Luồng Xử lý API Chatbot Bắt buộc Theo Thứ Tự

Mọi API endpoint liên quan đến AI PHẢI tuân thủ luồng sau:

```
[Frontend Request]
      |
      v
[app/routers/]          --> Chỉ validate & dispatch
      |
      v
[chatbot/services/]     --> Chứa toàn bộ business logic, gọi các agent
      |
      v
[chatbot/utils/]        --> Các agent đơn lẻ: grade, generate, validate
      |
      v
[Response trả về router] --> Router đóng gói ApiSuccess/ApiError
```

**CẤM các lối đi tắt sau:**

| Lỗi vi phạm | Dùng thay thế |
|---|---|
| Gọi LangChain trực tiếp trong `app/routers/` | Tạo hàm trong `chatbot/services/` và gọi từ router |
| Viết logic xử lý trong app/models/ | `app/models/` chỉ chứa SQLAlchemy model, `app/schemas/` chứa Pydantic schema |
| Đặt file `*_agent.py` trong `app/utils/` | Agent AI phải ở `chatbot/utils/`, không phải `app/utils/` |
| Import `chatbot/` trong `ingestion/` | `ingestion/` là pipeline độc lập, không phụ thuộc `chatbot/` |

---

## Rule 4: Bảng Phân Công File — Đặt Code Ở Đâu?

Sử dụng bảng này mỗi khi cần quyết định đặt 1 đoạn code vào file nào:

| Loại code cần viết | Đặt vào file nào |
|---|---|
| Endpoint API, route definition | `app/routers/{module}_router.py` |
| Pydantic request/response schema | `app/schemas/{module}_schema.py` |
| SQLAlchemy model (DB Table) | `app/models/{module}_model.py` |
| Database Connection (Session) | `app/database.py` |
| JWT, password hash, permission check | `app/security/` |
| Hàm tiện ích dùng chung cho API (format date, parse string...) | `app/utils/` |
| Toàn bộ workflow LangGraph/LangChain | `chatbot/services/{tên}_service.py` |
| Agent nhỏ: grader, generator, validator | `chatbot/utils/{tên}_agent.py` |
| Prompt Templates (System, Tool) | `chatbot/utils/prompt.py` (dùng Class để quản lý) |
| Khởi tạo LLM (Factory) — hỗ trợ OpenAI & OpenRouter | `chatbot/utils/llm.py` |
| Cấu hình OpenRouter (toggle, key, model) | `app/routers/settings_router.py` + `frontend/components/Settings.tsx` |
| LangGraph State Definition | `chatbot/utils/graph_state.py` |
| Kết nối và truy vấn FAISS | `ingestion/retriever.py` |
| Xây dựng / cập nhật Vector DB | `ingestion/vector_data_builder.py` |
| Logic chia chunk đặc thù theo domain | `ingestion/rag_multi_class_ingest.py` |
| Global config, biến môi trường | `app/config.py` (load từ `.env`) |
| File log output | `utils/logs/` (KHÔNG tạo folder `logs/` nơi khác) |
| File upload tạm thời từ người dùng | `utils/upload_temp/` |
| File export, báo cáo, favicon | `utils/download/` |
| FAISS index, embedding data | `utils/data_vector/` |
| Unit test cho backend | `test/` (dùng pytest) |
| Unit test cho frontend | `frontend/src/__tests__/` (dùng vitest) |

---

## Rule 5: Quy tắc Không Tạo Thư Mục Ngoài Cấu Trúc Chuẩn

**CẤM** tạo các thư mục sau đây ở bất kỳ cấp nào (trừ khi có lý do đặc biệt và được trao đổi trước):

- `helpers/` — thay bằng `utils/` đã có trong chuẩn
- `controllers/` — FastAPI không dùng MVC kiểu này, dùng `routers/` + `services/`
- `middleware/` thành thư mục riêng — middleware khai báo trong `app/main.py`
- `constants/` — hằng số đặt trong `app/config.py` hoặc file schema tương ứng
- `lib/` — không có ý nghĩa rõ ràng, thay bằng tên mục đích cụ thể
- `src/` tại root level — `src/` chỉ tồn tại bên trong `frontend/`
- `api/` tại root level — thư mục API là `app/routers/`, không tạo thêm `api/`

**Khi thật sự cần thêm thư mục mới:**
1. Xem lại Section 1 của `skill_project_structure.md` để kiểm tra liệu thư mục đã tồn tại hay chưa
2. Nếu không có thư mục phù hợp, đặt code vào `app/utils/` (cho API helper) hoặc `chatbot/utils/` (cho AI helper)
3. Chỉ tạo thư mục mới khi chức năng thực sự độc lập và không thể gộp vào đâu hiện có

---

## Rule 6: Quy tắc Import — Hướng Đi Một Chiều

Để tránh circular import và giữ kiến trúc rõ ràng, các module PHẢI tuân thủ hướng import một chiều:

```
app/routers/ --> chatbot/services/ --> chatbot/utils/
     |                |                     |
     v                v                     v
app/schemas/     app/models/         ingestion/retriever.py
     |                |
     v                v
app/security/    app/database.py
```

**CẤM ngược chiều:**
- `chatbot/` KHÔNG được import từ `app/routers/`
- `ingestion/` KHÔNG được import từ `chatbot/services/`
- `app/models/` KHÔNG được import từ `app/routers/` theo kiểu vòng tròn
- `app/utils/` KHÔNG được import từ `chatbot/` (util API khác util AI)

**Hàm dùng chung thực sự** (ví dụ: hàm đọc file, format date) có thể đặt vào `app/utils/` và được import từ cả `app/` lẫn `chatbot/` — đây là trường hợp ngoại lệ hợp lệ duy nhất.

---

## Rule 7: Checklist Trước Khi Tạo File Mới

Trước khi tạo bất kỳ file `.py` hoặc `.ts` mới, bắt buộc trả lời đủ 5 câu hỏi sau:

- [ ] **1. File này chứa loại code gì?** (endpoint / schema / service / agent / util / config)
- [ ] **2. Theo bảng Rule 4, nó thuộc thư mục nào?** Đặt vào đúng thư mục đó.
- [ ] **3. Đã có file tương tự trong thư mục đó chưa?** Nếu có, xem xét mở rộng file cũ thay vì tạo file mới.
- [ ] **4. Tên file có mô tả rõ chức năng không?** Tuyệt đối không đặt tên chung chung như `helper.py`, `misc.py`, `utils2.py`.
- [ ] **5. File này có vi phạm Rule Import không?** Kiểm tra hướng import trước khi viết code.

---

## Rule 8: Hướng Đối tượng & Chia nhỏ File (OOP & File Splitting)

**Nguyên tắc này áp dụng cho CẢ Backend (Python) và Frontend (TypeScript/React).**

Code PHẢI được viết theo hướng đối tượng (OOP). Mỗi class, module, file chỉ đảm nhiệm **một trách nhiệm duy nhất** (Single Responsibility). Nghiêm cấm gộp code cả ngàn dòng trong 1 file.

**Đúng:**
```
# Backend — mỗi class 1 file riêng
chatbot/utils/document_grader_agent.py   (~60 dòng)
chatbot/utils/answer_generator_agent.py  (~70 dòng)
chatbot/utils/query_transformer.py       (~50 dòng)

# Frontend — mỗi page/component 1 file riêng
domains/chat/pages/ChatPage.tsx           (~80 dòng)
domains/chat/components/MessageBubble.tsx (~40 dòng)
domains/chat/components/ChatInput.tsx     (~60 dòng)
domains/chat/components/ChatHistory.tsx   (~50 dòng)
```

**Sai (KHÔNG được phép):**
```
# Backend
chatbot/utils/all_in_one.py              (~800 dòng, nhiều class trộn lẫn)

# Frontend
domains/chat/pages/ChatPage.tsx          (~500 dòng, render + state + API + UI tất cả trong 1 file)
domains/chat/ChatFeature.tsx             (~600 dòng, page + component + logic không tách)
```

**Giới hạn file:**

| Loại file | Tối đa dòng | Áp dụng cho | Ghi chú |
|-----------|-------------|-------------|---------|
| Agent / Util nhỏ | 100 dòng | Backend | Một class, một chức năng |
| Service / Workflow | 200 dòng | Backend | Một luồng LangGraph |
| Router (API) | 150 dòng | Backend | Chỉ validate + dispatch |
| Page component | 150 dòng | Frontend | Nếu quá, tách component con |
| Component thường | 80 dòng | Frontend | Một component, một vai trò |
| Utility / Helper | 100 dòng | Cả hai | Hàm tiện ích đơn lẻ |

**Khi nào cần tách file:**
- File > 150 dòng: cân nhắc tách
- File > 300 dòng: BẮT BUỘC tách
- Một class > 200 dòng: cân nhắc tách thành nhiều class
- Một hàm > 50 dòng: cân nhắc tách thành nhiều hàm nhỏ
- Một component > 80 dòng: cân nhắc tách component con
- Page > 150 dòng: tách thành nhiều components + pages nhỏ hơn

**Ví dụ tách Backend (Python):**

```python
# SAI: 1 file làm hết
# chatbot/utils/ai_utils.py (~600 dòng)
class DocumentGrader: ...
class AnswerGenerator: ...
class QueryTransformer: ...
class PromptManager: ...

# ĐÚNG: Mỗi class 1 file riêng
# chatbot/utils/document_grader_agent.py (~60 dòng)
class DocumentGrader:
    """Agent kiểm tra độ liên quan của tài liệu với câu hỏi."""

# chatbot/utils/answer_generator_agent.py (~70 dòng)
class AnswerGenerator:
    """Agent sinh câu trả lời từ tài liệu đã lọc."""

# chatbot/utils/query_transformer.py (~50 dòng)
class QueryTransformer:
    """Biến đổi câu hỏi người dùng thành nhiều câu truy vấn."""
```

**Ví dụ tách Frontend (TypeScript/React):**

```tsx
// SAI: Tất cả trong 1 Page file (~500 dòng)
// frontend/src/domains/chat/pages/ChatPage.tsx
// Gồm: state management + API call + render history + input form + header
const ChatPage = () => {
    // 50 dòng state
    // 80 dòng API calls
    // 120 dòng render messages
    // 60 dòng render input
    // 40 dòng render header
    // ... ~500 dòng
};

// ĐÚNG: Tách thành nhiều components, mỗi file khoảng 40-80 dòng
// frontend/src/domains/chat/pages/ChatPage.tsx (~80 dòng)
// Chỉ phối hợp các component con, quản lý state tổng thể
import ChatHeader from '../components/ChatHeader';
import ChatHistory from '../components/ChatHistory';
import ChatInput from '../components/ChatInput';

const ChatPage = () => {
    const [messages, setMessages] = useState<Message[]>([]);
    return (
        <div>
            <ChatHeader />
            <ChatHistory messages={messages} />
            <ChatInput onMessageSent={(m) => setMessages(p => [...p, m])} />
        </div>
    );
};
```

**Lợi ích:**
- Dễ debug: biết chính xác file nào bị lỗi
- Dễ bảo trì: sửa chức năng A không ảnh hưởng chức năng B
- Dễ test: viết unit test cho từng class/component riêng biệt
- AI dễ đọc: file ngắn, AI không bị "loãng" context
- Code Splitting: React.lazy load từng domain, giảm bundle size

---

## File liên quan

- [Cấu trúc Dự án Tiêu chuẩn (Skill DuyVo26)](./skill_project_structure.md)
- [Tiêu chuẩn Viết Code (Coding Conventions)](./skill_coding_conventions.md)
- [Kiến trúc Chatbot & LLM](./skill_chatbot_architecture.md)
- [Chuẩn API Response](./skill_api_response_standard.md)
- [Codebase Mapper](./skill_codebase_mapper.md)
