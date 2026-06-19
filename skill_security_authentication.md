# Skill: Bảo mật & Xác thực Toàn diện (Security & Authentication)

## Mục tiêu

Bảo vệ hệ thống bằng nhiều lớp bảo mật: JWT Stateless, bcrypt hash, RBAC Admin, chống Path Traversal, và Frontend Security checklist.

---

## 1. JWT (JSON Web Token)

Xác thực không lưu trạng thái (Stateless).

```python
def get_current_user(token: str = Depends(oauth2_scheme)):
    payload = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
    user = db.get_by_email(payload["email"])
    if not user:
        raise HTTPException(status_code=401, detail="User not found")
    return user
```

---

## 2. RBAC — Phân quyền Admin

```python
def get_current_admin(current_user: dict = Depends(get_current_user)):
    if not current_user.get("is_admin"):
        raise HTTPException(status_code=403, detail="Forbidden")
    return current_user
```

---

## 3. bcrypt — Hash Mật khẩu

```python
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(password: str, hashed: str) -> bool:
    return pwd_context.verify(password, hashed)
```

---

## 4. Chống Path Traversal

```python
safe_filename = os.path.basename(filename)
file_path = os.path.join(SAFE_STORAGE_DIR, safe_filename)
if not os.path.exists(file_path):
    raise HTTPException(status_code=404)
```

---

## 5. Frontend Security Checklist

| # | Hạng mục | Bắt buộc |
|---|----------|----------|
| 1 | JWT gán tự động qua Interceptor | Có |
| 2 | Lỗi 401 redirect /login | Có |
| 3 | Token xác minh với server khi app load | Có |
| 4 | ProtectedRoute / AdminRoute | Có |
| 5 | Nút bấm isLoading + disabled | Có |
| 6 | Không hardcode token | Có |
| 7 | Multi-tab logout sync | Khuyến nghị |

---

## Quy tắc bắt buộc

1. Mật khẩu luôn hash bằng bcrypt, không lưu plain text.
2. JWT payload chứa id, email, is_admin — không chứa mật khẩu.
3. Trả lời giống nhau cho "email sai" vs "mật khẩu sai" (chống User Enumeration).
4. `os.path.basename()` bắt buộc khi xử lý filename từ user.
5. CORS không để `"*"` trong production.
6. Rate limiting cho AI API.

---

## File liên quan

- [Cấu hình Môi trường (.env)](./skill_env_configuration.md)
- [Đăng nhập Google OAuth](./skill_google_oauth_redirect.md)
- [Kiến trúc Frontend & API Setup](./skill_frontend_architecture.md)
- [Chuẩn API Response](./skill_api_response_standard.md)
- [Cấu trúc Dự án Tiêu chuẩn (Skill DuyVo26)](./skill_project_structure.md)
