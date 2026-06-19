# Skill: Viết Mã SQL Đa nền tảng (SQLite & MySQL)

## Mục tiêu

Viết SQL tương thích cả SQLite và MySQL, chống SQL Injection bằng Parameter Binding, xử lý sự khác biệt về Parameter placeholder.

---

## 1. Xử lý Parameter Binding

Sử dụng `self.P` để tương thích cả 2 loại DB:

```python
class BaseDB:
    def __init__(self):
        self.db_type = os.getenv("DB_TYPE", "sqlite")
        self.P = "?" if self.db_type == "sqlite" else "%s"

    def get_user(self, email: str):
        query = f"SELECT * FROM users WHERE email = {self.P}"
        self.cursor.execute(query, (email,))
        return self.cursor.fetchone()
```

---

## 2. Tránh hàm DB đặc thù

| Hàm | SQLite | MySQL | Cách xử lý |
|-----|--------|-------|------------|
| Ngày tháng | `DATE('now')` | `NOW()` | Dùng `datetime.now()` trong Python |
| Nối chuỗi | `\|\|` | `CONCAT()` | Nối trong Python trước |
| Tự động tăng | `INTEGER PRIMARY KEY` | `INT AUTO_INCREMENT` | Dùng `INTEGER PRIMARY KEY` (SQLite tự tăng) |

---

## 3. CREATE TABLE tương thích

```sql
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY,
    username VARCHAR(255) UNIQUE,
    email VARCHAR(255) UNIQUE,
    is_admin BOOLEAN DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## Quy tắc bắt buộc

1. Luôn dùng Parameter Binding (`?` hoặc `%s`), KHÔNG nối chuỗi trực tiếp vào SQL.
2. Dùng `self.P` để tương thích cả SQLite và MySQL, không hardcode `?` hay `%s`.
3. Giá trị ngày tháng tạo từ Python, không dùng hàm DB đặc thù.
4. `INTEGER PRIMARY KEY` tương thích cả 2 (SQLite tự động tăng).
5. Đóng kết nối sau khi thao tác (`close()`).

---

## File liên quan

- [Cấu trúc Dự án Tiêu chuẩn (Skill DuyVo26)](./skill_project_structure.md)
- [Cấu hình Môi trường (.env)](./skill_env_configuration.md)
- [Bảo mật & Xác thực](./skill_security_authentication.md)
- [Quản lý Thư viện (Dependencies)](./skill_dependencies_management.md)
