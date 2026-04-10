# Hướng dẫn Tích hợp Web App vào Mobile App (Hybrid App)

Tài liệu này hướng dẫn chi tiết cách biến một ứng dụng Web (React, Vue, HTML...) thành một ứng dụng Native App (Flutter) thông qua WebView, với cơ chế đăng nhập Google Native và đồng bộ Token hai chiều.

## 1. Tổng quan Kiến trúc (Hybrid Flow)
1. **Mobile App**: Đóng vai trò là "vỏ" (Shell), chứa WebView để hiển thị trang web.
2. **Native OAuth**: App xử lý đăng nhập Google bằng trình duyệt hệ thống để đảm bảo bảo mật và không bị Google chặn.
3. **Bridge Communication**: Web và App giao tiếp với nhau qua `JavascriptChannel`.
4. **Token Handover**: Sau khi App lấy được Token, nó sẽ đồng bộ vào Web thông qua URL hoặc `localStorage`.

---

## 2. Luồng Kết nối & Lưu trữ Dữ liệu

Ứng dụng sử dụng cơ chế **Lưu trữ Song song** để đảm bảo trải nghiệm người dùng mượt mà nhất.

### A. Kết nối (Connection)
- **Khởi động:** Khi App mở lên, nó sẽ đọc `access_token` từ bộ nhớ máy (`SharedPreferences`).
- **WebView:** App khởi tạo và tải trang Web (URL cấu hình trong `config.dart`). Nếu đã có token, App sẽ tự động gửi token này sang cho Web ngay khi trang web tải xong (`onPageFinished`).

### B. Lưu trữ (Storage)
Dữ liệu đăng nhập được lưu ở 2 tầng:
1. **Tầng Native (Flutter):** Sử dụng `SharedPreferences`. Token lưu tại đây giúp người dùng không phải đăng nhập lại mỗi khi mở App (xử lý ở hàm `main()` của Flutter).
2. **Tầng Web (WebView):** Sử dụng `localStorage`. Web cần token này để gọi các API lấy dữ liệu hay lịch sử người dùng.

### C. Cơ chế đồng bộ (Synchronization)
- **Từ App sang Web:** Khi `Native OAuth` thành công, App lưu token vào `SharedPreferences` và ra lệnh cho WebView: `controller.loadRequest(webUrl + "/?token=" + token)`.
- **Từ Web sang App:** Khi người dùng bấm "Đăng xuất" trên giao diện Web, Web xóa `localStorage` và gửi lệnh `LOGOUT` qua Bridge. App nhận lệnh này và xóa nốt token trong `SharedPreferences`.

---

## 2. Triển khai Backend (Ví dụ với FastAPI)

Để hỗ trợ Mobile App, Backend cần cung cấp 2 Endpoint: Một để bắt đầu đăng nhập và một để xử lý Callback từ Google.

