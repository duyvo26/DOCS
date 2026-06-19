# Skill: Parser DOCX to MD — Chuyển đổi báo cáo sang Markdown có cấu trúc

## Mục tiêu

Chuyển đổi file báo cáo nghiệp vụ (DOCX/PDF) sang Markdown, trích xuất cấu trúc mục lục và phân mảnh nội dung để phục vụ AI, RAG, hoặc chấm điểm tự động.

---

## 1. Công nghệ sử dụng

| Thư viện | Vai trò |
|----------|---------|
| Microsoft MarkItDown | Chuyển DOCX -> MD |
| Python Regex (re) | Trích xuất cấu trúc Heading |
| Pathlib | Quản lý file (tương thích Win/Linux) |

---

## 2. Quy trình thực hiện

**Bước 1:** Chuyển sang Markdown
```python
from markitdown import MarkItDown
md = MarkItDown()
result = md.convert(docx_path).markdown
```

**Bước 2:** Quét cấu trúc (Structure Scanning)
```python
def get_structure_map(content):
    md_pattern = r"(?m)^(#{1,3})\s+(.+)$"
    bold_pattern = r"(?m)^\s*\*\*(.*?)\*\*\s*$"
    # ... regex matching + sắp xếp theo line
```

**Bước 3:** Phân mảnh nội dung (Mapping Sections)
- Ghi nhớ dòng bắt đầu và dòng kết thúc của mỗi mục
- AI Agent có thể trích xuất chính xác từng mục

---

## 3. Ứng dụng

- AI Grader (Chấm điểm tự động)
- Smart RAG (Chia theo Chương/Mục)
- Auto Summary (Tóm tắt từng chương)
- Báo cáo đối soát (Audit)

---

## Quy tắc bắt buộc

1. Luôn dùng MarkItDown, không dùng PyMuPDF hay docx thuần.
2. Regex phải có comment giải thích pattern.
3. Output phải có bảng cấu trúc (Level, Title, Line reference).
4. Lưu file MD sạch để xử lý RAG.

---

## File liên quan

- [AI RAG Workflow](./skill_ai_rag_workflow.md)
- [Kiến trúc Chatbot & LLM](./skill_chatbot_architecture.md)
- [Quản lý Thư viện (Dependencies)](./skill_dependencies_management.md)
