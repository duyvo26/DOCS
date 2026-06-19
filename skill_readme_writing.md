# Skill: Viết README.md Chuẩn (README Writing Guide)

## Mục tiêu

Quy định cách viết file `README.md` chuẩn cho mọi dự án. README là cửa ngõ đầu tiên để Developer, AI Agent và đối tác hiểu dự án.

---

## 1. Cấu trúc README Bắt buộc (7 phần)

```
1. Tổng quan dự án (Project Overview)
2. Yêu cầu hệ thống (System Requirements)
3. Cài đặt & Chạy thử cục bộ (Local Setup)
4. Cấu hình biến môi trường (Environment Variables)
5. Cấu trúc thư mục (Project Structure)
6. Danh sách API Endpoint (API Reference)
7. Hướng dẫn Triển khai (Deployment)
```

Xem mẫu README đầy đủ trong file source.

---

## 2. Quy tắc Viết README

- Viết bằng tiếng Việt thuần hoặc thuần Anh, không trộn lẫn.
- Không dùng emoji.
- Code block phải có nhãn ngôn ngữ (` ```bash `, ` ```python `).
- Bảng biến môi trường phải đầy đủ: tên, mô tả, ví dụ.
- Bước cài đặt phải copy-paste chạy được ngay.
- Cập nhật README khi thay đổi cấu trúc dự án.

---

## 3. Quy tắc .env.example

```bash
# .env.example — File nay DUOC commit len Git
SECRET_KEY=your-secret-key-here
API_KEY=your-api-key
# ... placeholder, khong phai gia tri that
```

---

## Checklist trước khi commit README

- [ ] Có đầy đủ 7 phần chính
- [ ] Bước cài đặt đã test chạy thử
- [ ] Bảng biến môi trường đồng bộ với `.env.example`
- [ ] Cấu trúc thư mục khớp với thực tế
- [ ] Không có emoji
- [ ] Code block có nhãn ngôn ngữ

---

## File liên quan

- [Cấu trúc Dự án Tiêu chuẩn (Skill DuyVo26)](./skill_project_structure.md)
- [Cấu hình Môi trường (.env)](./skill_env_configuration.md)
- [Tiêu chuẩn Viết Code (Coding Conventions)](./skill_coding_conventions.md)
