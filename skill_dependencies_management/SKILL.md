---
name: dependencies-management
description: "Quản lý Thư viện (Dependencies Management). Actions: setup, configure, implement, review, fix, optimize. Keywords: packages, requirements.txt, FastAPI, LangGraph, JWT, zustand, zod"
argument-hint: "[action] [component]"
metadata:
  author: duyvo26
  version: "1.0.0"
---

# Skill: Quản lý Thư viện (Dependencies Management)

## Mục tiêu

Tổng hợp các nhóm thư viện cốt lõi và lệnh cài đặt tương ứng cho mỗi loại dự án (Backend Python, Frontend React). Đảm bảo mọi Skill có thể chạy được sau khi cài đúng package.

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

## Quy tắc bắt buộc

1. Kích hoạt môi trường ảo `.venv` trước khi `pip install`.
2. Gom thư viện Python vào `requirements.txt`.
3. Frontend package gom vào `package.json` tự động.
4. KHÔNG cài đặt package global.
5. Khi thêm package mới, cập nhật `requirements.txt` ngay.

---

## File liên quan

- [Cấu trúc Dự án Tiêu chuẩn (Skill DuyVo26)](skill: project-structure)
- [Cấu hình Môi trường (.env)](skill: env-configuration)
- [Bảo mật & Xác thực](skill: security-authentication)
