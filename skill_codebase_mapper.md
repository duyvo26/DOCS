# Skill: Codebase Mapper — Phân tích Codebase và Tạo map.md

## Mục tiêu

Tự động phân tích codebase và tạo tài liệu điều hướng giúp AI và lập trình viên hiểu nhanh cấu trúc dự án.

---

## Các bước thực hiện

### Bước 1: Phân tích codebase

- Đọc các file được cung cấp.
- Xác định chức năng chính của từng file.
- Xác định mối quan hệ giữa các file.
- Xác định các file quan trọng đối với luồng hoạt động của hệ thống.

### Bước 2: Tạo Header Documentation cho file

Nếu file chưa có phần mô tả đầu file, tạo header phù hợp.

Header cần bao gồm:
- Tên file
- Chức năng chính
- Vai trò trong hệ thống
- File liên quan (nếu có)

### Bước 3: Tạo/Cập nhật map.md

Tạo hoặc cập nhật file `map.md`.

Mục đích của `map.md`:
- Là bản đồ tổng quan của codebase.
- Liệt kê các file quan trọng.
- Mô tả chức năng từng file.
- Có **cây thư mục (directory tree)** để xem cấu trúc code trực quan.
- Giúp AI hiểu cấu trúc dự án trước khi chỉnh sửa code.

### Bước 4: Duy trì map.md

Khi:
- Thêm file mới
- Xóa file
- Đổi chức năng file
- Refactor cấu trúc dự án

AI phải cập nhật lại `map.md`.

---

## Quy tắc

1. Không mô tả các file quá nhỏ hoặc file sinh tự động.
2. Ưu tiên các file có logic nghiệp vụ.
3. Mô tả ngắn gọn, rõ ràng.
4. Không suy đoán chức năng nếu chưa đọc mã nguồn.
5. Luôn cập nhật `map.md` khi phát hiện thay đổi kiến trúc.
6. Header file phải phản ánh đúng chức năng thực tế của file.
7. File `map_{tên_dự_án}.md` **PHẢI** có cây thư mục (directory tree) ở đầu file để view cấu trúc code trực quan.

---

## Định dạng map_{tên_dự_án}.md

```markdown
# Map: {Tên Dự Án}

## Cây thư mục (Directory Tree)

```
project_root/
├── app/
│   ├── main.py
│   ├── config.py
│   ├── routers/
│   │   ├── auth.py
│   │   └── chat.py
│   └── models/
│       └── user_model.py
├── chatbot/
│   └── services/
│       └── rag_chat_service.py
└── frontend/
    └── src/
        ├── App.tsx
        └── domains/
            └── chat/
                ├── pages/
                │   └── ChatPage.tsx
                └── components/
                    ├── ChatInput.tsx
                    └── MessageBubble.tsx
```

## Danh sách file quan trọng

| File | Chức năng | Vai trò | File liên quan |
|------|-----------|---------|----------------|
| `app/main.py` | Entry point FastAPI | Cấu hình CORS, middleware | `app/config.py` |
| `app/routers/chat.py` | Endpoint chat | Router - tiếp nhận request | `chatbot/services/rag_chat_service.py` |
| ... | ... | ... | ... |

## Luồng xử lý chính

```
[User] -> [Router] -> [Service] -> [Agent] -> [Response]
```
```

---

## Ghi chú khi người dùng yêu cầu "chuẩn hoá code"

Khi người dùng yêu cầu chuẩn hoá code cho một dự án cụ thể (VD: "chuẩn hoá code chatbot-luat"), BẮT BUỘC:

1. Tạo file `map.md` trong thư mục gốc của dự án đó (nếu chưa có).
2. Folder `{tên_dự_án}/` (do người dùng tạo tay) trong thư mục DOCS chứa file `map_{tên_dự_án}.md` để tham khảo cấu trúc.
   - VD: `chatbot-luat/map_chatbot-luat.md`
3. Nội dung `map_{tên_dự_án}.md`:
   - Tên dự án
   - Mô tả tổng quan
   - **Cây thư mục (directory tree)** — bắt buộc
   - Danh sách file quan trọng (đường dẫn, chức năng, vai trò, file liên quan)
   - Sơ đồ luồng xử lý chính (nếu có)
4. Cập nhật `map.md` tổng thể (nếu có) để dẫn đến folder dự án mới.

---

## File liên quan

- [Cấu trúc Dự án Tiêu chuẩn (Skill DuyVo26)](./skill_project_structure.md)
- [Tiêu chuẩn Viết Code (Coding Conventions)](./skill_coding_conventions.md)
- [Cấu hình Môi trường (.env)](./skill_env_configuration.md)
- [Quy tắc Thực thi (Execution Rules)](./skill_execution_rules.md)
