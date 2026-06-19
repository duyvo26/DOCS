# Skill: Bao mat & Xac thuc Toan dien (Security & Authentication)

## Muc tieu

Bao ve he thong bang nhieu lop bao mat: JWT Stateless, bcrypt hash, RBAC Admin, chong Path Traversal, va Frontend Security checklist.

---

## 1. JWT (JSON Web Token)

Xac thuc khong luu trang thai (Stateless).

```python
def get_current_user(token: str = Depends(oauth2_scheme)):
    payload = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
    user = db.get_by_email(payload["email"])
    if not user:
        raise HTTPException(status_code=401, detail="User not found")
    return user
```

---

## 2. RBAC — Phan quyen Admin

```python
def get_current_admin(current_user: dict = Depends(get_current_user)):
    if not current_user.get("is_admin"):
        raise HTTPException(status_code=403, detail="Forbidden")
    return current_user
```

---

## 3. bcrypt — Hash Mat khau

```python
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(password: str, hashed: str) -> bool:
    return pwd_context.verify(password, hashed)
```

---

## 4. Chong Path Traversal

```python
safe_filename = os.path.basename(filename)
file_path = os.path.join(SAFE_STORAGE_DIR, safe_filename)
if not os.path.exists(file_path):
    raise HTTPException(status_code=404)
```

---

## 5. Frontend Security Checklist

| # | Hang muc | Bat buoc |
|---|----------|----------|
| 1 | JWT gan tu dong qua Interceptor | Co |
| 2 | Loi 401 redirect /login | Co |
| 3 | Token xac minh voi server khi app load | Co |
| 4 | ProtectedRoute / AdminRoute | Co |
| 5 | Nut bam isLoading + disabled | Co |
| 6 | Khong hardcode token | Co |
| 7 | Multi-tab logout sync | Khuyen nghi |

---

## Quy tac bat buoc

1. Mat khau luon hash bang bcrypt, khong luu plain text.
2. JWT payload chua id, email, is_admin — khong chua mat khau.
3. Tra loi giong nhau cho "email sai" vs "mat khau sai" (chong User Enumeration).
4. `os.path.basename()` bat buoc khi xu ly filename tu user.
5. CORS khong de `"*"` trong production.
6. Rate limiting cho AI API.

---

## File lien quan

- [Cau hinh Moi truong (.env)](./skill_env_configuration.md)
- [Dang nhap Google OAuth](./skill_google_oauth_redirect.md)
- [Kien truc Frontend & API Setup](./skill_frontend_architecture.md)
- [Chuan API Response](./skill_api_response_standard.md)
- [Cau truc Du an Tieu chuan (Skill DuyVo26)](./skill_project_structure.md)
