# Skill: Git Workflow & Commit Convention

## Mục tiêu

Quy định chuẩn Git cho toàn bộ dự án: cách đặt tên nhánh, viết commit message, quy trình làm việc hàng ngày. Giúp lịch sử Git sạch, dễ review, dễ trace lỗi.

---

## 1. Branch Strategy (Chiến lược nhánh)

### Cấu trúc nhánh

```
main                     -- Nhánh chính, luôn ở trạng thái deploy được. Chỉ merge qua Pull Request.
└── dev                  -- Nhánh phát triển, merge các feature vào đây trước khi lên main.
    ├── feature/xxx      -- Tính năng mới
    ├── fix/xxx          -- Sửa lỗi
    └── refactor/xxx     -- Cải tổ code
```

### Quy tắc đặt tên nhánh

```
{type}/{mô-tả-ngắn-bằng-tiếng-anh}
```

| Type | Khi nào dùng | Ví dụ ĐÚNG | Ví dụ SAI |
|------|-------------|------------|-----------|
| `feature/` | Thêm tính năng mới | `feature/google-oauth` | `feature/123`, `feature/sua-loi` |
| `fix/` | Sửa lỗi | `fix/payment-duplicate` | `fix/fix-bug`, `fix/1` |
| `refactor/` | Cải tổ code, không thay đổi chức năng | `refactor/chat-domain` | `refactor/aaaa` |

**Quy tắc:**
- Dùng `kebab-case` (chữ thường, gạch ngang)
- Ngắn gọn, rõ ràng, bằng tiếng Anh
- KHÔNG đặt: `feature/asdf`, `fix/sua-loi`, `refactor/1`, `dev-test`

---

## 2. Commit Convention (Conventional Commits)

### Format bắt buộc

```
<type>(<scope>): <mô-tả-ngắn>

<body> (tùy chọn, cách dòng thứ 3)
```

### Danh sách type

| Type | Khi nào dùng | Ví dụ |
|------|-------------|-------|
| `feat` | Thêm tính năng mới | `feat(auth): thêm đăng nhập Google OAuth` |
| `fix` | Sửa lỗi | `fix(payment): sửa lỗi tính tổng tiền sai` |
| `refactor` | Cải tổ cấu trúc, không thêm/xoá tính năng | `refactor(chat): tách ChatInput thành component riêng` |
| `docs` | Chỉ sửa tài liệu, README, comment | `docs(readme): cập nhật bước cài đặt` |
| `chore` | Việc không ảnh hưởng logic (config, dep) | `chore: thêm tailwind config` |
| `test` | Thêm hoặc sửa test | `test(auth): thêm unit test cho hàm verify_password` |
| `style` | Sửa format, không thay đổi logic | `style(frontend): chuẩn hóa khoảng trắng` |

### Quy tắc viết commit

- Mô tả ở dạng động từ nguyên thể tiếng Anh: `add`, `fix`, `update`, `remove` — không phải `added`, `fixing`
- Tối đa **72 ký tự** cho dòng đầu
- Scope là tên module/domain: `auth`, `payment`, `chat`, `frontend`, `docs`
- Nếu cần giải thích thêm, viết vào body (dòng 3 trở đi)

### Ví dụ ĐÚNG

```bash
# Tối giản
git commit -m "feat(auth): thêm đăng nhập Google OAuth"

# Có body (giải thích tại sao)
git commit -m "fix(auth): sửa lỗi logout không xoá token ở tab thứ hai

Thêm 'storage' event listener trong AuthContext để đồng bộ trạng thái
logout giữa nhiều tab. Token trong localStorage bị xoá ở tab 1 sẽ
tự động clear user state ở tab 2."
```

### Ví dụ SAI

```bash
git commit -m "sua loi"                              # Thiếu type + scope
git commit -m "fix bug"                               # Mô tả chung chung
git commit -m "feat(frontend): Added new feature"     # "Added" không phải nguyên thể
git commit -m "chore: sửa linh tinh"                 # Mô tả không rõ
git commit -m "feat: thêm chức năng mới cho chat và sửa luôn payment và thêm admin"  # Quá dài, làm nhiều việc
```

---

