# Router Chatbot Implementation

## Tổng quan

Hệ thống chatbot với khả năng:
1. **Định tuyến thông minh** (Question Router): Phân loại câu hỏi thành 2 loại:
   - `vectorstore`: Câu hỏi về sản phẩm → sử dụng RAG
   - `web_search`: Câu hỏi chung (chào hỏi, xã giao) → trả lời trực tiếp

2. **Tính phí token**: Đếm token output/input và tự động trừ từ tài khoản người dùng theo tỷ lệ cấu hình (Hỗ trợ số thực - float).

3. **RAG Pipeline**: Retrieve → Grade → Generate với LangGraph

## Cấu trúc code

```
chatbot/
├── services/
│   └── files_rag_chat_agent.py    # Main agent với router
└── utils/
    ├── question_router.py          # Router phân loại câu hỏi
    ├── token_counter.py            # Đếm token bằng tiktoken
    ├── document_grader.py          # Chấm điểm tài liệu
    ├── answer_generator.py         # Sinh câu trả lời
    └── custom_prompt.py            # Chứa ROUTER_PROMPT

app/
├── routers/
│   └── chatbot.py                  # API endpoint /chat
└── models/
    └── base_db.py                  # UserDB với token_balance (REAL)

test/
└── test_router_chatbot.py          # Script test
```

## Workflow

```
START
  ↓
route_question (QuestionRouter)
  ├─→ [vectorstore] → retrieve → grade_documents → generate → END
```

Sau mỗi bước `generate` hoặc `web_search`:
- Đếm token output bằng `tiktoken`
- Trừ token từ `user.token_balance` (dạng REAL/float)
- Ghi log vào `token_history`

## Sử dụng

### 1. Cài đặt dependencies

```bash
pip install tiktoken
```

### 2. Cấu hình .env

```env
LLM_NAME=gemini
EMBEDDING_MODEL_NAME=text-embedding-004
PATH_VECTOR_STORE=./vector_store
NUMDOCS=5
```

### 3. Test script

```bash
python test/test_router_chatbot.py
```

### 4. API Endpoint

**POST** `/api/v1/chat`

Headers:
```
Authorization: Bearer <token>
```

Body:
```json
{
  "question": "tư vấn tôi mất ngủ dùng sản phẩm gì",
  "prompt": "Bạn là nhân viên tư vấn..."
}
```

Response:
```json
{
  "answer": "Dạ, em xin tư vấn...",
  "tokens_charged": 125.0,
  "user_token_balance": 875.0
}
```

## Các file đã xóa (không dùng)

- `chatbot/utils/query_generator.py`
- `chatbot/utils/question.py`
- `chatbot/utils/text_summarizer.py`
- `chatbot/utils/html_content_generator.py`

## Thay đổi database

### Schema updates:

**users table:**
```sql
token_balance REAL DEFAULT 0  -- Thay vì INTEGER
```

**token_history table:**
```sql
amount REAL  -- Thay vì INTEGER
```

### Migration (nếu cần):

Nếu database đã tồn tại, cần migrate:
```sql
-- Backup data
CREATE TABLE users_backup AS SELECT * FROM users;
CREATE TABLE token_history_backup AS SELECT * FROM token_history;

-- Drop old tables
DROP TABLE token_history;
DROP TABLE users;

-- Recreate với REAL type (code sẽ tự tạo khi restart)
```

## Tính năng chính

### 1. QuestionRouter
- Phân loại câu hỏi bằng LLM
- Prompt: `ROUTER_PROMPT` trong `custom_prompt.py`
- Output: "vectorstore" hoặc "web_search"

### 2. TokenCounter
- Sử dụng `tiktoken` để đếm chính xác
- Hỗ trợ nhiều model (GPT, Gemini)
- Fallback về `cl100k_base` nếu không tìm thấy encoding

### 3. Token Charging
- Tự động sau khi có output
- Ghi log vào `token_history` với description
- Trả về số dư mới

## Ví dụ flow hoàn chỉnh

```python
from chatbot.services.files_rag_chat_agent import FilesChatAgent
from chatbot.utils.llm import LLM
import os

# Khởi tạo
llm = LLM().get_llm(os.environ["LLM_NAME"])
agent = FilesChatAgent(
    llm_model=llm,
    path_vector_store=os.environ["PATH_VECTOR_STORE"]
)

# Compile workflow
pipeline = agent.get_workflow().compile()

# Invoke
result = pipeline.invoke({
    "question": "tư vấn sản phẩm trị mất ngủ",
    "prompt": "Bạn là tư vấn viên...",
    "email": "user@example.com"  # Quan trọng để trừ token
})

print(result["generation"])
# Token đã tự động bị trừ từ tài khoản user@example.com
```

## Notes

- Email trong GraphState là **bắt buộc** để trừ token
- Nếu không có email, hệ thống sẽ warning nhưng vẫn trả lời
- Token charging chỉ áp dụng cho output, không tính input
- Rate có thể điều chỉnh trong `TokenCounter.calculate_cost()`
