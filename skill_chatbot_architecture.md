# Kỹ thuật Kiến trúc Chatbot (Chatbot Architecture Skill)

Tài liệu này quy định tiêu chuẩn hóa module `chatbot/` nhằm đảm bảo tính độc lập, chuyên sâu về logic AI/LLM và dễ bảo trì.

---

## 1. Cấu trúc Thư mục Chuẩn (Standard Folder Structure)

Module `chatbot/` chỉ chứa logic liên quan đến xử lý ngôn ngữ tự nhiên và tương tác với LLM. Tuyệt đối không để code Ingestion (Nạp dữ liệu) hoặc Database Model vào đây.

```text
chatbot/
├── services/               # [WORKFLOW] Chứa các luồng logic LangGraph
│   ├── base_chat_service.py
│   └── rag_workflow_service.py
└── utils/                  # [ATOMIC COMPONENTS] Các thành phần đơn lẻ
    ├── llm.py              # LLM Factory: Khởi tạo OpenAI, Gemini, Grok...
    ├── prompt.py           # Class tập trung quản lý các Prompt Templates
    ├── graph_state.py      # Định nghĩa State (TypedDict) cho LangGraph
    ├── helpers.py          # Các hàm xử lý text, clean JSON dùng chung cho AI
    ├── {name}_agent.py     # Các Agent đơn lẻ: document_grader, answer_generator...
    └── {name}_tool.py      # Các công cụ hỗ trợ Agent (nếu cần)
```

---

## 2. Quy tắc Thiết kế Thành phần (Component Rules)

### A. LLM Factory (`utils/llm.py`)
Tất cả các thành phần trong `chatbot/` phải sử dụng chung một Class khởi tạo LLM để dễ dàng thay đổi Model hoặc cấu hình Temperature toàn cục.
*   **Hỗ trợ đa nền tảng**: OpenAI, Google Gemini, xAI (Grok), Ollama.
*   **Quản lý Config**: Lấy Key và Model Name từ biến môi trường.

### B. Centralized Prompts (`utils/prompt.py`)
*   Sử dụng một Class `Prompt` duy nhất để chứa các hằng số string.
*   Tránh để Prompt rải rác trong code logic.
*   Tên hằng số phải viết HOA và mô tả rõ mục đích (VD: `RAG_SYSTEM_PROMPT`).

### C. Atomic Agents (`utils/*_agent.py`)
*   Mỗi Agent chỉ làm một việc (Single Responsibility).
*   Ví dụ: `DocumentGrader` chỉ kiểm tra tính liên quan, không sinh câu trả lời.
*   Khuyến nghị bọc Agent trong một Class để dễ quản lý `llm_chain`.

---

## 3. Luồng Hoạt động Tiêu chuẩn (Standard Workflow)

Mọi xử lý AI phức tạp (đặc biệt là RAG) bắt buộc sử dụng **LangGraph** để quản lý trạng thái và rẽ nhánh logic.

### Quy trình thực thi:
1.  **Entry Point**: Router gọi một hàm trong `chatbot/services/`.
2.  **Workflow Initial**: Khởi tạo `StateGraph` với `GraphState` tương ứng.
3.  **Nodes execution**: Các bước chạy qua các Agent trong `utils/`.
4.  **Condition execution**: Kiểm tra điều kiện (ví dụ: có tài liệu không? điểm cao không?) để quyết định bước tiếp theo hoặc kết thúc.
5.  **Output**: Trả về dữ liệu đã được làm sạch (JSON clean) về cho Router.

---

## 4. Tiêu chuẩn Viết Code (Coding Standards)

1.  **Xử lý JSON**: LLM thường trả về text kèm theo tag (như `<think>` hoặc markdown block). Bắt buộc sử dụng hàm `clean_json` để bóc tách dữ liệu trước khi xử lý tiếp.
2.  **Retry Logic**: Trong RAG, nếu không tìm thấy tài liệu liên quan ở lần đầu, hãy sử dụng cơ chế `retry` (đếm số lần thử) trong LangGraph để thử lại với Prompt khác hoặc query khác.
3.  **Type Hinting**: Luôn sử dụng Type Hinting cho tham số đầu vào và đầu ra của các Agent.
4.  **Logging**: Sử dụng `logger` thay vì `print`. Log rõ các bước quan trọng: `Retrieve Start`, `Grading Results`, `Generate Final`.

---

## 5. Danh sách các file "Cấm" trong module Chatbot

*   **KHÔNG** để file `.env` hoặc load `.env` trực tiếp (Sử dụng `app/config.py`).
*   **KHÔNG** chứa logic `PyMuPDF`, `Markdownify` (Những thứ này thuộc `ingestion/`).
*   **KHÔNG** chứa SQLAlchemy models hoặc logic lưu DB (Sử dụng `app/models/`).
*   **KHÔNG** chứa logic UI/Frontend.

---

> [!IMPORTANT]
> Mục tiêu của module `chatbot/` là trở thành một "Blackbox" thông minh: Nhận câu hỏi/dữ liệu và trả về kết quả AI chính xác nhất.