### A. Các bước cấu hình Google Cloud Console:
1. Truy cập [Google Cloud Console](https://console.cloud.google.com/).
2. Tạo **OAuth 2.0 Client ID** loại **Web Application**.
3. **Authorized Redirect URIs**: Bạn cần thêm **CẢ HAI** URL sau:
   - Web: `https://domain.com/api/v1/auth/google/callback`
   - Mobile: `https://domain.com/api/v1/auth/google/callback/flutter`

### B. Endpoint bắt đầu đăng nhập (Flutter)
App gọi đến Link: `https://domain.com/api/v1/auth/google/login/flutter?callback_scheme=your_scheme`

### C. Endpoint xử lý Callback cho Flutter (`/callback/flutter`)
Đây là route chuyên biệt để xử lý việc quay trở lại App Mobile. Backend sẽ tạo JWT Token và trả về trang HTML gọi Deep Link.

```python
@router.get("/auth/google/callback/flutter")
async def google_callback_flutter(code: str, state: str):
    # 1. Lấy Token từ Google
    # 2. Tạo access_token hệ thống
    token = "EYJ..." 
    
    # 3. Trả về HTML chứa Deep Link (state chính là callback_scheme)
    deep_link = f"{state}://callback?token={token}"
    
    content = f"""
    <html>
    <body onload="window.location.href='{deep_link}'; setTimeout(()=>window.close(), 1000);">
        <h2>Đăng nhập thành công</h2>
        <a href="{deep_link}">Nhấn vào đây để quay lại App</a>
    </body>
    </html>
    """
    return HTMLResponse(content=content)
```

---

## 3. Cơ chế Bắc cầu (Bridge Communication)

### A. Phía Web (React/Frontend)
Web gửi thông điệp cho App thông qua đối tượng `window.FlutterBridge`.

**1. Yêu cầu App đăng nhập:**
```typescript
const handleGoogleLogin = () => {
  if ((window as any).FlutterBridge) {
    (window as any).FlutterBridge.postMessage('GOOGLE_LOGIN');
  }
};
```

**2. Thông báo App đăng xuất:**
```typescript
const handleLogout = () => {
  localStorage.removeItem('access_token');
  if ((window as any).FlutterBridge) {
    (window as any).FlutterBridge.postMessage('LOGOUT');
  }
};
```

### B. Phía App (Flutter/Mobile)
```dart
JavascriptChannel(
  name: 'FlutterBridge',
  onMessageReceived: (JavascriptMessage message) {
    if (message.message == 'GOOGLE_LOGIN') _triggerNativeGoogleLogin();
    if (message.message == 'LOGOUT') _handleAppLogout();
  },
)
```

---

## 4. Quy trình Bàn giao Token (Token Handover)

Sau khi Flutter lấy được Token từ Deep Link, nó thực hiện:
1. **Lưu Token:** `prefs.setString('access_token', token)`.
2. **Đồng bộ sang Web:** `controller.loadRequest(Uri.parse("weburl.com/?token=" + token))`.

**Web xử lý nhận Token:**
```typescript
useEffect(() => {
  const token = new URLSearchParams(window.location.search).get('token');
  if (token) {
    localStorage.setItem('access_token', token);
    window.history.replaceState({}, '', window.location.pathname);
    fetchUser();
  }
}, []);
```

---

## 5. Cấu hình Mobile App (Flutter)

1. **Deep Link (Android):** Mở `AndroidManifest.xml`, sửa `scheme` thành scheme của bạn.
2. **App ID:** Mở `build.gradle.kts`, sửa `applicationId` (Không dùng dấu `-`).
3. **Build:** 
   - `flutter clean`
   - `flutter build apk --release`

---

## 6. Giải quyết sự cố & Lưu ý quan trọng

Dưới đây là các lưu ý "xương máu" để tránh lỗi khi triển khai thực tế:

### 1. Cấu hình CORS (Backend)
Nếu App không load được dữ liệu từ API, hãy kiểm tra file `app/main.py`. Bạn phải cho phép tên miền của Web App được truy cập API. 

**Lưu ý bảo mật:** Ở bản phát hành (Production), hãy thay đổi `ALLOW_ORIGINS` trong file `.env` từ `*` thành domain thật của bạn (Vd: `ALLOW_ORIGINS=https://yourdomain.com`) để ngăn chặn các trang web lạ tấn công API.
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://yourdomain.com"], # Cấu hình đúng domain tại đây
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### 2. HTTPS là bắt buộc
Google OAuth **không cho phép** Redirect URI sử dụng `http` (trừ localhost). Vì vậy, cả Web App và API của bạn bắt buộc phải có chứng chỉ SSL (HTTPS) để đăng nhập Google hoạt động ổn định.

### 3. Namespace Android
Khi đổi tên Package trong `build.gradle.kts` (applicationId), **TUYỆT ĐỐI KHÔNG** dùng dấu gạch ngang `-` (Vd: `com.my-app`). Android chỉ chấp nhận dấu gạch dưới `_`. Nếu dùng dấu `-`, App sẽ bị crash ngay lập tức khi khởi chạy.

### 4. Lỗi dư dấu chấm trong URL
Hãy kiểm tra file `config.dart` trong Flutter. Đảm bảo URL không bị dư dấu chấm ở cuối (Vd: `https://api.domain.com./` là sai). Điều này sẽ khiến WebView không thể so khớp scheme thành công.

### 5. Xử lý lỗi từ Deep Link
Nếu đăng nhập thất bại, Backend có thể trả về: `your_scheme://callback?error=failed`. Bạn nên viết thêm code trong Flutter để bắt tham số `error` này và hiển thị thông báo (Alert) cho người dùng.

### 6. Xóa cache khi Build lại
Nếu bạn thay đổi cấu hình Deep Link trong `AndroidManifest.xml`, hãy chạy lệnh sau để đảm bảo thay đổi được áp dụng:
```bash
flutter clean
flutter pub get
```

---
*Tài liệu hướm dẫn Hybrid App chuyên sâu - Antigravity AI.*
