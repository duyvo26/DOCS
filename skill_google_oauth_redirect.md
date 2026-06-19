# Skill: Đăng nhập Google OAuth (Redirect Flow)

## Mục tiêu

Đăng nhập Google mượt mà qua Redirect Flow (Backend làm trung gian), tránh lỗi hiển thị JSON thô trên trình duyệt.

---

## 1. Sơ đồ luồng

```
[Browser] - Click Login -> [Backend /google/login]
                              -> Redirect 302 -> [Google Auth Screen]
[Backend /callback] <- Redirect w/ Code - Google
    -> Đổi Code lấy User Info
    -> Tạo JWT Token
    -> Redirect 302 kèm Token -> [Frontend /?token=...]
[Frontend App.tsx] -> Lưu Token -> Vào trang chính
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

## Quy tắc bắt buộc

1. Luôn dùng `RedirectResponse`, không trả JSON trực tiếp cho OAuth callback.
2. Redirect về Frontend URL có kèm token trên query param.
3. Frontend phải xóa token khỏi URL sau khi lưu (`replaceState`).
4. Scope bắt buộc: `openid`, `email`, `profile`.
5. Cấu hình `GOOGLE_REDIRECT_URI` trong `.env` trùng khớp với Google Cloud Console.

---

## File liên quan

- [Bảo mật & Xác thực](./skill_security_authentication.md)
- [Cấu hình Môi trường (.env)](./skill_env_configuration.md)
- [Đăng nhập Hybrid App (Mobile)](./skill_hybrid_app_login.md)
- [Kiến trúc Frontend & API Setup](./skill_frontend_architecture.md)
