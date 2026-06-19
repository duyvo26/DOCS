# Skill: Chuẩn API Response (Standard API Response Format)

## Mục tiêu

Quy định cấu trúc JSON bắt buộc cho mọi Endpoint trong hệ thống. Chuẩn hóa response giúp Frontend xử lý dữ liệu nhất quán, dễ debug, và dễ mở rộng.

---

## 1. Nguyên tắc Chung

- Mọi response — thành công hay lỗi — đều có cấu trúc JSON thống nhất.
- Trường `success` (boolean) giúp Frontend phân biệt ngay mà không cần kiểm tra HTTP status code.
- Trường `data` chứa kết quả thực sự khi thành công.
- Trường `error` chứa thông tin lỗi khi thất bại.
- KHÔNG trả về kết quả thay đổi: lần này trả `{"user": ...}`, lần kia trả `{"data": {"user": ...}}`.

---

## 2. Các Pydantic Schema Chuẩn

Định nghĩa tập trung trong `app/models/schemas.py`:

```python
class ApiSuccess(BaseModel):
    success: bool = True
    message: str = "Thanh cong"
    data: Optional[Any] = None

class ApiError(BaseModel):
    success: bool = False
    message: str
    error_code: Optional[str] = None

class PaginatedData(BaseModel):
    items: List[Any]
    total: int
    page: int
    page_size: int
    total_pages: int
```

---

## 3. Sử dụng trong Router

```python
@router.post("/login")
async def login(data: LoginPayload, db: UserDB = Depends(get_db)):
    user = db.get_user_by_email(data.email)
    if not user:
        raise HTTPException(status_code=401, detail=ApiError(message="Sai thong tin").model_dump())
    token = create_access_token(user)
    return ApiSuccess(data={"token": token, "user": {...}})
```

---

## 4. Global Exception Handler

Thêm vào `app/main.py` để đảm bảo mọi lỗi đều trả về JSON chuẩn:

```python
@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    logger.error(f"Loi tai {request.method} {request.url}: {exc}")
    return JSONResponse(status_code=500, content=ApiError(message="Loi he thong").model_dump())
```

---

## Quy tắc bắt buộc

1. Mọi Endpoint bắt buộc trả về `ApiSuccess` hoặc `ApiError`.
2. KHÔNG trả về raw dict hoặc list.
3. Dùng `HTTPException` cho lỗi nghiệp vụ, `global_exception_handler` cho lỗi bất ngờ.
4. Frontend luôn kiểm tra `success` trước khi đọc `data`.
5. Status code chuẩn: 200 OK, 201 Created, 400 Bad Request, 401 Unauthorized, 403 Forbidden, 404 Not Found, 500 Internal Error.

---

## File liên quan

- [Cấu trúc Dự án Tiêu chuẩn (Skill DuyVo26)](./skill_project_structure.md)
- [Tiêu chuẩn Viết Code (Coding Conventions)](./skill_coding_conventions.md)
- [Bảo mật & Xác thực](./skill_security_authentication.md)
