# Skill: Kiến trúc Chatbot & LLM (Chatbot Architecture Skill)

## Mục tiêu

Quy định tiêu chuẩn hóa module `chatbot/` nhằm đảm bảo tính độc lập, chuyên sâu về logic AI/LLM và dễ bảo trì.

---

## 1. Cấu trúc Thư mục Chuẩn

```text
chatbot/
├── services/               # Chứa các luồng logic LangGraph
│   ├── rag_chat_service.py
│   └── multi_agent_service.py
└── utils/                  # Các thành phần đơn lẻ
    ├── llm.py              # LLM Factory: Khởi tạo OpenAI, Gemini, Grok...
    ├── prompt.py           # Class tập trung quản lý Prompt Templates
    ├── graph_state.py      # Định nghĩa State (TypedDict) cho LangGraph
    ├── {name}_agent.py     # Các Agent đơn lẻ
    └── {name}_tool.py      # Công cụ hỗ trợ Agent
```

---

## 2. Quy tắc Thiết kế Thành phần

- **LLM Factory** (`utils/llm.py`): Tất cả thành phần dùng chung một Class khởi tạo LLM.
- **Centralized Prompts** (`utils/prompt.py`): Một Class duy nhất chứa tất cả Prompt. Tên hằng số viết HOA.
- **Atomic Agents** (`utils/*_agent.py`): Mỗi Agent chỉ làm một việc (Single Responsibility).
- **LangGraph Workflows** (`services/`): Mỗi service là một luồng StateGraph hoàn chỉnh.

---

## 3. Luồng Hoạt động Tiêu chuẩn

1. Entry Point: Router gọi hàm trong `chatbot/services/`
2. Khởi tạo `StateGraph` với `GraphState`
3. Thực thi các Nodes qua Agent trong `utils/`
4. Kiểm tra điều kiện, rẽ nhánh hoặc kết thúc
5. Trả về dữ liệu JSON sạch cho Router

---

## Quy tắc bắt buộc

1. KHÔNG để code Ingestion hoặc DB Model trong `chatbot/`
2. Mỗi Agent chỉ chứa một chức năng duy nhất
3. Sử dụng LLM Factory, không khởi tạo LLM riêng lẻ
4. Prompt tập trung trong `prompt.py`, không rải rác
5. Bắt buộc clean_json trước khi xử lý dữ liệu từ LLM
6. Retry trong RAG nếu không tìm thấy tài liệu

---

## File liên quan

- [AI RAG Workflow](./skill_ai_rag_workflow.md)
- [Cấu trúc Dự án Tiêu chuẩn (Skill DuyVo26)](./skill_project_structure.md)
- [Kết nối OpenRouter](./skill_openrouter_integration.md)
- [Tiêu chuẩn Viết Code (Coding Conventions)](./skill_coding_conventions.md)
