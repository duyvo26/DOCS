# Tiêu chuẩn Viết Code & Đặt tên (Coding Conventions)

Tài liệu này quy định các quy tắc chuẩn mực khi viết code, đặt tên biến, tên hàm, và các tiêu chuẩn định dạng (formatting) cho cả hệ thống Backend (Python) và Frontend (TypeScript). Việc tuân thủ quy tắc này giúp AI Agent và Developer làm việc nhóm đồng bộ và tránh lỗi.

---

## 1. Tiêu chuẩn Backend (Python / FastAPI)

Chúng ta tuân theo tiêu chuẩn **PEP 8** của Python cùng với một số tinh chỉnh riêng cho ứng dụng AI.

### 1.1. Quy tắc đặt tên (Naming Conventions)
*   **Class (Lớp)**: Sử dụng `PascalCase`.
    *   *Đúng*: `DocumentGrader`, `VectorStoreManager`, `AuthRouter`.
    *   *Sai*: `documentGrader`, `vector_store_manager`.
*   **Function / Method (Hàm / Phương thức)**: Sử dụng `snake_case`. Tên hàm phải bắt đầu bằng một động từ (hành động).
    *   *Đúng*: `get_user_by_id()`, `split_question()`, `generate_sub_answers()`.
    *   *Sai*: `UserById()`, `SplitQuestion()`.
*   **Variable (Biến)**: Sử dụng `snake_case`.
    *   *Đúng*: `retry_count`, `filtered_docs`, `user_token_balance`.
*   **Constant (Hằng số)**: Sử dụng `UPPER_SNAKE_CASE` (Toàn bộ viết hoa, cách nhau bởi gạch dưới). Thường được định nghĩa ở đầu file hoặc file `config.py`.
    *   *Đúng*: `MAX_RETRIES_RAG`, `SECRET_XOR_KEY`.

### 1.2. Type Hinting (Gợi ý Kiểu dữ liệu)
**Bắt buộc** sử dụng Type Hinting cho tất cả các tham số đầu vào và kết quả trả về của hàm để AI có thể hiểu rõ luồng dữ liệu.
```python
from typing import List, Dict, Any
from langchain.schema import Document

# Ví dụ CHUẨN:
def process_chunks(self, chunks: List[Document], threshold: float = 0.8) -> Dict[str, Any]:
    return {"status": "success", "processed_count": len(chunks)}
```

### 1.3. Tiếng Anh vs Tiếng Việt
*   **Logic Hệ thống, Framework, Tool**: Bắt buộc dùng Tiếng Anh (`UserDB`, `generate_answer`, `is_admin`).
*   **Nghiệp vụ đặc thù (Domain Logic)**: Được phép sử dụng Tiếng Việt (không dấu) để khớp sát với yêu cầu bài toán (Ví dụ trong dự án Luật: `hanh_vi`, `dieu_khoan`, `hinh_phat`).

---

## 2. Tiêu chuẩn Frontend (React / TypeScript)

### 2.1. Quy tắc đặt tên
*   **Component (Thành phần UI)**: Sử dụng `PascalCase`. Tên file cũng phải là `PascalCase.tsx`.
    *   *Đúng*: `AuthView.tsx`, `SidebarMenu.tsx`.
*   **Interface / Type**: Sử dụng `PascalCase`. (Có thể thêm chữ `I` hoặc `T` ở đầu tùy quy ước, nhưng phổ biến nhất là trùng tên thực thể gốc).
    *   *Đúng*: `UserProfile`, `SessionData`.
*   **Function / Variable**: Sử dụng `camelCase`.
    *   *Đúng*: `handleGoogleLogin()`, `isSubmitting`, `userBalance`.
*   **Boolean Variables (Biến True/False)**: Phải bắt đầu bằng chữ `is`, `has`, `should`, `can`.
    *   *Đúng*: `isLoading`, `hasError`, `canSubmit`.

