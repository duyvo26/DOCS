# Kỹ thuật chuyên sâu: Google OAuth 2.0 (Redirect Flow)

Tài liệu này hướng dẫn chi tiết cách triển khai luồng Đăng nhập Google mượt mà, tránh lỗi hiển thị JSON thô trên trình duyệt.

## 1. Sơ đồ luồng xử lý (Detailed Sequence)

```text
[Browser] ────── 1. Click Login ─────→ [Backend: /google/login]
    ↑                                         ↓
    └─────────── 2. Redirect 302 ──────── [Google Auth Screen]
                                              ↓
[Backend: /callback] ←── 3. Redirect w/ Code ──┘
    ↓
    ├─ 4. Đổi Code lấy User Info từ Google
    ├─ 5. Tạo JWT Token của hệ thống
    └─ 6. Redirect 302 kèm Token ──────→ [Frontend: /?token=...]
                                              ↓
[Frontend: App.tsx] ←─── 7. Lưu Token ────────┘
```

## 2. Mã triển khai Backend (FastAPI)

Điểm then chốt là sử dụng `RedirectResponse` ở bước cuối cùng.

```python
# app/routers/auth.py
from fastapi.responses import RedirectResponse

@router.get("/google/callback")
async def google_callback(code: str):
    # ... logic lấy email, name từ Google API ...
    
    # Tạo JWT token
    token = create_access_token({"id": user["id"], "email": user["email"]})
    
    # REDIRECT người dùng quay lại giao diện React
    # settings.FRONTEND_URL thường là http://localhost:5173
    return RedirectResponse(url=f"{settings.FRONTEND_URL}/?token={token}")
```

## 3. Mã triển khai Frontend (React)

Tại component gốc (`App.tsx`), chúng ta cần một `useEffect` chạy ngay khi app khởi động để "hứng" token từ URL.

```tsx
// frontend/App.tsx
useEffect(() => {
  // 1. Phân tích URL để tìm params 'token'
  const params = new URLSearchParams(window.location.search);
  const tokenFromUrl = params.get('token');
  
  if (tokenFromUrl) {
    // 2. Lưu vào máy để dùng cho các request sau
    localStorage.setItem('access_token', tokenFromUrl);
    
    // 3. CLEAN UP: Xóa token khỏi URL để link trông gọn gàng và an toàn
    window.history.replaceState({}, document.title, window.location.pathname);
    
    // 4. Load thông tin profile user
    fetchUserInfor();
  }
}, []);
```

## 4. Tại sao dùng Redirect Flow thay vì AJAX?
- **An toàn**: Tránh được các lỗi CORS phức tạp khi Google redirect về backend.
- **Trải nghiệm**: Người dùng không nhìn thấy các trang JSON thô.
- **Mượt mà**: Cảm giác như đang dùng một ứng dụng Native, quá trình chuyển đổi giữa Google -> Backend -> Frontend diễn ra tự động.

## 5. Cấu hình Scopes
Để lấy được đầy đủ thông tin Avatar và Email, bạn phải đảm bảo đã yêu cầu 3 scopes:
- `openid`
- `email`
- `profile`

---

## 6. Cấu hình Biến Môi trường (.env)

Để luồng đăng nhập hoạt động, bạn cần cấu hình các tham số sau trong file `.env` của Backend. Việc hiểu đúng ý nghĩa từng tham số rất quan trọng:

```env
# ID Định danh của ứng dụng trên Google Cloud Console. 
# Cho Google biết ứng dụng nào đang yêu cầu đăng nhập.
GOOGLE_CLIENT_ID=xxxxxxxxxxxxxxxxxxxxxxxx

# Chìa khóa bí mật để xác thực Backend của bạn với Google.
# TUYỆT ĐỐI KHÔNG để lộ lên Frontend hoặc Github.
GOOGLE_CLIENT_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Đường dẫn URL MÀ GOOGLE SẼ GỌI VỀ sau khi user chọn tài khoản xong.
# Bắt buộc phải trùng khớp 100% với URL đã khai báo trong "Authorized redirect URIs" trên Google Cloud.
# Ví dụ: http://localhost:2643/api/v1/auth/google/callback
GOOGLE_REDIRECT_URI=https://yourdomain.com/api/v1/auth/google/callback

# Đường dẫn gốc của Frontend (React/Vue). 
# Backend sẽ dùng URL này ở bước cuối cùng (bước 6) để Redirect user quay lại giao diện web kèm theo Token.
FRONTEND_URL=http://localhost:5173
```
