# Quy trình Đăng nhập Hybrid App (Kỹ thuật Cloud-Sync Polling)

Tài liệu này mô tả luồng đăng nhập Google OAuth 2.0 an toàn, ổn định tuyệt đối trên Android & iOS bằng cách đồng bộ trạng thái qua Database, thay thế cho cơ chế Deep Link hay bị trình duyệt chặn.

---

## 1. Sơ đồ Hoạt động (Step-by-Step)

1. **[Web]** Người dùng bấm "Đăng nhập Google".
2. **[Web]** Frontend tạo `sessionId` ngẫu nhiên.
3. **[Web]** Frontend gọi API `POST /auth/login-session` để đăng ký phiên chờ.
4. **[Web]** Frontend bắt đầu vòng lặp (Polling) gọi `GET /auth/login-session/{id}` mỗi 2 giây.
5. **[Web]** Frontend gửi thông điệp `GOOGLE_LOGIN:sessionId` cho Flutter qua Bridge.
6. **[App]** Flutter nhận thông điệp và mở Chrome Custom Tab (CCT) dẫn đến trang Backend.
7. **[Server]** Người dùng đăng nhập Google thành công, Server tạo JWT Token.
8. **[Server]** Server cập nhật Token vào bảng `login_sessions` trong DB ứng với `sessionId`.
9. **[Server]** Server trả về trang HTML "Thành công", yêu cầu người dùng đóng Tab.
10. **[Web]** Ở lần Polling tiếp theo, Frontend nhận được Token -> Tự động đăng nhập và vào màn hình chính.

---

## 2. Chi tiết Triển khai Mã nguồn

### A. Backend: Quản lý Phiên (FastAPI + SQLite)

**Cấu trúc bảng Database (`base_db.py`):**
```sql
CREATE TABLE login_sessions (
    session_id TEXT PRIMARY KEY,
    token TEXT,
    status TEXT DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Logic xử lý Callback (`auth.py`):**
Sau khi Google trả về thông tin người dùng, Server sẽ cập nhật Token vào DB:
```python
@router.get("/google/callback/flutter")
async def google_callback_flutter(code: str, state: str):
    session_id = state  # state chứa sessionId được truyền từ App
    # ... xác thực Google và tạo JWT Token ...
    
    user_db = UserDB()
    user_db.update_login_session(session_id, token) # Lưu Token vào DB
    user_db.close()

    return HTMLResponse(content="<h2>Đăng nhập thành công! Hãy đóng Tab này.</h2>")
```

### B. Frontend: Cơ chế Polling (`AuthView.tsx`)

Frontend chịu trách nhiệm theo dõi trạng thái đăng nhập:
```typescript
const handleGoogleLogin = async () => {
    const sessionId = crypto.randomUUID(); // Tạo ID bảo mật
    
    // 1. Khởi tạo phiên trên Server
    const formData = new FormData();
    formData.append('session_id', sessionId);
    await fetch(`${BASE_URL}/auth/login-session`, { method: 'POST', body: formData });

    // 2. Lắng nghe trạng thái
    const pollInterval = setInterval(async () => {
        const res = await fetch(`${BASE_URL}/auth/login-session/${sessionId}`);
        if (!res.ok) return;
        const data = await res.json();
        
        if (data.status === 'completed' && data.token) {
            clearInterval(pollInterval);
            onSuccess(data.user, data.token); // Đăng nhập thành công!
        }
    }, 2000);

    // 3. Gọi App mở trình duyệt login
    window.FlutterBridge.postMessage(`GOOGLE_LOGIN:${sessionId}`);
};
```

### C. Mobile App: Trụ cầu kết nối (`main.dart`)

App đóng vai trò trung gian mở Tab đăng nhập:
```dart
void _handleWebMessage(JavaScriptMessage message) {
  final data = message.message;
  if (data.startsWith('GOOGLE_LOGIN:')) {
    final sessionId = data.split(':')[1];
    _triggerNativeGoogleLogin(sessionId);
  }
}

Future<void> _triggerNativeGoogleLogin(String sessionId) async {
  final url = "${AppConfig.apiBaseUrl}/auth/google/login/flutter?session_id=$sessionId";
  
  // App chỉ mở Tab. Người dùng đóng xong app vẫn ở lại trang WebView.
  await FlutterWebAuth2.authenticate(
    url: url,
    callbackUrlScheme: 'none', // Không cần bắt deep link
  );
}
```

---

## 3. Các quy tắc Bảo mật (Security Rules)

Hệ thống được thiết kế với các lớp bảo mật nghiêm ngặt:

1. **One-time Use (Dùng một lần):** Ngay khi API trả về Token cho Frontend qua Polling, Server sẽ **XÓA NGAY** session đó khỏi Database. Không ai có thể dùng lại ID đó để lấy token lần thứ hai.
2. **Thời gian sống (TTL):** Session chỉ có hiệu lực trong **10 phút**. Sau 10 phút, session tự động bị coi là hết hạn và bị xóa bỏ.
3. **Dọn dẹp tự động:** Backend thực hiện quét và xóa các session cũ mỗi khi có một phiên đăng nhập mới được khởi tạo (`user_db.cleanup_old_sessions()`).
4. **ID Bảo mật:** Sử dụng `UUID` hoặc ID ngẫu nhiên độ dài lớn để chống tấn công đoán mã (Brute-force).

---

## 4. Hướng dẫn Vận hành

1. **Backend:** Đảm bảo đã chạy lệnh migrate/tạo bảng `login_sessions`.
2. **Frontend:** Cấu hình đúng `BASE_URL` trỏ về API Server.
3. **App:** Đảm bảo `JavascriptChannel` tên là `FlutterBridge` được cấu hình đúng trong WebView.
4. **Google Cloud:** Cài đặt Redirect URI của bản Flutter là: `https://yourdomain.com/api/v1/auth/google/callback/flutter`.

---
*Tài liệu hướng dẫn Quy trình Đăng nhập Hybrid Cloud-Sync - Antigravity AI.*
