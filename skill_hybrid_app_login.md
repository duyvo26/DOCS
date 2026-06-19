# Skill: Đăng nhập Hybrid App (Cloud-Sync Polling)

## Mục tiêu

Đăng nhập Google OAuth 2.0 an toàn, ổn định trên Android & iOS bằng cách đồng bộ trạng thái qua Database, thay thế cho cơ chế Deep Link hay bị trình duyệt chặn.

---

## 1. Sơ đồ Hoạt động

1. Web user bấm "Đăng nhập Google"
2. Frontend tạo `sessionId` (UUID)
3. Frontend gọi `POST /auth/login-session` để đăng ký phiên chờ
4. Frontend Polling `GET /auth/login-session/{id}` mỗi 2 giây
5. Frontend gửi thông điệp `GOOGLE_LOGIN:sessionId` cho App qua Bridge
6. App mở Chrome Custom Tab -> User đăng nhập Google
7. Server cập nhật Token vào bảng `login_sessions` theo `sessionId`
8. Frontend Polling nhận được Token -> Đăng nhập thành công

---

## 2. Backend

```sql
CREATE TABLE login_sessions (
    session_id TEXT PRIMARY KEY,
    token TEXT,
    status TEXT DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

```python
@app.get("/google/callback/flutter")
async def google_callback_flutter(code: str, state: str):
    session_id = state
    # ... xac thuc Google, tao JWT ...
    user_db.update_login_session(session_id, token)
    return HTMLResponse("<h2>Thành công! Đóng tab này.</h2>")
```

---

## 3. Frontend Polling

```typescript
const handleGoogleLogin = async () => {
    const sessionId = crypto.randomUUID();
    await fetch(`${BASE_URL}/auth/login-session`, { method: 'POST', body: { session_id: sessionId } });
    const poll = setInterval(async () => {
        const res = await fetch(`${BASE_URL}/auth/login-session/${sessionId}`);
        if (res.data.status === 'completed') {
            clearInterval(poll);
            onSuccess(data.user, data.token);
        }
    }, 2000);
    window.FlutterBridge.postMessage(`GOOGLE_LOGIN:${sessionId}`);
};
```

---

## Quy tắc bắt buộc

1. One-time Use: Xóa session ngay sau khi trả Token.
2. TTL: Session có hiệu lực 10 phút.
3. Sử dụng UUID cho sessionId, tránh brute-force.
4. Cleanup session cũ tự động.
5. App chỉ mở Tab, không cần bắt deep link.

---

## File liên quan

- [Đăng nhập Google OAuth](./skill_google_oauth_redirect.md)
- [Bảo mật & Xác thực](./skill_security_authentication.md)
- [Tác vụ Bất đồng bộ & Polling](./skill_async_task_polling.md)
