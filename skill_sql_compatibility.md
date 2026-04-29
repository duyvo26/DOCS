# Kỹ thuật chuyên sâu: Viết Mã SQL Tương thích (SQLite & MySQL)

Khi thiết kế ứng dụng theo kiến trúc dùng `BaseDB` với Raw SQL, chúng ta thường sử dụng SQLite để phát triển nhanh. Tuy nhiên, nếu muốn bộ SQL này có thể chạy được trên cả MySQL sau này, bạn cần tuân thủ các quy tắc viết SQL chuẩn (ANSI SQL) và xử lý sự khác biệt về Parameter.

---

## 1. Cấu trúc Bảng (CREATE TABLE)
Một số từ khóa đặc thù (như `AUTOINCREMENT` của SQLite và `AUTO_INCREMENT` của MySQL) sẽ gây lỗi chéo. 

**Kỹ thuật:** Ở SQLite, nếu bạn khai báo `INTEGER PRIMARY KEY` (không có chữ AUTOINCREMENT), nó vẫn sẽ tự động tăng giá trị (đóng vai trò là ROWID alias).
Tuy nhiên, để tạo script chạy mượt trên cả 2, cách an toàn nhất là thiết kế script riêng hoặc sử dụng ORM (như SQLAlchemy). Nếu bắt buộc dùng Raw SQL tương thích cao:

```sql
-- Dùng các kiểu dữ liệu phổ thông: INTEGER, TEXT/VARCHAR, REAL/FLOAT, TIMESTAMP
CREATE TABLE IF NOT EXISTS users (
    -- Ghi chú: SQLite dùng INTEGER PRIMARY KEY AUTOINCREMENT
    -- MySQL dùng INT AUTO_INCREMENT PRIMARY KEY
    id INTEGER PRIMARY KEY, 
    username VARCHAR(255) UNIQUE,
    email VARCHAR(255) UNIQUE,
    is_admin BOOLEAN DEFAULT 0, -- SQLite sẽ lưu 0/1, MySQL hiểu BOOLEAN là TINYINT(1)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Tương thích cả hai
);
```

---

## 2. Xử lý Parameter Binding (Chống SQL Injection)
Sự khác biệt lớn nhất giữa SQLite driver (`sqlite3`) và MySQL driver (`mysql-connector` hoặc `pymysql`) là ký tự tham số truyền vào:
- **SQLite** sử dụng dấu hỏi chấm `?`
- **MySQL** sử dụng phần trăm `%s`

**Cách khắc phục trong Python:** Đừng hardcode `?` hay `%s`. Hãy định nghĩa nó dựa vào loại kết nối DB hiện tại.

```python
# app/models/base_db.py
import sqlite3
import mysql.connector
import os

class BaseDB:
    def __init__(self):
        # Đọc loại DB từ biến môi trường, mặc định là sqlite
        self.db_type = os.getenv("DB_TYPE", "sqlite")
        # Placeholder tương ứng với từng loại DB
        self.P = "?" if self.db_type == "sqlite" else "%s"
        
        if self.db_type == "sqlite":
            db_path = os.path.join(os.getenv("DIR_ROOT", "."), "database.db")
            self.conn = sqlite3.connect(db_path)
            self.conn.row_factory = sqlite3.Row  # Trả kết quả dạng dict-like
        else:
            self.conn = mysql.connector.connect(
                host=os.getenv("DB_HOST", "localhost"),
                port=int(os.getenv("DB_PORT", 3306)),
                user=os.getenv("DB_USER", "root"),
                password=os.getenv("DB_PASSWORD", ""),
                database=os.getenv("DB_NAME", "myapp")
            )
            
        self.cursor = self.conn.cursor()

    def get_user(self, email: str):
        query = f"SELECT * FROM users WHERE email = {self.P}"
        self.cursor.execute(query, (email,))
        return self.cursor.fetchone()

    def add_user(self, username: str, email: str):
        query = f"INSERT INTO users (username, email) VALUES ({self.P}, {self.P})"
        self.cursor.execute(query, (username, email))
        self.conn.commit()

    def close(self):
        """Luon goi ham nay sau khi thao tac xong de giai phong ket noi."""
        self.cursor.close()
        self.conn.close()
```

---

## 3. Tránh các Hàm Đặc thù của Database
*   **Xử lý Ngày Tháng**: Đừng dùng các hàm như `DATE('now')` của SQLite hay `NOW()` của MySQL. Hãy tạo giá trị ngày tháng từ Python `datetime.now().isoformat()` và truyền vào như một chuỗi (String Parameter).
*   **Toán tử Nối Chuỗi**: SQLite dùng `||`, MySQL dùng hàm `CONCAT()`. Hạn chế việc nối chuỗi trong SQL, hãy nối chuỗi từ Python trước rồi truyền xuống SQL qua Parameter Binding.
*   **LIMIT và OFFSET**: Cả SQLite và MySQL đều hỗ trợ chuẩn cú pháp:
    ```sql
    SELECT * FROM logs ORDER BY created_at DESC LIMIT 10 OFFSET 20;
    ```

> 💡 **Khuyến nghị Lập trình viên**: Nếu dự án ngay từ đầu đã xác định sẽ thay đổi Database thường xuyên (chuyển từ SQLite lên MySQL/Postgres), bắt buộc **phải cân nhắc sử dụng SQLAlchemy ORM**. ORM sẽ tự động biên dịch code Python thành các cú pháp SQL đặc thù của từng loại Database, giải quyết triệt để vấn đề không tương thích.
