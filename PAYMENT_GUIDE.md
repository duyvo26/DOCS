# Hướng dẫn Hệ thống Thanh toán (Payment System Guide)

Tài liệu này cung cấp cái nhìn chi tiết về cấu trúc và logic triển khai hệ thống thanh toán tự động thông qua **SePay** cho ứng dụng Bloom.

## 1. Tổng quan kiến trúc (Architecture Overview)

Hệ thống thanh toán hoạt động theo mô hình: **Giao dịch -> Quét Giao dịch -> Đối soát -> Cộng Token**.

- **Provider**: SePay (Hỗ trợ quét lịch sử giao dịch ngân hàng Việt Nam qua API/Webhook).
- **Cơ chế**: Dựa vào nội dung chuyển khoản (Transfer Content) để xác định người dùng và đơn hàng.
- **Workflow**:
    1. Người dùng chọn gói Token.
    2. Hệ thống tạo bản ghi `payment` ở trạng thái `pending`.
    3. Hệ thống tạo mã nội dung chuyển khoản duy nhất (Unique Payment Code).
    4. Người dùng chuyển khoản qua QR hoặc thủ công với nội dung trên.
    5. Hệ thống quét API SePay (Sync) tìm giao dịch khớp mã.
    6. Chuyển trạng thái `payment` thành `completed`, tạo `transaction` và cộng `token_balance` cho `user`.

---

## 2. Các thành phần chính (Key Components)

### 2.1 Backend (Python/FastAPI)
- **`app/routers/payment.py`**: Chứa các API tạo đơn, kiểm tra trạng thái và logic đồng bộ giao dịch từ SePay.
- **`app/utils/database.py`**: Các hàm CRUD cho bảng `payments`, `transactions` và `packages`.
- **`app/models/auth.py`**: Định nghĩa Schema dữ liệu (Pydantic models) cho thanh toán.

### 2.2 Frontend (React/TypeScript)
- **`PaymentModal.tsx`**: Component hiển thị các gói token, hướng dẫn chuyển khoản và mã QR.
- **`PaymentHistoryModal.tsx`**: Hiển thị danh sách lịch sử nạp tiền của người dùng.

---

## 3. Cấu trúc Mã Thanh toán (Payment Code Logic)

Mã nội dung chuyển khoản được thiết kế để bảo mật thông tin ID và đảm bảo tính duy nhất.

```python
# app/routers/payment.py

# Format: [USER_HEX(6)][RANDOM_LETTERS(2)][PAYMENT_HEX(6)]
# Tổng cộng: 14 ký tự HEX
base = f"{user_id}{payment_id}"
md5 = hashlib.md5(base.encode()).hexdigest()

# Sinh 2 chữ cái ngẫu nhiên dựa trên md5 của user/payment
letters = string.ascii_uppercase
rand_letters = letters[int(md5[0:2], 16) % 26] + letters[int(md5[2:4], 16) % 26]

# Ví dụ: 000001XY000005
payment_code = f"{user_id:06X}{rand_letters}{payment_id:06X}"
payment_description = f"XXX NAPTOKEN {payment_code}"
```

Khi quét giao dịch, hệ thống sử dụng Regex để tách ngược lại `user_id` và `payment_id` từ nội dung:
```python
hex_match = re.search(r"XXX\s+NAPTOKEN\s+([A-Z0-9]{14})", description, re.IGNORECASE)
# ... bóc tách hex ...
user_id = int(code[:6], 16)
payment_id = int(code[8:], 16)
```

---

## 4. Tích hợp SePay API & VietQR

### 4.1 Tạo mã QR Thanh toán (VietQR)
Hệ thống sử dụng dịch vụ của SePay để tạo mã QR động theo tiêu chuẩn VietQR. Điều này giúp người dùng chỉ cần quét mã là các thông tin (Số tài khoản, Số tiền, Nội dung) sẽ tự động được điền chính xác.

**Cấu trúc URL tạo QR:**
```
https://qr.sepay.vn/img?acc={STK}&bank={NganHang}&amount={SoTien}&des={NoiDung}
```

**Các tham số chủ đạo:**
- `acc`: Số tài khoản ngân hàng nhận tiền (Lấy từ `settings.SEPAY_ACCOUNT_NUMBER`).
- `bank`: Mã định danh ngân hàng hoặc tên ngân hàng (Lấy từ `settings.SEPAY_BANK_BRAND`).
- `amount`: Số tiền nạp chính xác (VNĐ).
- `des`: Nội dung chuyển khoản quan trọng (Phải khớp chính xác với `payment_description` tạo ra ở Backend và được `encodeURIComponent`).