### 2.2. Tránh Hardcode
Tuyệt đối không gán cứng các API URL hoặc chuỗi văn bản tĩnh. Phải dùng biến môi trường:
```typescript
// Sai:
const res = await fetch("http://localhost:2643/api/v1/auth/login");

// Đúng:
const res = await fetch(`${import.meta.env.VITE_API_URL}/auth/login`);
```

---

## 3. Quy tắc Comment (Ghi chú mã nguồn)

Thay vì comment giải thích "Code làm gì" (What), hãy comment giải thích **"Tại sao lại viết thế này" (Why)**. AI và lập trình viên đều có thể đọc code để biết "What", nhưng không thể biết "Why" nếu logic phức tạp.

### 3.1. Tiêu chuẩn Docstring (Backend - Python)
Hệ thống sử dụng **Google Style Docstrings**. Bắt buộc phải có docstring cho mọi `class` và `function` có logic phức tạp.

**Cấu trúc chuẩn của một Docstring:**
1.  **Mô tả ngắn gọn**: 1-2 câu giải thích mục đích chính của hàm/class.
2.  **Args (Tham số)**: Liệt kê từng tham số, kiểu dữ liệu (tùy chọn vì đã có type hint) và ý nghĩa.
3.  **Returns (Trả về)**: Mô tả dữ liệu trả về.
4.  **Raises (Ngoại lệ - Tùy chọn)**: Các lỗi cố ý được `raise` trong hàm.

**Ví dụ:**
```python
class PunishmentValidator:
    """
    PunishmentValidator:
    Agent chuyên biệt dùng để đánh giá chéo (cross-validate) kết quả của PunishmentAgent.
    Trả về JSON chứa 'hop_le' (yes/no) và 'giai_thich' để quyết định chấp nhận hay từ chối hình phạt.
    """
    
    def evaluate_punishment(self, context: str, predicted_penalty: str) -> dict:
        """
        Thực thi đánh giá hình phạt dựa trên văn bản luật gốc được cung cấp.
        
        Args:
            context (str): Chuỗi chứa nội dung các điều luật trích xuất từ FAISS.
            predicted_penalty (str): Hình phạt mà Agent trước đó đã dự kiến.
            
        Returns:
            dict: Kết quả đánh giá đã parse JSON, bao gồm cờ 'hop_le' và 'giai_thich'.
            
        Raises:
            ValueError: Nếu chuỗi context bị rỗng hoặc không hợp lệ.
        """
        if not context:
            raise ValueError("Context không được để trống.")
        pass
```

### 3.2. Tiêu chuẩn JSDoc (Frontend - TypeScript)
Tương tự như Python, ở Frontend chúng ta sử dụng chuẩn **JSDoc** cho các Component hoặc Utility functions phức tạp. Việc này giúp các IDE như VSCode tự động hiển thị gợi ý khi hover chuột.

**Ví dụ:**
```typescript
/**
 * Xử lý luồng đăng nhập Google và quản lý token.
 * 
 * @param {string} sessionId - Mã phiên giao dịch duy nhất sinh ra ở Client.
 * @param {function} onSuccess - Callback được gọi khi đăng nhập thành công.
 * @returns {Promise<void>} Hàm không trả về giá trị trực tiếp mà gọi onSuccess.
 */
const handleGoogleLogin = async (sessionId: string, onSuccess: (user: any, token: string) => void): Promise<void> => {
    // ... logic
};
```

### 3.3. Comment theo Header Block
Đối với những file dài, sử dụng Block comment để chia tách các giai đoạn logic (giống như trong LangGraph pipeline):
```python
# ------------------------------------------------------------------
# BƯỚC 2: TRUY VẤN TÀI LIỆU (RETRIEVE_MULTI)
# ------------------------------------------------------------------
def retrieve_multi(self, state: GraphStates) -> Dict[str, Any]:
    pass
```

---

## 4. Quản lý Lỗi (Error Handling)

### 4.1. Backend
Không bao giờ dùng `print(error)` rồi chạy tiếp. Phải bắt lỗi và trả về Exception chuẩn.
```python
from fastapi import HTTPException

try:
    data = json.loads(llm_output)
except json.JSONDecodeError:
    # Ghi log chi tiết hệ thống
    logger.error(f"JSON Parse failed: {llm_output}")
    # Trả lỗi thân thiện cho client
    raise HTTPException(status_code=500, detail="Lỗi trích xuất dữ liệu từ AI.")
```

