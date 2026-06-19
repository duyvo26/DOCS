# Skill: Logging & Monitoring Chuan (Structured Logging)

## Muc tieu

Cau hinh va su dung logging co cau truc trong toan bo du an. Cam dung `print()` trong code production.

---

## 1. Tai sao khong dung `print()`?

| print() | logging |
|---------|---------|
| Khong co muc do | 5 muc: DEBUG, INFO, WARNING, ERROR, CRITICAL |
| Khong biet dong code nao in | Tu ghi ten file, ten ham, so dong |
| Khong the tat khi deploy | Tat/mo theo moi truong (dev/production) |
| Khong luu vao file log | Ghi file, RotatingFileHandler |

---

## 2. Cau hinh Logger Chuan

Tao `app/logger.py`:

```python
def get_logger(name: str) -> logging.Logger:
    logger = logging.getLogger(name)
    if logger.handlers:
        return logger
    log_level = logging.DEBUG if os.getenv("ENV") == "development" else logging.INFO
    logger.setLevel(log_level)
    formatter = logging.Formatter("%(asctime)s | %(name)-30s | %(levelname)-8s | %(message)s")
    logger.addHandler(logging.StreamHandler(sys.stdout))
    logger.addHandler(RotatingFileHandler("utils/logs/app.log", maxBytes=5*1024*1024, backupCount=3))
    return logger
```

---

## 3. Su dung trong Module

```python
from app.logger import get_logger
logger = get_logger(__name__)

logger.info(f"Task {task_id} bat dau")
logger.warning(f"Rate limit: {count} lan/phut")
logger.error(f"Loi ket noi AI: {e}", exc_info=True)
```

---

## 4. Muc do Log

| Muc do | Dung khi |
|--------|----------|
| DEBUG | Chi tiet debug, chi bat o dev |
| INFO | Su kien binh thuong: login, tao task |
| WARNING | Bat thuong nhung app van chay |
| ERROR | Loi xay ra, tinh nang khong hoat dong |
| CRITICAL | Loi nghiem trong, app co nguy co sap |

---

## Quy tac bat buoc

1. Moi file module BAT BUOC khai bao `logger = get_logger(__name__)`.
2. KHONG dung `print()` trong code production.
3. Log phai co context: user_id, task_id, email.
4. KHONG log mat khau, token, API key.
5. Dung `exc_info=True` khi log ERROR.
6. File log nam trong `utils/logs/` (da ignore trong .gitignore).

---

## File lien quan

- [Cau truc Du an Tieu chuan (Skill DuyVo26)](./skill_project_structure.md)
- [Cau hinh Moi truong (.env)](./skill_env_configuration.md)
- [Tieu chuan Viet Code (Coding Conventions)](./skill_coding_conventions.md)