## 3. Git Workflow Hàng ngày

### Quy trình cơ bản

```bash
# 1. Lấy code mới nhất từ dev
git checkout dev
git pull origin dev

# 2. Tạo nhánh mới
git checkout -b feature/ten-tinh-nang

# 3. Code và commit
git add <file>
git commit -m "feat(scope): mô tả"

# 4. Push lên remote
git push origin feature/ten-tinh-nang

# 5. Lên GitHub tạo Pull Request vào dev
```

### Quy tắc

| Hành động | Quy tắc |
|-----------|---------|
| `git commit` | Chỉ commit khi code chạy được, không commit code dang dở |
| `git push` | Push sau mỗi commit, tránh mất code |
| Pull Request | Mỗi tính năng/lỗi = 1 PR riêng. Không gộp nhiều việc vào 1 PR |
| Merge vào `dev` | Qua PR, có review. KHÔNG merge tay |
| Merge vào `main` | Chỉ khi `dev` ổn định, qua PR |
| Commit vào `main` | **CẤM** commit trực tiếp vào `main`. Luôn qua nhánh phụ + PR |

### Nguyên tắc quan trọng

1. **Một commit = một việc**: Không sửa 2 lỗi khác nhau trong cùng 1 commit.
2. **Commit sớm, commit thường xuyên**: Mỗi khi hoàn thành 1 phần nhỏ, commit ngay.
3. **Commit message phải có ý nghĩa**: `git log` phải đọc được như một cuốn nhật ký.
4. **KHÔNG commit file nhạy cảm**: `.env`, `node_modules/`, `__pycache__/`, `*.db`

---

## 4. Quy tắc cho AI khi làm Git

1. **KHÔNG tự ý commit, push** nếu người dùng chưa yêu cầu.
2. **Khi được yêu cầu commit**:
   - Chạy `git status` và `git diff` trước để kiểm tra.
   - Chỉ stage những file cần thiết (không stage `.env`, `node_modules/`, `__pycache__/`).
   - Viết commit message theo chuẩn Conventional Commits.
3. **Khi được yêu cầu tạo branch**:
   - Đặt tên theo chuẩn `type/mô-tả`.
   - Checkout từ `dev`, không từ `main`.
4. **Khi được yêu cầu push**: Push đúng nhánh hiện tại.

---

## 5. Lệnh Git thường dùng (Cheat Sheet)

### Cơ bản

| Mục đích | Lệnh |
|----------|------|
| Kiểm tra trạng thái | `git status` |
| Xem diff | `git diff` |
| Stage file | `git add <file>` hoặc `git add -A` |
| Commit | `git commit -m "type(scope): message"` |
| Push | `git push origin <branch>` |
| Pull | `git pull origin <branch>` |

### Nhánh

| Mục đích | Lệnh |
|----------|------|
| Tạo nhánh mới | `git checkout -b feature/ten-tinh-nang` |
| Đổi nhánh | `git checkout dev` |
| Xoá nhánh local | `git branch -d feature/ten-tinh-nang` |
| Xoá nhánh remote | `git push origin --delete feature/ten-tinh-nang` |
| Xem danh sách nhánh | `git branch -a` |

### Lịch sử

| Mục đích | Lệnh |
|----------|------|
| Xem log | `git log --oneline -10` |
| Xem log đồ hoạ | `git log --oneline --graph --all` |
| Sửa commit message cuối | `git commit --amend -m "message mới"` (chỉ khi chưa push) |

### Xử lý tình huống

| Tình huống | Lệnh |
|------------|------|
| Lỡ stage file nhạy cảm | `git restore --staged .env` |
| Lỡ commit vào sai nhánh | `git reset HEAD~1` (chỉ khi chưa push) |
| Cần lưu code tạm thời | `git stash` → `git stash pop` |
| Huỷ thay đổi local | `git restore <file>` |
| Kéo code mới nhất | `git pull --rebase origin dev` |

---

## File liên quan

- [Cấu trúc Dự án Tiêu chuẩn (Skill DuyVo26)](./skill_project_structure.md)
- [Tiêu chuẩn Viết Code (Coding Conventions)](./skill_coding_conventions.md)
