# Skill: Logging & Monitoring Chuẩn (Structured Logging)

## Mục tiêu

Cấu hình và sử dụng logging có cấu trúc trong toàn bộ dự án. Cấm dùng `print()` trong code production.

---

## 1. Tại sao không dùng `print()`?

| print() | logging |
|---------|---------|
| Không có mức độ | 5 mức: DEBUG, INFO, WARNING, ERROR, CRITICAL |
| Không biết dòng code nào in | Tự ghi tên file, tên hàm, số dòng |
| Không thể tắt khi deploy | Tắt/mở theo môi trường (dev/production) |
| Không lưu vào file log | Ghi file, RotatingFileHandler |

---

## 2. Cấu hình Logger Chuẩn

Tạo `app/logger.py`:

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

## 3. Sử dụng trong Module

```python
from app.logger import get_logger
logger = get_logger(__name__)

logger.info(f"Task {task_id} bat dau")
logger.warning(f"Rate limit: {count} lan/phut")
logger.error(f"Loi ket noi AI: {e}", exc_info=True)
```

---

## 4. Mức độ Log

| Mức độ | Dùng khi |
|--------|----------|
| DEBUG | Chi tiết debug, chỉ bật ở dev |
| INFO | Sự kiện bình thường: login, tạo task |
| WARNING | Bất thường nhưng app vẫn chạy |
| ERROR | Lỗi xảy ra, tính năng không hoạt động |
| CRITICAL | Lỗi nghiêm trọng, app có nguy cơ sập |

---

## Quy tắc bắt buộc

1. Mọi file module BẮT BUỘC khai báo `logger = get_logger(__name__)`.
2. KHÔNG dùng `print()` trong code production.
3. Log phải có context: user_id, task_id, email.
4. KHÔNG log mật khẩu, token, API key.
5. Dùng `exc_info=True` khi log ERROR.
6. File log nằm trong `utils/logs/` (đã ignore trong .gitignore).

---

## File liên quan

- [Cấu trúc Dự án Tiêu chuẩn (Skill DuyVo26)](./skill_project_structure.md)
- [Cấu hình Môi trường (.env)](./skill_env_configuration.md)
- [Tiêu chuẩn Viết Code (Coding Conventions)](./skill_coding_conventions.md)
