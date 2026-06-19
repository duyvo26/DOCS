# Skill: Dang nhap Google OAuth (Redirect Flow)

## Muc tieu

Dang nhap Google muot ma qua Redirect Flow (Backend lam trung gian), tranh loi hien thi JSON tho tren trinh duyet.

---

## 1. So do luong

```
[Browser] - Click Login -> [Backend /google/login]
                              -> Redirect 302 -> [Google Auth Screen]
[Backend /callback] <- Redirect w/ Code - Google
    -> Doi Code lay User Info
    -> Tao JWT Token
    -> Redirect 302 kem Token -> [Frontend /?token=...]
[Frontend App.tsx] -> Luu Token -> Vao trang chinh
```

---

## 2. Backend Implementation

```python
@app.get("/google/callback")
async def google_callback(code: str):
    # ... logic lay user tu Google ...
    token = create_access_token({"id": user["id"], "email": user["email"]})
    return RedirectResponse(url=f"{settings.FRONTEND_URL}/?token={token}")
```

---

## 3. Frontend Implementation

```typescript
useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    const token = params.get('token');
    if (token) {
        localStorage.setItem('access_token', token);
        window.history.replaceState({}, '', window.location.pathname);
        fetchUserInfor();
    }
}, []);
```

---

## Quy tac bat buoc

1. Luon dung `RedirectResponse`, khong tra JSON truc tiep cho OAuth callback.
2. Redirect ve Frontend URL co kem token tren query param.
3. Frontend phai xoa token khoi URL sau khi luu (`replaceState`).
4. Scope bat buoc: `openid`, `email`, `profile`.
5. Cau hinh `GOOGLE_REDIRECT_URI` trong `.env` trung khop voi Google Cloud Console.

---

## File lien quan

- [Bao mat & Xac thuc](./skill_security_authentication.md)
- [Cau hinh Moi truong (.env)](./skill_env_configuration.md)
- [Dang nhap Hybrid App (Mobile)](./skill_hybrid_app_login.md)
- [Kien truc Frontend & API Setup](./skill_frontend_architecture.md)
