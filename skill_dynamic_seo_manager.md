# Skill: Quản lý SEO Động (Dynamic SEO Manager)

## Mục tiêu

Thay thế trực tiếp Meta Tag trong file tĩnh `index.html` của React giúp chia sẻ link hiệu quả (Facebook, Zalo). Sử dụng cơ chế Dynamic HTML Modification: ghi trực tiếp vào file vật lý thay vì render bằng Javascript.

---

## 1. Cơ chế Đồng bộ Hai chiều

### A. Push: DB xuống File HTML
Khi Admin lưu, hệ thống:
1. Lưu vào bảng `settings` trong DB
2. Dùng Regex để thay thế giá trị trong `frontend/index.html`

```python
def update_index_html_seo(title, description, keywords, author):
    content = read("frontend/index.html")
    content = re.sub(r'<title>.*?</title>', f'<title>{title}</title>', content)
    # Thay meta tags...
    write("frontend/index.html", content)
```

### B. Pull: File HTML lên UI
Admin có thể nhấn "Sync từ HTML" để lấy giá trị từ file vào DB.

---

## 2. Quản lý Tài nguyên (Logo, Favicon)

- Sanitize filename bằng `uuid.uuid4()` + `os.path.basename()`
- Lưu vào `utils/download/`
- Trả về URL: `/api/v1/download/{filename}`

---

## Quy tắc bắt buộc

1. Luôn sử dụng Regex để thay thế, không dùng string replace thuần.
2. File `index.html` phải có các placeholder meta tags mặc định.
3. Backup file trước khi ghi đè.
4. Logo upload < 500KB.
5. Kiểm tra Canonical, Robot tags sau khi update.

---

## File liên quan

- [Kiến trúc Frontend & API Setup](./skill_frontend_architecture.md)
- [Chia nhỏ Components & Domain Routing](./skill_frontend_routing_components.md)
- [Cấu hình Môi trường (.env)](./skill_env_configuration.md)
