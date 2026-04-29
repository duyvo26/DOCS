# Ky thuat chuyen sau: Chuan API Response (Standard API Response Format)

Tai lieu nay quy dinh cau truc JSON bat buoc cho moi Endpoint trong he thong. Chuan hoa response giup Frontend xu ly du lieu nhat quan, de debug, va de mo rong sau nay.

---

## 1. Nguyen tac Chung

- Moi response — thanh cong hay loi — deu co cau truc JSON thong nhat.
- Truong `success` (boolean) giup Frontend phan biet ngay ma khong can kiem tra HTTP status code.
- Truong `data` chua ket qua thuc su khi thanh cong.
- Truong `error` chua thong tin loi khi that bai.
- KHONG tra ve ket qua thay doi: lan nay tra `{"user": ...}`, lan kia tra `{"data": {"user": ...}}`.

---

## 2. Cac Pydantic Schema Chuan

Dinh nghia tap trung trong `app/models/schemas.py`:

```python
# app/models/schemas.py
from pydantic import BaseModel
from typing import Any, Optional, List

class ApiSuccess(BaseModel):
    """
    Wrapper chuan cho moi response thanh cong.
    Frontend luon kiem tra success=True truoc khi doc data.
    """
    success: bool = True
    message: str = "Thanh cong"
    data: Optional[Any] = None

class ApiError(BaseModel):
    """
    Wrapper chuan cho moi response loi.
    Dung kem voi HTTPException hoac Exception handler.
    """
    success: bool = False
    message: str
    error_code: Optional[str] = None  # Ma loi noi bo de debug (vi du: "USER_NOT_FOUND")

class PaginatedData(BaseModel):
    """
    Wrapper cho cac API co phan trang (list users, list transactions...).
    """
    items: List[Any]
    total: int         # Tong so ban ghi
    page: int          # Trang hien tai (bat dau tu 1)
    page_size: int     # So ban ghi moi trang
    total_pages: int   # Tong so trang
```

---

## 3. Vi du su dung trong Router

```python
# app/routers/auth.py
from app.models.schemas import ApiSuccess, ApiError

@router.post("/login")
async def login(data: LoginPayload, db: UserDB = Depends(get_db)):
    user = db.get_user_by_email(data.email)
    if not user:
        # Loi nghiep vu: Dung 400/401, khong phai 500
        raise HTTPException(
            status_code=401,
            detail=ApiError(
                message="Email hoac mat khau khong dung",
                error_code="INVALID_CREDENTIALS"
            ).model_dump()
        )

    token = create_access_token(user)

    # Thanh cong: Luon boc vao ApiSuccess
    return ApiSuccess(
        message="Dang nhap thanh cong",
        data={
            "token": token,
            "user": {
                "id": user["id"],
                "email": user["email"],
                "is_admin": user["is_admin"]
            }
        }
    )

# Vi du API co phan trang
@router.get("/admin/users")
async def list_users(page: int = 1, page_size: int = 20):
    users, total = db.get_users_paginated(page, page_size)
    return ApiSuccess(
        data=PaginatedData(
            items=users,
            total=total,
            page=page,
            page_size=page_size,
            total_pages=(total + page_size - 1) // page_size
        )
    )
```

---

## 4. Global Exception Handler (Bat loi toan cuc)

Them vao `app/main.py` de dam bao moi loi khong mong doi deu tra ve JSON chuan:

```python
# app/main.py
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from app.models.schemas import ApiError
from app.logger import get_logger

logger = get_logger(__name__)
app = FastAPI()

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    """
    Bat tat ca loi khong co trong code (loi bat ngo).
    Dam bao nguoi dung luon nhan duoc JSON, khong bao gio nhan HTML error page.
    """
    logger.error(
        f"Loi khong mong doi tai {request.method} {request.url}: {exc}",
        exc_info=True
    )
    return JSONResponse(
        status_code=500,
        content=ApiError(
            message="Loi he thong. Vui long thu lai sau.",
            error_code="INTERNAL_SERVER_ERROR"
        ).model_dump()
    )

@app.exception_handler(HTTPException)
async def http_exception_handler(request: Request, exc: HTTPException):
    """
    Chuan hoa tat ca HTTPException sang ApiError format.
    Khac phuc truong hop FastAPI mac dinh tra {"detail": "..."} thay vi {"success": false, ...}.
    """
    return JSONResponse(
        status_code=exc.status_code,
        content=exc.detail if isinstance(exc.detail, dict)
                else ApiError(message=str(exc.detail)).model_dump()
    )
```

---

## 5. Chuan JSON Tra ve — Tom tat

### Response Thanh cong (200 / 201):
```json
{
    "success": true,
    "message": "Dang nhap thanh cong",
    "data": {
        "token": "eyJhbGci...",
        "user": { "id": 1, "email": "user@example.com" }
    }
}
```

### Response Loi Nghiep vu (400 / 401 / 403 / 404):
```json
{
    "success": false,
    "message": "Email hoac mat khau khong dung",
    "error_code": "INVALID_CREDENTIALS"
}
```

### Response Loi He thong (500):
```json
{
    "success": false,
    "message": "Loi he thong. Vui long thu lai sau.",
    "error_code": "INTERNAL_SERVER_ERROR"
}
```

### Response Co Phan trang:
```json
{
    "success": true,
    "message": "Thanh cong",
    "data": {
        "items": [ ... ],
        "total": 150,
        "page": 2,
        "page_size": 20,
        "total_pages": 8
    }
}
```

---

## 6. Cach Frontend Doc Response Chuan nay

```typescript
// frontend/src/services/api.ts
// Voi chuan tren, moi API call co the duoc doc nhat quan:

const login = async (email: string, password: string) => {
    const response = await apiClient.post('/auth/login', { email, password });
    // response.data la ApiSuccess object
    // response.data.data.token la JWT token
    const { token, user } = response.data.data;
    return { token, user };
};

// Neu loi, Axios se throw va Interceptor bat -> redirect /login neu 401
// Neu loi khac, component dung try/catch de hien thi response.data.message
```

---

## 7. HTTP Status Code Chuan Dung

| Status | Khi nao dung |
|---|---|
| 200 OK | Thanh cong, GET / PUT / DELETE thanh cong |
| 201 Created | Tao moi thanh cong (POST tao ban ghi) |
| 400 Bad Request | Dau vao sai (validation fail, thieu truong) |
| 401 Unauthorized | Chua dang nhap, token sai / het han |
| 403 Forbidden | Da dang nhap nhung khong co quyen (non-admin) |
| 404 Not Found | Tai nguyen khong ton tai |
| 409 Conflict | Trung lap du lieu (email da ton tai khi dang ky) |
| 422 Unprocessable | Pydantic validation loi (FastAPI tu xu ly) |
| 500 Internal Error | Loi he thong khong mong doi |
