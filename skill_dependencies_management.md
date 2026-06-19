# Skill: Quan ly Thu vien (Dependencies Management)

## Muc tieu

Tong hop cac nhom thu vien cot loi va lenh cai dat tuong ung cho moi loai du an (Backend Python, Frontend React). Dam bao moi Skill co the chay duoc sau khi cai dat dung package.

---

## 1. Nhóm Core API & Database

```bash
pip install fastapi uvicorn python-multipart pydantic-settings python-dotenv requests aiohttp sqlalchemy mysql-connector-python
```

---

## 2. Nhóm Bảo mật & Xác thực

```bash
pip install "python-jose[cryptography]" "passlib[bcrypt]"
```

---

## 3. Nhóm AI & RAG

```bash
pip install langchain langgraph langchain-openai langchain-google-genai faiss-cpu tiktoken crawl4ai beautifulsoup4
```

---

## 4. Nhóm Xử lý Dữ liệu

```bash
pip install markitdown pandas openpyxl
```

---

## 5. Nhóm Frontend (React/Vite)

```bash
npm install axios react-router-dom lucide-react zustand zod react-hook-form
npm install -D tailwindcss postcss autoprefixer
```

---

## Quy tac bat buoc

1. Kich hoat moi truong ao `.venv` truoc khi `pip install`.
2. Gom thu vien Python vao `requirements.txt`.
3. Frontend package gom vao `package.json` tu dong.
4. KHONG cai dat package global.
5. Khi them package moi, cap nhat `requirements.txt` ngay.

---

## File lien quan

- [Cau truc Du an Tieu chuan (Skill DuyVo26)](./skill_project_structure.md)
- [Cau hinh Moi truong (.env)](./skill_env_configuration.md)
- [Bao mat & Xac thuc](./skill_security_authentication.md)
