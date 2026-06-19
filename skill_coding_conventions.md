# Skill: Tiêu chuẩn Viết Code & Đặt tên (Coding Conventions)

## Mục tiêu

Quy định các quy tắc chuẩn mực khi viết code, đặt tên biến, tên hàm, và tiêu chuẩn định dạng cho cả Backend (Python) và Frontend (TypeScript). Giúp AI Agent và Developer làm việc nhóm đồng bộ và tránh lỗi.

---

## 1. Tiêu chuẩn Backend (Python / FastAPI)

### 1.1. Quy tắc đặt tên
| Loại | Đúng | Sai |
|------|------|-----|
| Class | `PascalCase`: `DocumentGrader`, `AuthRouter` | `documentGrader` |
| Function/Method | `snake_case`: `get_user_by_id()` | `GetUserById()` |
| Variable | `snake_case`: `retry_count` | `retryCount` |
| Constant | `UPPER_SNAKE_CASE`: `MAX_RETRIES_RAG` | `maxRetriesRag` |

### 1.2. Type Hinting
Bắt buộc cho tất cả tham số và kết quả trả về.

### 1.3. Tiếng Anh vs Tiếng Việt
- Logic hệ thống: bắt buộc Tiếng Anh
- Nghiệp vụ đặc thù: được dùng Tiếng Việt (không dấu)

---

## 2. Tiêu chuẩn Frontend (React / TypeScript)

### 2.1. Quy tắc đặt tên
- Component: `PascalCase`, file cùng tên: `AuthView.tsx`
- Interface/Type: `PascalCase`
- Function/Variable: `camelCase`: `handleGoogleLogin`
- Boolean: bắt đầu bằng `is`, `has`, `should`, `can`

### 2.2. Tránh Hardcode
Dùng `import.meta.env.VITE_*`, không hardcode URL.

---

## 3. Docstring & JSDoc

### 3.1. Python — Google Style Docstring
Bắt buộc cho mọi class và function có logic phức tạp.

```python
def evaluate(self, context: str) -> dict:
    """
    Mo ta chuc nang, giai thich "Tai sao".

    Args:
        context (str): Mo ta tham so

    Returns:
        dict: Mo ta ket qua tra ve

    Raises:
        ValueError: Khi nao xay ra loi
    """
    pass
```

### 3.2. TypeScript — JSDoc
```typescript
/**
 * Mo ta chuc nang chinh.
 * @param {string} id - Mo ta tham so
 * @returns {Promise<void>} Mo ta ket qua
 */
const handleAction = async (id: string): Promise<void> => {}
```

---

## 4. Quản lý Lỗi

- Backend: Dùng `logger.error`, không dùng `print`
- Frontend: Dùng Optional Chaining `?.` và Nullish Coalescing `??`

---

## 5. Quy tắc Inline Comment

Comment "Why" (Tại sao), không phải "What" (Làm gì).
Bắt buộc cho: magic number, workaround, regex phức tạp.

---

## 6. Quy tắc Đặt tên File

- Python: `snake_case.py`
- TypeScript Component: `PascalCase.tsx`
- TypeScript Util: `camelCase.ts`

---

## 7. Quy tắc Cấm Emoji

Cấm tuyệt đối emoji trong code, markdown, config, comment.

---

## 8. Git Workflow & Commit Convention

Format: `<type>(<scope>): <mo ta>`

Branching:
```
main -> dev -> feature/..., fix/..., refactor/...
```

---

## File liên quan

- [Cấu trúc Dự án Tiêu chuẩn (Skill DuyVo26)](./skill_project_structure.md)
- [Logging & Monitoring](./skill_logging_monitoring.md)
- [Chuẩn API Response](./skill_api_response_standard.md)
- [Codebase Mapper](./skill_codebase_mapper.md)