### 4.2. Frontend
Sử dụng Optional Chaining `?.` và Nullish Coalescing `??` để tránh "vỡ" giao diện.
```typescript
// Đúng:
const userName = data?.user?.profile?.name ?? "Khách";
```

---

## 5. Quy tắc Inline Comment (Comment dòng code)

Ngoài Docstring và JSDoc (comment khối), lập trình viên cần biết **khi nào** phải viết comment cho từng dòng/đoạn code nhỏ.

### 5.1. Khi nào BẮT BUỘC comment
*   **Logic nghiệp vụ không rõ ràng**: Các phép tính, ngưỡng (threshold), hoặc hằng số "ma thuật" (magic number).
    ```python
    # Trừ 15% phí hệ thống trước khi cộng token cho user
    actual_amount = amount * 0.85
    ```
*   **Workaround hoặc Hack tạm thời**: Khi bạn buộc phải viết code "xấu" để sửa lỗi tạm, comment lại lý do.
    ```python
    # FIXME: SePay API trả content bị thừa khoảng trắng, cần strip trước khi so khớp
    content = tx.get('content', '').replace(" ", "")
    ```
*   **Regex phức tạp**: Mọi biểu thức Regex phải có comment giải thích pattern đang tìm gì.
    ```python
    # Tìm mã nạp HEX theo format: MYAPPNAPTOKEN + [chuỗi hex]
    pattern = rf"{prefix}([A-Fa-f0-9]+)"
    ```

### 5.2. Khi nào KHÔNG NÊN comment
*   Code đã quá rõ ràng nhờ đặt tên tốt:
    ```python
    # SAI - comment thừa, vì tên hàm đã nói lên tất cả:
    # Lấy user bằng email
    user = get_user_by_email(email)
    
    # ĐÚNG - không cần comment:
    user = get_user_by_email(email)
    ```

---

## 6. Quy tắc Đặt tên File và Thư mục

### 6.1. Backend (Python)
*   **File module**: Dùng `snake_case.py`. Ví dụ: `base_db.py`, `question_router.py`.
*   **File router**: Đặt theo tên chức năng. Ví dụ: `auth.py`, `payment.py`, `chat.py`.
*   **File class**: Đặt tên khớp với class chính bên trong. Ví dụ: `vector_data_builder.py` chứa class `VectorDataBuilder`.

### 6.2. Frontend (React/TypeScript)
*   **Component**: Dùng `PascalCase.tsx`. Ví dụ: `ChatView.tsx`, `SidebarMenu.tsx`, `AuthView.tsx`.
*   **Utility/Service**: Dùng `camelCase.ts`. Ví dụ: `api.ts`, `helpers.ts`.
*   **Thư mục**: Dùng `lowercase` hoặc `kebab-case`. Ví dụ: `components/`, `pages/`, `hooks/`.

---

## 7. Quy tac Cam Emoji (No-Emoji Rule)

**Cam tuyet doi** su dung emoji trong tat ca file cua du an, bao gom:

- File code (`*.py`, `*.ts`, `*.tsx`, `*.js`)
- File tai lieu (`*.md`)
- File cau hinh (`*.yaml`, `*.json`, `*.env.example`)
- Comment trong code

### Ly do:

| Van de | Mo ta |
|--------|-------|
| Encoding loi | Emoji co the bi render sai tren he dieu hanh khac nhau (Windows / Linux / macOS) |
| Terminal bi loi | Mot so terminal khong hien thi duoc Unicode emoji, lam mat thong tin log |
| Khong chuyen nghiep | Trong tai lieu ky thuat, emoji la nhieu, gay mat tap trung |
| Khach hang / Doi tac | Mot so he thong doc tai lieu tu dong bi loi khi gap emoji |
| AI Agent | Mot so AI pipeline xu ly text bi out-of-sync khi gap ky tu dac biet |

