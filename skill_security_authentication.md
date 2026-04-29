# Kỹ thuật chuyên sâu: Bảo mật & Xác thực toàn diện

Tài liệu này đi sâu vào các lớp bảo mật (Security Layers) bảo vệ tài nguyên hệ thống.

## 1. Cơ chế JWT (JSON Web Token)
Chúng tôi sử dụng JWT để xác thực không lưu trạng thái (Stateless). Token được tạo tại Backend và lưu dưới dạng `Bearer` token ở Frontend.

### Cấu trúc Payload:
```json
{
  "id": 1,
  "username": "admin",
  "email": "admin@example.com",
  "is_admin": true,
  "exp": 1700000000
}
```

### Logic Kiểm tra Token (FastAPI Dependency):
```python
# app/security/security.py
def get_current_user(token: str = Depends(oauth2_scheme)):
    try:
        # Giải mã và kiểm tra chữ ký
        payload = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
        email = payload.get("email")
        
        # Luôn truy vấn lại DB để đảm bảo user chưa bị xóa hoặc đổi quyền
        db = UserDB()
        user = db.get_by_email(email)
        if not user:
            raise HTTPException(status_code=401, detail="User not found")
        return user
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")
```

## 2. Hệ thống Avatar 3 lớp (Fallback Mechanism)
Để tránh tình trạng "vỡ" giao diện khi ảnh lỗi, chúng tôi triển khai logic fallback cực kỳ bền bỉ.

### Lớp 1: Gravatar (Backend)
Nếu người dùng không có ảnh, hệ thống tự sinh mã MD5 từ email để gọi Gravatar.
```python
# app/models/base_db.py
import hashlib

def get_gravatar_url(email: str):
    email_hash = hashlib.md5(email.strip().lower().encode('utf-8')).hexdigest()
    return f"https://www.gravatar.com/avatar/{email_hash}?d=identicon"
```

### Lớp 2: Fallback UI (Frontend)
Sử dụng sự kiện `onError` của thẻ `<img>` để chuyển đổi sang dạng placeholder bằng tên.
```tsx
// frontend/components/AvatarImage.tsx
const AvatarImage = ({ src, name }) => {
  const [error, setError] = useState(false);

  if (error || !src) {
    return <div className="avatar-placeholder">{name[0]}</div>;
  }

  return <img src={src} onError={() => setError(true)} />;
}
```

## 3. Bảo vệ Admin API (RBAC)
Phân quyền dựa trên vai trò (Role-Based Access Control) được thực hiện qua các Dependency lồng nhau. Chúng ta tránh việc check `is_admin` lặp lại trong từng hàm.

```python
# app/security/security.py
from fastapi import Depends, HTTPException

# Lấy User hiện tại (Lớp bảo vệ 1)
def get_current_user(token: str = Depends(oauth2_scheme)):
    payload = verify_token(token)
    user = db.get_user(payload["email"])
    if not user:
        raise HTTPException(status_code=401, detail="User not found")
    return user

# Lọc Admin (Lớp bảo vệ 2 - Kế thừa từ lớp 1)
def get_current_admin(current_user: dict = Depends(get_current_user)):
    if not current_user.get("is_admin"):
        raise HTTPException(status_code=403, detail="Forbidden: Admin access required")
    return current_user

# --- Sử dụng trong Router ---
@router.delete("/admin/users/{user_id}")
async def delete_user(user_id: int, admin: dict = Depends(get_current_admin)):
    # Code chạy tới đây chắc chắn là do Admin thực hiện
    db.delete_user(user_id)
    return {"message": "Success"}
```

## 4. Chống Path Traversal (An toàn file Upload/Download)
Kẻ tấn công thường lạm dụng tham số API để đọc trộm các file hệ thống (ví dụ: `GET /api/v1/download?filename=../../../../etc/passwd`).

Để chặn hoàn toàn lỗi này, chúng ta kết hợp 3 kỹ thuật: `os.path.basename`, kiểm tra File Exists, và Prefix thư mục gốc.

