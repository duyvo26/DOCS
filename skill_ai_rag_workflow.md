# Skill: AI RAG Workflow — LangGraph & Retrieval-Augmented Generation

## Mục tiêu

Cung cấp luồng xử lý nội bộ (Internal Logic) cho hệ thống tích hợp AI sử dụng mô hình RAG (Retrieval-Augmented Generation) và LangGraph, bao gồm định tuyến câu hỏi, lọc tài liệu, sinh câu trả lời và quản lý chi phí token.

---

## 1. Kiến trúc LangGraph Workflow

Hệ thống sử dụng mô hình Máy trạng thái (State Machine) thông qua LangGraph thay vì gọi LLM đơn lẻ. Mỗi Node trong đồ thị là một hàm Python nhận vào `State` hiện tại và trả về `State` đã được cập nhật.

### Sơ đồ xử lý tiêu chuẩn:
```text
[BẮT ĐẦU]
    |
[Node: route_question] ----------|
    | (Phân loại yêu cầu)        |
    |-- "web_search" ---|         | (Dùng cho kiến thức tổng quát)
    |                  |         |
    +-- "vectorstore" -+-> [Node: retrieve] (Truy xuất dữ liệu cục bộ)
                                 |
                            [Node: grade_documents] (Kiểm tra độ liên quan)
                                 |
                            [Node: generate] (Sinh câu trả lời từ dữ liệu)
                                 |
                            [KẾT THÚC & CẬP NHẬT CHI PHÍ]
```

---

## 2. Chi tiết các thành phần

### A. Question Router
Sử dụng LLM kết hợp với Pydantic để phân loại yêu cầu người dùng.

### B. Document Grader
Bước chống ảo giác (Hallucination). Chấm điểm độ liên quan của từng tài liệu trước khi đưa vào ngữ cảnh sinh câu trả lời.

### C. Cơ chế Quản lý Chi phí
Đếm token sử dụng (tiktoken) và khấu trừ số dư người dùng trong Database.

---

## Quy tắc bắt buộc

1. Mỗi Node trong LangGraph là một hàm Python độc lập, nhận `State` và trả về `State` đã cập nhật.
2. Sử dụng `GraphState` (TypedDict) thống nhất cho toàn bộ đồ thị.
3. Luôn kiểm tra độ liên quan tài liệu (Document Grader) trước khi sinh câu trả lời.
4. Chi phí token phải được tính và khấu trừ sau mỗi yêu cầu thành công.
5. Trả về response chuẩn: answer, credits_charged, remaining_balance, sources.

---

## File liên quan

- [Kiến trúc Chatbot & LLM](./skill_chatbot_architecture.md)
- [Cấu trúc Dự án Tiêu chuẩn (Skill DuyVo26)](./skill_project_structure.md)
- [Chuẩn API Response](./skill_api_response_standard.md)
- [Kết nối OpenRouter](./skill_openrouter_integration.md)
