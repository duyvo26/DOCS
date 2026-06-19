# Skill: Tieu chuan Viet Code & Dat ten (Coding Conventions)

## Muc tieu

Quy dinh cac quy tac chuan muc khi viet code, dat ten bien, ten ham, va tieu chuan dinh dang cho ca Backend (Python) va Frontend (TypeScript). Giups AI Agent va Developer lam viec nhom dong bo va tranh loi.

---

## 1. Tieu chuan Backend (Python / FastAPI)

### 1.1. Quy tac dat ten
| Loai | Dung | Sai |
|------|------|-----|
| Class | `PascalCase`: `DocumentGrader`, `AuthRouter` | `documentGrader` |
| Function/Method | `snake_case`: `get_user_by_id()` | `GetUserById()` |
| Variable | `snake_case`: `retry_count` | `retryCount` |
| Constant | `UPPER_SNAKE_CASE`: `MAX_RETRIES_RAG` | `maxRetriesRag` |

### 1.2. Type Hinting
Bat buoc cho tat ca tham so va ket qua tra ve.

### 1.3. Tieng Anh vs Tieng Viet
- Logic he thong: bat buoc Tieng Anh
- Nghiep vu dac thu: duoc dung Tieng Viet (khong dau)

---

## 2. Tieu chuan Frontend (React / TypeScript)

### 2.1. Quy tac dat ten
- Component: `PascalCase`, file cung ten: `AuthView.tsx`
- Interface/Type: `PascalCase`
- Function/Variable: `camelCase`: `handleGoogleLogin`
- Boolean: bat dau bang `is`, `has`, `should`, `can`

### 2.2. Tranh Hardcode
Dung `import.meta.env.VITE_*`, khong hardcode URL.

---

## 3. Docstring & JSDoc

### 3.1. Python — Google Style Docstring
Bat buoc cho moi class va function co logic phuc tap.

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

## 4. Quan ly Loi

- Backend: Dung `logger.error`, khong dung `print`
- Frontend: Dung Optional Chaining `?.` va Nullish Coalescing `??`

---

## 5. Quy tac Inline Comment

Comment "Why" (Tai sao), khong phai "What" (Lam gi).
Bat buoc cho: magic number, workaround, regex phuc tap.

---

## 6. Quy tac Dat ten File

- Python: `snake_case.py`
- TypeScript Component: `PascalCase.tsx`
- TypeScript Util: `camelCase.ts`

---

## 7. Quy tac Cam Emoji

Cam tuyet doi emoji trong code, markdown, config, comment.

---

## 8. Git Workflow & Commit Convention

Format: `<type>(<scope>): <mo ta>`

Branching:
```
main -> dev -> feature/..., fix/..., refactor/...
```

---

## File lien quan

- [Cau truc Du an Tieu chuan (Skill DuyVo26)](./skill_project_structure.md)
- [Logging & Monitoring](./skill_logging_monitoring.md)
- [Chuan API Response](./skill_api_response_standard.md)
- [Codebase Mapper](./skill_codebase_mapper.md)
