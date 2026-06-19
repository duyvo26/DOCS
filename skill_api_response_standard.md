# Skill: Chuan API Response (Standard API Response Format)

## Muc tieu

Quy dinh cau truc JSON bat buoc cho moi Endpoint trong he thong. Chuan hoa response giup Frontend xu ly du lieu nhat quan, de debug, va de mo rong.

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

## 3. Su dung trong Router

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

Them vao `app/main.py` de dam bao moi loi deu tra ve JSON chuan:

```python
@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    logger.error(f"Loi tai {request.method} {request.url}: {exc}")
    return JSONResponse(status_code=500, content=ApiError(message="Loi he thong").model_dump())
```

---

## Quy tac bat buoc

1. Moi Endpoint bat buoc tra ve `ApiSuccess` hoac `ApiError`.
2. KHONG tra ve raw dict hoac list.
3. Dung `HTTPException` cho loi nghiep vu, `global_exception_handler` cho loi bat ngo.
4. Frontend luon kiem tra `success` truoc khi doc `data`.
5. Status code chuan: 200 OK, 201 Created, 400 Bad Request, 401 Unauthorized, 403 Forbidden, 404 Not Found, 500 Internal Error.

---

## File lien quan

- [Cau truc Du an Tieu chuan (Skill DuyVo26)](./skill_project_structure.md)
- [Tieu chuan Viet Code (Coding Conventions)](./skill_coding_conventions.md)
- [Bao mat & Xac thuc](./skill_security_authentication.md)
