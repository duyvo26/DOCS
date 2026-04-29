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
*Ghi chú: Mọi thay đổi về logic bảo mật cần phải được review chéo bởi các thành viên khác trong team.*
