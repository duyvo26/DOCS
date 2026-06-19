# Skill: AI RAG Workflow — LangGraph & Retrieval-Augmented Generation

## Mục tiêu

Cung cấp luồng xử lý nội bộ (Internal Logic) cho hệ thống tích hợp AI sử dụng mô hình RAG (Retrieval-Augmented Generation) và LangGraph, bao gồm định tuyến câu hỏi, lọc tài liệu, sinh câu trả lời và quản lý chi phí token.

---

## 1. Kien truc LangGraph Workflow

He thong su dung mo hinh May trang thai (State Machine) thong qua LangGraph thay vi goi LLM don le. Moi Node trong do thi la mot ham Python nhan vao `State` hien tai va tra ve `State` da duoc cap nhat.

### So do xu ly tieu chuan:
```text
[BAT DAU]
    |
[Node: route_question] ----------|
    | (Phan loai yeu cau)        |
    |-- "web_search" ---|         | (Dung cho kien thuc tong quat)
    |                  |         |
    +-- "vectorstore" -+-> [Node: retrieve] (Truy xuat du lieu cuc bo)
                                 |
                           [Node: grade_documents] (Kiem tra do lien quan)
                                 |
                           [Node: generate] (Sinh cau tra loi tu du lieu)
                                 |
                           [KET THUC & CAP NHAT CHI PHI]
```

---

## 2. Chi tiet cac thanh phan

### A. Question Router
Su dung LLM ket hop voi Pydantic de phan loai yeu cau nguoi dung.

### B. Document Grader
Buoc chong ao giac (Hallucination). Cham diem do lien quan cua tung tai lieu truoc khi dua vao ngu canh sinh cau tra loi.

### C. Co che Quan ly Chi phi
Dem token su dung (tiktoken) va khau tru so du nguoi dung trong Database.

---

## Quy tac bat buoc

1. Moi Node trong LangGraph la mot ham Python doc lap, nhan `State` va tra ve `State` da cap nhat.
2. Su dung `GraphState` (TypedDict) thong nhat cho toan bo do thi.
3. Luon kiem tra do lien quan tai lieu (Document Grader) truoc khi sinh cau tra loi.
4. Chi phi token phai duoc tinh va khau tru sau moi yeu cau thanh cong.
5. Tra ve response chuan: answer, credits_charged, remaining_balance, sources.

---

## File lien quan

- [Kien truc Chatbot & LLM](./skill_chatbot_architecture.md)
- [Cau truc Du an Tieu chuan (Skill DuyVo26)](./skill_project_structure.md)
- [Chuan API Response](./skill_api_response_standard.md)
- [Ket noi OpenRouter](./skill_openrouter_integration.md)