```python
# app/routers/file_upload.py
import os
from fastapi import HTTPException
from fastapi.responses import FileResponse

# Thư mục lưu trữ an toàn định trước
SAFE_STORAGE_DIR = "/utils/download/"

@router.get("/download/{filename}")
async def download_file(filename: str):
    # 1. Triệt tiêu các chuỗi "../" nguy hiểm
    safe_filename = os.path.basename(filename)
    
    # 2. Ráp vào đường dẫn gốc một cách an toàn
    file_path = os.path.join(SAFE_STORAGE_DIR, safe_filename)
    
    # 3. Kiểm tra file tồn tại
    if not os.path.exists(file_path):
         raise HTTPException(status_code=404, detail="File không tồn tại")
         
    return FileResponse(file_path)
```

## 5. Security Checklist
- **Rate Limiting**: AI API cần giới hạn số lượt gọi/phút để tránh spam tốn tiền LLM.
- **CORS Configuration**:
  ```python
  app.add_middleware(
      CORSMiddleware,
      allow_origins=["http://localhost:5173"], # Không nên để "*" ở production
      allow_methods=["*"],
      allow_headers=["*"],
  )
  ```
- **Environment Isolation**: File `.env` phải được đưa vào `.gitignore` để tránh rò rỉ Key lên Git.

---

## 6. Bảo mật JWT Phía Frontend (Frontend Security)

Backend có JWT, nhưng Frontend cũng cần có các lớp bảo vệ tương ứng để hệ thống thực sự an toàn end-to-end.

### 6.1. Sơ đồ Luồng Bảo mật Đầy đủ (Backend ↔ Frontend)

```
[User truy cập /dashboard]
        │
        ▼
[ProtectedRoute kiểm tra]
        │
        ├── Không có token trong localStorage? ──► Redirect /login
        │
        └── Có token?
                │
                ▼
        [Gọi GET /api/v1/auth/me để xác minh]
                │
                ├── Server trả 401? ──► Interceptor xóa token + Redirect /login
                │
                └── Server trả 200 + user info? ──► Cho phép vào /dashboard ✅
```

### 6.2. Lưu Token An toàn

```typescript
// ✅ ĐƠN GIẢN (phù hợp hầu hết dự án):
localStorage.setItem('access_token', token);
// Axios Interceptor sẽ tự lấy và gắn vào mọi request.

// ✅ BẢO MẬT HƠN (dự án production quan trọng):
// Yêu cầu Backend trả token qua Set-Cookie (httpOnly flag).
// Browser tự lưu cookie, JS không thể đọc => chống tấn công XSS hoàn toàn.
// Frontend KHÔNG cần gọi localStorage.setItem() nữa.
// Cookie sẽ tự động được gửi kèm mọi request cùng domain.

// ❌ TUYỆT ĐỐI KHÔNG:
window.__myToken = token; // Biến global - XSS đọc được ngay
sessionStorage.setItem(...) // Mất khi đóng tab, UX kém
```

### 6.3. Kiểm tra Token khi App Khởi động (Token Verification on Load)

Token lưu trong localStorage có thể đã bị revoke phía server (admin ban user, đổi mật khẩu...). Phải xác minh với server khi app load lên, không chỉ kiểm tra sự tồn tại trong localStorage:

```typescript
// Trong AuthContext useEffect:
useEffect(() => {
    const verifyOnStartup = async () => {
        const token = localStorage.getItem('access_token');
        if (!token) { setIsLoading(false); return; }

        try {
            // Gọi API để server xác minh token
            const user = await authApi.getMe(); // GET /api/v1/auth/me
            setUser(user); // Token hợp lệ, lưu thông tin user
        } catch {
            // Token hết hạn hoặc bị revoke → Response Interceptor đã xử lý redirect
            setUser(null);
        } finally {
            setIsLoading(false);
        }
    };
    verifyOnStartup();
}, []);
```

### 6.4. Đồng bộ Đăng xuất giữa nhiều Tab (Multi-Tab Sync)

Nếu user mở app ở 2 tab và logout ở tab 1, tab 2 vẫn còn token trong memory. Dùng `storage` event để đồng bộ:

```typescript
// Trong AuthContext:
useEffect(() => {
    const handleStorageChange = (e: StorageEvent) => {
        // Lắng nghe khi tab khác xóa token (logout)
        if (e.key === 'access_token' && e.newValue === null) {
            setUser(null); // Cập nhật state tab hiện tại
            // React Router sẽ tự redirect qua ProtectedRoute
        }
    };
    window.addEventListener('storage', handleStorageChange);
    return () => window.removeEventListener('storage', handleStorageChange);
}, []);
```

