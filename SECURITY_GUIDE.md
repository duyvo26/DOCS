# Hướng dẫn Hệ thống Bảo mật (Security & Auth Guide)

Tài liệu này mô tả các biện pháp bảo mật, xác thực và phân quyền được áp dụng trong dự án Bloom.

## 1. Xác thực người dùng (Authentication)

Ứng dụng sử dụng **Google OAuth 2.0** làm phương thức đăng nhập duy nhất để đảm bảo an toàn và tiện lợi. Xem chi tiết cách cấu hình tại [Hướng dẫn cấu hình Google Login](./GOOGLE_LOGIN_GUIDE.md).

### Quy trình (Flow):
1. **Frontend**: Yêu cầu link login từ `/api/v1/auth/google/login`.
2. **Google**: Người dùng xác nhận danh tính qua Google Consent Screen.
3. **Backend Callback**: 
    - Nhận `code` từ Google.
    - Trao đổi lấy `access_token` và thông tin người dùng (email, name, picture).
    - Tạo người dùng mới (nếu chưa có) và cấp 1 lượng Token miễn phí.
    - Tạo **JWT (JSON Web Token)** từ phía server để duy trì phiên làm việc.

### Cấu trúc JWT:
- **Thuật toán**: HS256.
- **Payload**: `{ "user_id": int, "email": string, "exp": timestamp }`.
- **Secret**: Được lưu trong biến môi trường `JWT_SECRET_KEY`.

---

## 2. Phân quyền (Authorization)

Hệ thống sử dụng cơ chế **Dependency Injection** của FastAPI để kiểm soát truy cập.

- **`get_current_user`**: Yêu cầu token hợp lệ trong header `Authorization: Bearer <token>`.
- **`get_current_admin`**: Kiểm tra thêm thuộc tính `is_admin` của người dùng.
- **`require_tokens(amount)`**: Một decorator/dependency đặc biệt dùng để kiểm tra số dư Token của người dùng trước khi thực hiện các tác vụ nặng (như chạy pipeline Bloom).

```python
@router.post("/run")
async def run_task(
    payload: BloomTaskRequest,
    current_user: dict = Depends(require_tokens(10)) # Yêu cầu 10 tokens
):
    # Logic...
```

---

## 3. Bảo mật File và Dữ liệu (File & Data Security)

### Chống Path Traversal
Tất cả các endpoint liên quan đến file (upload/download/view) đều được xử lý để ngăn chặn việc truy cập trái phép vào các thư mục hệ thống qua các chuỗi như `../`.

```python
# app/routers/file_upload.py
safe_filename = os.path.basename(filename) # Xóa bỏ mọi đường dẫn, chỉ lấy tên file
file_path = os.path.join(settings.DIR_ROOT, "utils", "download", safe_filename)
```

### Kiểm tra quyền sở hữu File (Ownership)
Đối với các file kết quả (kết quả chạy AI), hệ thống kiểm tra xem người yêu cầu có phải là người đã tạo ra tác vụ đó hay không bằng cách truy vấn DB.

```python
# Chỉ cho phép tải nếu là chủ sở hữu hoặc admin
is_owner = False
for task in user_history:
    if f"/bloom/{safe_uid}/" in task["result_url"]:
        is_owner = True
        break

if not is_owner and not current_user["is_admin"]:
    raise HTTPException(status_code=403, detail="Access denied")
```

---

## 4. Bảo mật API Admin

- Các API tại `/api/v1/admin/*` được bảo vệ nghiêm ngặt bởi `get_current_admin`.
- **Quản lý cấu hình**: Các thông số như `rate_per_1000`, `logo_url`, `site_title`, `seo_author` được quản lý tập trung và đồng bộ hóa an toàn với file vật lý `index.html`.
- **Cơ chế ghi file**: Backend sử dụng Regex an toàn để chỉ thay đổi nội dung bên trong các thẻ HTML được chỉ định, tránh làm hỏng cấu trúc mã nguồn.

## 5. Các đoạn mã bảo mật

### Bảo mật Admin Route
```python
@router.post("/settings")
async def update_settings(
    data: SettingsUpdate, 
    admin: dict = Depends(get_current_admin) # Chỉ Admin mới vào được
):
    # Logic update...
```

### Chống Path Traversal (Upload Logo)
```python
@router.post("/upload-logo")
async def upload_logo(file: UploadFile = File(...)):
    # os.path.basename đảm bảo tên file không chứa đường dẫn nguy hiểm
    filename = f"logo_{uuid.uuid4().hex}{os.path.splitext(file.filename)[1]}"
    safe_name = os.path.basename(filename) 
    # Lưu vào thư mục download cố định...
```

## 6. Hướng dẫn cho Developer/LLM

### Thực hiện các API call từ Client
Mọi yêu cầu (trừ login/callback) đều phải đính kèm header:
`Authorization: Bearer <JWT_TOKEN>`

### Thêm một route mới cần bảo mật
Sử dụng `Depends(get_current_user)` làm tham số của function:
```python
@router.get("/protected-route")
async def secret_data(user: dict = Depends(get_current_user)):
    return {"data": "Only for logged in users"}
```

### Nguyên tắc vàng:
1. **Không bao giờ** trả về thông tin nhạy cảm của người dùng khác.
2. **Luôn sử dụng** `os.path.basename()` khi làm việc với file paths từ người dùng.
3. **Luôn kiểm tra** `token_balance` trước khi chạy các tác vụ tiêu tốn tài nguyên.
4. **Không cứng mã** (Hardcode) các secret key vào mã nguồn.
