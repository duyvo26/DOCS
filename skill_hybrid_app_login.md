# Skill: Dang nhap Hybrid App (Cloud-Sync Polling)

## Muc tieu

Dang nhap Google OAuth 2.0 an toan, on dinh tren Android & iOS bang cach dong bo trang thai qua Database, thay the cho co che Deep Link hay bi trinh duyet chan.

---

## 1. So do Hoat dong

1. Web user bam "Dang nhap Google"
2. Frontend tao `sessionId` (UUID)
3. Frontend goi `POST /auth/login-session` de dang ky phien cho
4. Frontend Polling `GET /auth/login-session/{id}` moi 2 giay
5. Frontend gui thong diep `GOOGLE_LOGIN:sessionId` cho App qua Bridge
6. App mo Chrome Custom Tab -> User dang nhap Google
7. Server cap nhat Token vao bang `login_sessions` theo `sessionId`
8. Frontend Polling nhan duoc Token -> Dang nhap thanh cong

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
    return HTMLResponse("<h2>Thanh cong! Dong tab nay.</h2>")
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

## Quy tac bat buoc

1. One-time Use: Xoa session ngay sau khi tra Token.
2. TTL: Session co hieu luc 10 phut.
3. Su dung UUID cho sessionId, tranh brute-force.
4. Cleanup session cu tu dong.
5. App chi mo Tab, khong can bat deep link.

---

## File lien quan

- [Dang nhap Google OAuth](./skill_google_oauth_redirect.md)
- [Bao mat & Xac thuc](./skill_security_authentication.md)
- [Tac vu Bat dong bo & Polling](./skill_async_task_polling.md)
