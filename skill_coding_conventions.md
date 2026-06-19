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

Bắt buộc cho mọi class và function có logic phức tạp.

**AI khi vào chỉnh/sửa code:** Nếu phát hiện hàm thiếu docstring, PHẢI tự động thêm. Docstring phải bao gồm cả giải thích logic các dòng code chính và các hàm con được gọi.

### 3.1. Python — Google Style Docstring

```python
def process_message(user_id: int, text: str) -> dict:
    """
    Xu ly tin nhan chat qua luong RAG.

    Logic:
      - B1: Goi retrieve_node() de truy van FAISS => List[Document]
      - B2: Goi grade_node() de loc tai lieu khong lien quan
      - B3: Goi generate_node() de LLM sinh cau tra loi
      - B4: Goi update_usage() de tru token user

    Args:
        user_id (int): ID nguoi dung, kiem tra balance
        text (str): Cau hoi nguoi dung gui vao LLM

    Returns:
        dict: { "answer": str, "sources": list, "credits": float }
    Raises:
        ValueError: Neu text rong hoac user khong du balance
    """
    docs = retrieve_node(text, top_k=5)            # FAISS search
    relevant = grade_node(text, documents=docs)    # Loc > 0.7
    answer = generate_node(text, documents=relevant)  # LLM sinh
    update_usage(user_id, tokens=count_tokens(text))  # Tru phi
    return {"answer": answer, "sources": relevant, "credits": 12.5}
```

### 3.2. TypeScript — JSDoc

```typescript
/**
 * Gui tin nhan chat va cap nhat UI.
 *
 * Logic:
 *   - Goi chatbotApi.sendMessage() gui cau hoi len backend
 *   - API tra ve { answer, sources } -> tao message moi
 *   - setMessages() append vao state -> UI tu render
 *   - Loi 401 -> Interceptor tu redirect login
 *   - Loi khac -> showToast() hien thi cho nguoi dung
 *
 * @param {string} question - Cau hoi nguoi dung
 * @returns {Promise<void>}
 */
const handleSend = async (question: string): Promise<void> => {
    if (isLoading) return;
    setIsLoading(true);
    try {
        const res = await chatbotApi.sendMessage(question);
        setMessages(p => [...p, { id: Date.now(), role: 'assistant', content: res.answer }]);
    } catch (error) {
        showToast(error?.response?.data?.message ?? 'Co loi xay ra', 'error');
    } finally {
        setIsLoading(false);
    }
};
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

Xem chi tiết tại skill riêng: [**Git Workflow & Commit Convention**](./skill_git_workflow.md)

---

## File liên quan

- [Cấu trúc Dự án Tiêu chuẩn (Skill DuyVo26)](./skill_project_structure.md)
- [Git Workflow & Commit Convention](./skill_git_workflow.md)
- [Logging & Monitoring](./skill_logging_monitoring.md)
- [Chuẩn API Response](./skill_api_response_standard.md)
- [Codebase Mapper](./skill_codebase_mapper.md)