**Ví dụ triển khai React (PaymentModal.tsx):**
```tsx
const qrUrl = `https://qr.sepay.vn/img?acc=${order.account_number}&bank=${order.bank_brand}&amount=${order.amount_vnd}&des=${encodeURIComponent(order.note)}`;

<img src={qrUrl} alt="VietQR" />
```

### 4.2 API Lấy danh sách giao dịch (Fetch Transactions)
Hệ thống sử dụng endpoint `list` của SePay để quét các giao dịch mới nhất.

```python
# Trích xuất từ sync_sepay_transactions() trong app/routers/payment.py
url = "https://my.sepay.vn/userapi/transactions/list"
headers = {"Authorization": f"Bearer {settings.SEPAY_API_KEY}"}
params = {"account_number": settings.SEPAY_ACCOUNT_NUMBER, "limit": 20}
```

### 4.3 Cấu trúc dữ liệu phản hồi từ SePay
Dữ liệu SePay trả về cần được chú ý các trường quan trọng:
- `id`: ID giao dịch duy nhất từ SePay (dùng để tránh trùng lặp).
- `transaction_content`: Nội dung chuyển khoản (chứa mã nạp tiền).
- `amount_in`: Số tiền thực nhận.

```python
for tx in transactions:
    tx_id = str(tx.get("id"))
    description = tx.get("transaction_content", "")
    amount = float(tx.get("amount_in", "0"))
    
    # Kiểm tra xem giao dịch này đã được xử lý chưa trong DB
    if get_payment_by_sepay_id(tx_id):
        continue
    
    # Tiếp tục bóc tách description và đối soát...
```

---

## 5. Quy trình xử lý tự động (Automatic Sync & Polling)

### 5.1 Phía Client (Frontend Polling)
Trong khi `PaymentModal` đang mở, Frontend sẽ gọi API kiểm tra trạng thái mỗi **1 giây** một lần:
- Endpoint: `GET /api/v1/payment/status/{payment_id}`
- Nếu trả về `completed`: Đóng modal, thông báo thành công.
- Nếu trả về `failed`: Thông báo đơn hàng đã hết hạn.

### 5.2 Phía Server (Passive Sync)
Mỗi khi API `/status` hoặc `/history` được gọi, Server thực hiện các tác vụ sau:
1. **Dọn dẹp (`get_and_update_expired_payments`)**: Tự động đánh dấu các `payment` có trạng thái `pending` quá 10 phút là `failed`.
2. **Đồng bộ API (`sync_sepay_transactions`)**: Gọi SePay API để tìm giao dịch khớp mã.
3. **Cập nhật số dư**: Nếu khớp, hệ thống gọi `update_payment_status` và `create_transaction`. Hàm này sẽ tự động cộng `amount` vào `token_balance` của người dùng trong DB.

---

## 6. Hướng dẫn cho Developer/LLM

### Thêm gói nạp mới
Sử dụng API Admin hoặc insert trực tiếp vào bảng `packages` trong `bloom.db`:
- `name`: Tên hiển thị.
- `tokens`: Số lượng token nhận được.
- `amount_vnd`: Giá tiền VNĐ.

### Xử lý khi thanh toán không được cộng tự động
1. Kiểm tra log backend để xem nội dung giao dịch SePay trả về có khớp Regex không.
2. Kiểm tra `SEPAY_API_KEY` trong file `.env`.
3. Admin có thể cộng token thủ công qua `AdminDashboard` (gọi endpoint `/api/v1/admin/users/{user_id}/tokens`).

### Lưu ý quan trọng khi Debug
- **Log Giao dịch**: Kiểm tra log console của backend để xem "Parsed IDs". Nếu ID bóc tách sai, hãy kiểm tra lại cấu trúc mã Hex.
- **Khớp số tiền**: Hệ thống yêu cầu số tiền thực nhận (`amount_in`) phải khớp 100% với số tiền đơn hàng.
- **Regex**: Nếu thay đổi nội dung prefix `XXX NAPTOKEN`, phải cập nhật cả Frontend và Regex trong Backend.

### Bảo mật
- Mã chuyển khoản 14 ký tự đóng vai trò là "Secret" để xác minh giao dịch.
- Mọi API tải file kết quả AI (`/bloom/{uid}/{filename}`) đều kiểm tra `is_owner` hoặc `is_admin`.
