# Skill: Parser DOCX to MD — Chuyen doi bao cao sang Markdown co cau truc

## Muc tieu

Chuyen doi file bao cao nghiep vu (DOCX/PDF) sang Markdown, trich xuat cau truc muc luc va phan manh noi dung de phuc vu AI, RAG, hoac cham diem tu dong.

---

## 1. Cong nghe su dung

| Thu vien | Vai tro |
|----------|---------|
| Microsoft MarkItDown | Chuyen DOCX -> MD |
| Python Regex (re) | Trich xuat cau truc Heading |
| Pathlib | Quan ly file (tuong thich Win/Linux) |

---

## 2. Quy trinh thuc hien

**Buoc 1:** Chuyen sang Markdown
```python
from markitdown import MarkItDown
md = MarkItDown()
result = md.convert(docx_path).markdown
```

**Buoc 2:** Quet cau truc (Structure Scanning)
```python
def get_structure_map(content):
    md_pattern = r"(?m)^(#{1,3})\s+(.+)$"
    bold_pattern = r"(?m)^\s*\*\*(.*?)\*\*\s*$"
    # ... regex matching + sap xep theo line
```

**Buoc 3:** Phan manh noi dung (Mapping Sections)
- Ghi nho dong bat dau va dong ket thuc cua moi muc
- Ai Agent co the trich xuat chinh xac tung muc

---

## 3. Ung dung

- AI Grader (Cham diem tu dong)
- Smart RAG (Chia theo Chuong/Muc)
- Auto Summary (Tom tat tung chuong)
- Bao cao doi soat (Audit)

---

## Quy tac bat buoc

1. Luon dung MarkItDown, khong dung PyMuPDF hay docx thuan.
2. Regex phai co comment giai thich pattern.
3. Output phai co bang cau truc (Level, Title, Line reference).
4. Luu file MD sach de xu ly RAG.

---

## File lien quan

- [AI RAG Workflow](./skill_ai_rag_workflow.md)
- [Kien truc Chatbot & LLM](./skill_chatbot_architecture.md)
- [Quan ly Thu vien (Dependencies)](./skill_dependencies_management.md)
