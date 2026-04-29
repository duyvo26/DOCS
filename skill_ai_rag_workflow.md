# Kỹ thuật chuyên sâu: AI Engine & RAG Workflow (Standard)

Tài liệu này cung cấp cái nhìn chi tiết về luồng xử lý nội bộ (Internal Logic) dành cho các hệ thống tích hợp AI, đặc biệt là các ứng dụng sử dụng mô hình RAG (Retrieval-Augmented Generation) và LangGraph.

## 1. Kiến trúc LangGraph Workflow

Hệ thống sử dụng mô hình Máy trạng thái (State Machine) thông qua LangGraph thay vì gọi LLM đơn lẻ. Mỗi Node trong đồ thị là một hàm Python nhận vào `State` hiện tại và trả về `State` đã được cập nhật.

### Sơ đồ xử lý tiêu chuẩn:
```text
[BẮT ĐẦU] 
    ↓
[Node: route_question] ──────────┐
    ↓ (Phân loại yêu cầu)        │
    ├─→ "web_search" ──┐         │ (Dùng cho kiến thức tổng quát)
    │                  ↓         │
    └─→ "vectorstore" ─┴─→ [Node: retrieve] (Truy xuất dữ liệu cục bộ)
                                 ↓
                           [Node: grade_documents] (Kiểm tra độ liên quan)
                                 ↓
                           [Node: generate] (Sinh câu trả lời từ dữ liệu)
                                 ↓
                           [KẾT THÚC & CẬP NHẬT CHI PHÍ]
```

## 2. Chi tiết các thành phần xử lý (Nodes)

### A. Question Router (Định tuyến thông minh)
Sử dụng LLM kết hợp với Pydantic để phân loại yêu cầu của người dùng, giúp hệ thống chọn đúng nguồn dữ liệu (Local DB hoặc Internet).
```python
# [module_name]/utils/question_router.py
class RouteQuery(BaseModel):
    datasource: Literal["vectorstore", "web_search"]

def route_question(state: GraphState):
    question = state["question"]
    # LLM phân tích câu hỏi và trả về object RouteQuery
    source = question_router.invoke({"question": question})
    return source.datasource 
```

### B. Document Grader (Lọc dữ liệu rác)
Bước này cực kỳ quan trọng để chống lại hiện tượng "Ảo giác" (Hallucination). Hệ thống sẽ chấm điểm độ liên quan của từng tài liệu trước khi đưa vào ngữ cảnh sinh câu trả lời.
```python
def grade_documents(state: GraphState):
    documents = state["documents"]
    filtered_docs = []
    for doc in documents:
        # LLM đánh giá: "yes" là liên quan, "no" là không liên quan
        score = retrieval_grader.invoke({"question": question, "document": doc.page_content})
        if score.binary_score == "yes":
            filtered_docs.append(doc)
    return {"documents": filtered_docs}
```

## 3. Cơ chế Quản lý Chi phí (Usage & Billing)

Các dự án AI thường đi kèm chi phí vận hành (API tokens). Hệ thống cần cơ chế đếm và trừ phí chính xác sau mỗi yêu cầu thành công.

### Bước 1: Đếm Token sử dụng
Sử dụng các thư viện như `tiktoken` hoặc thư viện đặc thù của model để tính toán khối lượng dữ liệu trao đổi.
```python
import tiktoken

def count_tokens(text: str, model="gpt-4o-mini"):
    encoding = tiktoken.encoding_for_model(model)
    return len(encoding.encode(text))
```

### Bước 2: Khấu trừ số dư (Credit Deduction)
Cập nhật số dư người dùng trong Database một cách an toàn, hỗ trợ log lịch sử giao dịch để đối soát.
```python
def change_usage_balance(self, user_id, amount, description):
    # amount: số lượng credit/token cần trừ
    self.cursor.execute(
        "UPDATE users SET balance = balance - ? WHERE id = ?",
        (float(amount), user_id)
    )
    # Lưu vết lịch sử (Audit Log)
    self.cursor.execute(
        "INSERT INTO usage_history (user_id, amount, description) VALUES (?, ?, ?)",
        (user_id, float(amount), description)
    )
```

## 4. Quản lý Cơ sở dữ liệu Vector (Vector Store)

- **Công nghệ**: Thường sử dụng FAISS, ChromaDB, hoặc Pinecone.
- **Embedding**: Sử dụng các model embedding chuẩn (như OpenAI, Google hoặc các model Open-source).
- **Quy trình cập nhật**: Dữ liệu thô cần được Chunking (chia nhỏ), Embedding (véc-tơ hóa) và Indexing (lập chỉ mục) trước khi có thể truy xuất.

## 5. Cấu trúc phản hồi API (API Response)

Mọi phản hồi từ AI Engine nên bao gồm thông tin chi tiết về chi phí và nguồn trích dẫn để tăng tính minh bạch:
```json
{
  "answer": "[Nội dung câu trả lời từ AI]",
  "credits_charged": 12.5,
  "remaining_balance": 150.0,
  "sources": ["source_1.pdf", "data_entry_02.txt"],
  "process_time": "1.2s"
}
```

## 6. Cấu hình Máy trạng thái (Graph Compilation)

Để kết nối các Nodes thành một luồng hoàn chỉnh, hệ thống sử dụng `StateGraph` từ thư viện LangGraph. Việc này yêu cầu khai báo rõ ràng trạng thái (`State`) lưu chuyển giữa các Node.

### Định nghĩa GraphState (TypedDict)
```python
from typing import TypedDict, List
from langchain.schema import Document

class GraphState(TypedDict):
    """
    Khai báo các biến trạng thái sẽ được truyền đi và cập nhật xuyên suốt đồ thị.
    """
    question: str
    generation: str
    documents: List[Document]
    source: str
```

### Xây dựng và biên dịch Đồ thị
```python
from langgraph.graph import StateGraph, END

# Khởi tạo đồ thị với State đã định nghĩa
workflow = StateGraph(GraphState)

# Khai báo các Node (Hàm xử lý)
workflow.add_node("retrieve", retrieve)
workflow.add_node("grade_documents", grade_documents)
workflow.add_node("generate", generate)
workflow.add_node("web_search", web_search)

# Xây dựng các cạnh (Edges) để tạo luồng
# Bắt đầu với một Conditional Edge (chọn rẽ nhánh)
workflow.set_conditional_entry_point(
    route_question, # Hàm trả về string "web_search" hoặc "vectorstore"
    {
        "web_search": "web_search",
        "vectorstore": "retrieve",
    }
)

# Kết nối tuyến tính bình thường
workflow.add_edge("web_search", "generate")
workflow.add_edge("retrieve", "grade_documents")
workflow.add_edge("grade_documents", "generate")
workflow.add_edge("generate", END)

# Biên dịch thành ứng dụng có thể chạy được
app = workflow.compile()
```

---
*Lưu ý: Luôn tuân thủ chuẩn `GraphState` để đảm bảo dữ liệu không bị thất thoát khi đi qua các Node.*