### 6.5. Frontend Security Checklist

| # | Hạng mục | Trạng thái |
|---|----------|------------|
| 1 | JWT được gắn tự động qua **Axios Request Interceptor** | Bắt buộc |
| 2 | Lỗi 401 redirect `/login` qua **Axios Response Interceptor** | Bắt buộc |
| 3 | Token được **xác minh với server** (gọi `/auth/me`) khi app load | Bắt buộc |
| 4 | Route nhạy cảm được bọc bằng `ProtectedRoute` / `AdminRoute` | Bắt buộc |
| 5 | Nút bấm có `disabled` + `isLoading` để chặn double-submit | Bắt buộc |
| 6 | Không hardcode token, không lưu vào `window.*` | Bắt buộc |
| 7 | **Multi-tab logout sync** qua `storage` event | Khuyến nghị |
| 8 | Token lưu trong `httpOnly Cookie` thay vì localStorage | Production cao |

> **Tham khảo thêm**: [`skill_frontend_architecture.md`](./skill_frontend_architecture.md) và [`skill_frontend_routing_components.md`](./skill_frontend_routing_components.md) để xem code mẫu chi tiết.

---

## 7. Hash Mat khau (Password Hashing — bcrypt)

Tuyet doi khong luu mat khau dang plain text vao Database. Su dung `passlib[bcrypt]` de ma hoa mot chieu.

### 7.1. Cau hinh PassLib

```python
# app/security/security.py
from passlib.context import CryptContext

# Khai bao context bao mat — bcrypt la thuat toan khuyen dung nam 2024+
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(plain_password: str) -> str:
    """
    Ma hoa mat khau nguoi dung truoc khi luu vao DB.
    bcrypt tu dong them 'salt' ngau nhien vao moi lan hash —
    cung mot mat khau se cho ra hash khac nhau moi lan, chong Rainbow Table.
    """
    return pwd_context.hash(plain_password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    So sanh mat khau nguoi dung nhap voi hash trong DB.
    Tra ve True neu khop, False neu sai.
    Tuyet doi khong compare bang == truc tiep.
    """
    return pwd_context.verify(plain_password, hashed_password)
```

### 7.2. Su dung khi Dang ky va Dang nhap

```python
# app/routers/auth.py
from app.security.security import hash_password, verify_password, create_access_token
from app.models.schemas import ApiSuccess, ApiError

@router.post("/register")
async def register(data: RegisterPayload):
    if db.get_user_by_email(data.email):
        raise HTTPException(
            status_code=409,
            detail=ApiError(message="Email nay da duoc dang ky", error_code="EMAIL_EXISTS").model_dump()
        )
    # Hash mat khau truoc khi luu — TUYET DOI khong luu plain text
    hashed = hash_password(data.password)
    user_id = db.create_user(data.email, data.username, hashed)
    return ApiSuccess(message="Dang ky thanh cong", data={"user_id": user_id})


@router.post("/login")
async def login(data: LoginPayload):
    user = db.get_user_by_email(data.email)

    # Kiem tra ca hai truong hop cung mot cach xu ly (chong User Enumeration Attack)
    # Neu tra loi khac nhau ("Email sai" vs "Mat khau sai"), ke tan cong biet email ton tai
    if not user or not verify_password(data.password, user["password_hash"]):
        raise HTTPException(
            status_code=401,
            detail=ApiError(message="Email hoac mat khau khong dung").model_dump()
        )

    token = create_access_token({"id": user["id"], "email": user["email"], "is_admin": user["is_admin"]})
    return ApiSuccess(message="Dang nhap thanh cong", data={"token": token, "user": dict(user)})
```

### 7.3. Schema Database cho mat khau

```sql
-- Luu y: Ten truong la password_hash, khong phai password
-- De nhac nho rang gia tri da duoc ma hoa
CREATE TABLE users (
    id      INTEGER PRIMARY KEY,
    email   VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(255),
    password_hash TEXT NOT NULL,   -- Gia tri bcrypt hash, khong bao gio plain text
    is_admin BOOLEAN DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---
*Ghi chu: Moi thay doi ve logic bao mat can phai duoc review cheo boi cac thanh vien khac trong team.*