### Cach thay the emoji bang van ban:

| Thay vi dung | Dung thay the |
|---|---|
| `✅ Dung` | `[Dung]` hoac chu thuong |
| `❌ Sai` | `[Sai]` hoac `KHONG:` |
| `⚠️ Luu y` | `**Luu y:**` hoac `CANH BAO:` |
| `📁 Thu muc` | Chi can ten thu muc |
| `🔑 Bao mat` | `Bao mat:` |
| `💡 Meo` | `Goi y:` hoac `Meo:` |

### Vi du ap dung:

```python
# SAI:
# ✅ Da kiem tra xong
# ⚠️ Can xu ly loi nay

# DUNG:
# [OK] Da kiem tra xong
# CANH BAO: Can xu ly loi nay
```

```markdown
<!-- SAI trong file .md: -->
> ⚠️ **Vấn đề cốt lõi**: ...

<!-- DUNG trong file .md: -->
> **Luu y - Van de cot loi**: ...
```

---

## 8. Quy tac Git Workflow & Commit Convention

### 8.1. Chuan Commit Message (Conventional Commits)

Format bat buoc: `<type>(<scope>): <mo ta ngan gon>`

| Type | Khi nao dung | Vi du |
|---|---|---|
| `feat` | Them tinh nang moi | `feat(auth): them dang nhap Google OAuth` |
| `fix` | Sua loi | `fix(payment): sua loi tinh tong tien sai` |
| `refactor` | Doi cau truc, khong them/xoa tinh nang | `refactor(chat): tach ChatInput thanh component rieng` |
| `docs` | Chi sua tai lieu, README, comment | `docs(readme): cap nhat buoc cai dat` |
| `chore` | Viec lam khong anh huong logic (cap nhat dep, config) | `chore: them tailwind config` |
| `test` | Them hoac sua test | `test(auth): them unit test cho ham verify_password` |
| `style` | Sua format, khong thay doi logic | `style(frontend): chuan hoa khoang trang` |

**Quy tac them:**
- Mo ta o dang dong tu nguyen mau, tieng Anh: `add`, `fix`, `update`, `remove` — khong phai `added`, `fixing`.
- Ngan gon toi da 72 ky tu.
- Neu can giai thich them, viet them vao body commit (dong 3 tro di).

```bash
# Vi du commit day du (co body):
git commit -m "fix(auth): sua loi logout khong xoa token o tab thu hai

Them 'storage' event listener trong AuthContext de dong bo trang thai
logout giua nhieu tab. Token trong localStorage bi xoa o tab 1 se
tu dong clear user state o tab 2."
```

### 8.2. Quy tac Branching (Nhanh)

```
main          -- Nhanh chinh, luon o trang thai deploy duoc. Chi merge qua Pull Request.
└── dev       -- Nhanh phat trien, merge cac feature vao day truoc khi len main.
    ├── feature/ten-tinh-nang   -- Tinh nang moi (vi du: feature/google-oauth)
    ├── fix/ten-loi             -- Sua loi (vi du: fix/payment-duplicate)
    └── refactor/ten-module     -- Cai to code (vi du: refactor/chat-domain)
```

**Quy tac lam viec:**
1. Moi tinh nang moi -> tao nhanh `feature/` tu `dev`.
2. Khi hoan thanh -> tao Pull Request vao `dev`, can review.
3. Khi `dev` on dinh -> merge vao `main` de deploy.
4. KHONG commit truc tiep vao `main`.

### 8.3. Quy tac .gitignore Toan dien

Xem chi tiet mau `.gitignore` day du trong `skill_env_configuration.md` (Muc 2A).

**Nhung gi BAT BUOC phai ignore:**
- `.env`, `.env.*` (tru `.env.example`)
- `.venv/`, `node_modules/`
- `__pycache__/`, `*.pyc`
- `utils/logs/`, `utils/data_vector/`, `utils/upload_temp/`
- `*.db`, `*.sqlite3`
- `dist/`, `.next/`, `build/` (output frontend)
