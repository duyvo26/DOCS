# Ky thuat chuyen sau: Logging & Monitoring Chuan (Structured Logging)

Tai lieu nay quy dinh cach cau hinh va su dung logging co cau truc trong toan bo du an. Tuyet doi khong dung `print()` de debug trong code production.

---

## 1. Tai sao khong dung `print()`?

| Van de voi print() | Giai phap voi logging |
|---|---|
| Khong co muc do (debug/info/error) | Co 5 muc: DEBUG, INFO, WARNING, ERROR, CRITICAL |
| Khong biet dong code nao in ra | Tu dong ghi ten file, ten ham, so dong |
| Khong the tat khi deploy | Co the tat/mo theo moi truong (dev/production) |
| Khong luu vao file log | Co the ghi file, ghi DB, gui alert |
| In ra lẫn lộn tat ca | Co the loc theo module, muc do |

---

## 2. Cau hinh Logger Chuan (Backend Python)

Tao mot file cau hinh logger dung chung cho toan bo du an, dat trong `app/logger.py`.

```python
# app/logger.py
import logging
import sys
from logging.handlers import RotatingFileHandler
import os

def get_logger(name: str) -> logging.Logger:
    """
    Tao va tra ve mot logger da duoc cau hinh chuan.
    Moi module goi ham nay voi __name__ de co logger rieng, de loc log.

    Args:
        name: Ten logger, thuong truyen __name__ cua module goi.

    Returns:
        Logger da cau hinh voi console handler va file handler.
    """
    logger = logging.getLogger(name)

    # Tranh them handler trung lap neu ham duoc goi nhieu lan
    if logger.handlers:
        return logger

    log_level = logging.DEBUG if os.getenv("ENV", "production") == "development" else logging.INFO
    logger.setLevel(log_level)

    # Format chuan: thoi gian - ten module - muc do - noi dung
    formatter = logging.Formatter(
        fmt="%(asctime)s | %(name)-30s | %(levelname)-8s | %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S"
    )

    # Handler 1: In ra console (stdout)
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setFormatter(formatter)
    logger.addHandler(console_handler)

    # Handler 2: Ghi ra file (tu dong xoay vong khi qua 5MB, giu toi da 3 file)
    log_dir = os.path.join(os.getenv("DIR_ROOT", "."), "utils", "logs")
    os.makedirs(log_dir, exist_ok=True)
    file_handler = RotatingFileHandler(
        filename=os.path.join(log_dir, "app.log"),
        maxBytes=5 * 1024 * 1024,  # 5MB moi file
        backupCount=3,
        encoding="utf-8"
    )
    file_handler.setFormatter(formatter)
    logger.addHandler(file_handler)

    return logger
```

---

## 3. Cach su dung Logger trong tung Module

```python
# app/routers/auth.py
from app.logger import get_logger

# Moi file tao logger rieng voi __name__ de de loc
logger = get_logger(__name__)

@router.post("/login")
async def login(data: LoginPayload):
    logger.info(f"Yeu cau dang nhap cho email: {data.email}")

    try:
        user = db.get_user_by_email(data.email)
        if not user:
            logger.warning(f"Dang nhap that bai — Email khong ton tai: {data.email}")
            raise HTTPException(status_code=401, detail="Sai thong tin dang nhap")

        logger.info(f"Dang nhap thanh cong cho user ID: {user['id']}")
        return {"token": create_token(user)}

    except Exception as e:
        # Chi log ERROR khi co loi thuc su, khong log moi thu
        logger.error(f"Loi khong mong doi khi dang nhap: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="Loi he thong")
```

---

## 4. Muc do Log va Khi nao Dung

| Muc do | Ham | Dung khi nao |
|---|---|---|
| DEBUG | `logger.debug()` | Thong tin chi tiet de debug, chi bat khi phat trien (`ENV=development`) |
| INFO | `logger.info()` | Cac su kien quan trong binh thuong: dang nhap, tao task, thanh toan OK |
| WARNING | `logger.warning()` | Co dieu bat thuong nhung app van chay duoc: sai mat khau, het han token |
| ERROR | `logger.error()` | Co loi xay ra, mot tinh nang khong hoat dong duoc |
| CRITICAL | `logger.critical()` | Loi nghiem trong, app co nguy co sap: khong ket noi duoc DB |

### Quy tac chon muc do:
```python
# DEBUG: Du lieu trung gian trong qua trinh xu ly — chi bat o dev
logger.debug(f"Ket qua tra ve tu FAISS: {len(docs)} tai lieu, query='{query[:50]}'")

# INFO: Su kien binh thuong can theo doi
logger.info(f"Task {task_id} bat dau xu ly cho user {user_id}")
logger.info(f"Task {task_id} hoan thanh. Thoi gian: {elapsed:.2f}s")

# WARNING: Bat thuong nhung khong phai loi
logger.warning(f"Rate limit: User {user_id} da goi {count} lan trong 1 phut")

# ERROR: Loi xay ra, can xu ly
logger.error(f"Khong the ket noi AI API sau {MAX_RETRIES} lan thu: {str(e)}", exc_info=True)
```

---

## 5. Them Bien Moi truong cho Logging

Them vao file `.env` va `.env.example`:
```env
# Logging
ENV=development
# Cac gia tri: development (DEBUG log) hoac production (INFO log)
```

---

## 6. Xem Log khi Deploy (Production)

```bash
# Xem log truc tiep (real-time)
tail -f utils/logs/app.log

# Tim kiem loi trong log
grep "ERROR" utils/logs/app.log

# Tim log theo ngay
grep "2026-04-29" utils/logs/app.log | grep "ERROR"

# Xem 50 dong log cuoi
tail -n 50 utils/logs/app.log
```

---

## 7. Cap nhat .gitignore cho thu muc logs

Them vao file `.gitignore`:
```text
# Log files
utils/logs/
*.log
```

---

## 8. Quy tac Logging Bat buoc

- Moi file module BAT BUOC khai bao `logger = get_logger(__name__)` o dau file.
- KHONG dung `print()` trong bat ky file nao duoc commit.
- Log phai co context: ten user, task_id, email hoac du lieu dinh danh de truy vet.
- KHONG log mat khau, token, API key — chi log ID hoac email.
- Dung `exc_info=True` khi log ERROR de ghi full stack trace vao file log.
