# Skill: Viet Ma SQL Da nen tang (SQLite & MySQL)

## Muc tieu

Viet SQL tuong thich ca SQLite va MySQL, chong SQL Injection bang Parameter Binding, xu ly su khac biet ve Parameter placeholder.

---

## 1. Xu ly Parameter Binding

Su dung `self.P` de tuong thich ca 2 loai DB:

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

## 2. Tranh ham DB dac thu

| Ham | SQLite | MySQL | Cach xu ly |
|-----|--------|-------|------------|
| Ngay thang | `DATE('now')` | `NOW()` | Dung `datetime.now()` trong Python |
| Noi chuoi | `\|\|` | `CONCAT()` | Noi trong Python truoc |
| Tu dong tang | `INTEGER PRIMARY KEY` | `INT AUTO_INCREMENT` | Dung `INTEGER PRIMARY KEY` (SQLite tu tang) |

---

## 3. CREATE TABLE tuong thich

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

## Quy tac bat buoc

1. Luon dung Parameter Binding (`?` hoac `%s`), KHONG noi chuoi truc tiep vao SQL.
2. Dung `self.P` de tuong thich ca SQLite va MySQL, khong hardcode `?` hay `%s`.
3. Gia tri ngay thang tao tu Python, khong dung ham DB dac thu.
4. `INTEGER PRIMARY KEY` tuong thich ca 2 (SQLite tu dong tang).
5. Dong ket noi sau khi thao tac (`close()`).

---

## File lien quan

- [Cau truc Du an Tieu chuan (Skill DuyVo26)](./skill_project_structure.md)
- [Cau hinh Moi truong (.env)](./skill_env_configuration.md)
- [Bao mat & Xac thuc](./skill_security_authentication.md)
- [Quan ly Thu vien (Dependencies)](./skill_dependencies_management.md)
