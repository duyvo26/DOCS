# Hướng dẫn Hệ thống Thanh toán (Payment System Guide)

Tài liệu này cung cấp cái nhìn chi tiết về cấu trúc và logic triển khai hệ thống thanh toán tự động thông qua **SePay** cho ứng dụng.

## 1. Tổng quan kiến trúc
Hệ thống thanh toán hoạt động theo mô hình: **Giao dịch -> Quét Giao dịch ngân hàng -> Đối soát -> Cộng Token**.

- **Provider**: SePay (Hỗ trợ quét lịch sử giao dịch ngân hàng Việt Nam qua API).
- **Cơ chế**: Dựa vào nội dung chuyển khoản để xác định người dùng và đơn hàng.
- **Workflow**:
    1. Người dùng chọn gói nạp.
    2. Hệ thống tạo hóa đơn ở trạng thái `pending`.
    3. Tạo nội dung chuyển khoản duy nhất (Payment Note).
    4. Người dùng chuyển khoản.
    5. Hệ thống quét API SePay để tìm giao dịch khớp mã.
    6. Tự động cộng token và chuyển trạng thái hóa đơn thành `completed`.

---

## 2. Mã nội dung chuyển khoản (Payment Code)
Để đảm bảo tính chính xác và không bị nhầm lẫn giữa hàng nghìn giao dịch, mã chuyển khoản được thiết kế như sau:

**Format**: `<NAMENAME>NAPTOKEN<HEX_ID>`
- **NAMENAME**: Tên website được cấu hình trong `.env` (`NAME_WEB`).
- **NAPTOKEN**: Từ khóa cố định.
- **HEX_ID**: Mã hóa đơn được chuyển sang hệ cơ số 16 và XOR để bảo mật nhẹ.

**Ví dụ**: `BLOOMNAPTOKEN1A2B`

---

## 3. Thời gian hết hạn (Expiry Time)
Hóa đơn có hiệu lực trong vòng **60 phút** kể từ khi khởi tạo.
- Sau 60 phút, nếu chưa nhận được tiền, hóa đơn sẽ tự động chuyển sang trạng thái `failed`.
- Hệ thống vẫn hỗ trợ xử lý các hóa đơn đã `failed` nếu tiền về sau đó (thông qua cơ chế đối soát thông minh).

---

## 4. Tích hợp SePay API
Hệ thống kết nối với SePay thông qua API Token (`SEPAY_API_KEY`).

- **Dữ liệu đối soát**: 
    - `amount_in` (Số tiền thực nhận): Phải khớp chính xác 100% với giá gói nạp (`amount_vnd`).
    - `transaction_content`: Phải chứa mã `NAPTOKEN` hợp lệ.

---

## 5. Metadata & Reporting
Hệ thống lưu trữ lịch sử giao dịch chi tiết bao gồm:
- Mã giao dịch ngân hàng (`sepay_id`).
- Thời gian giao dịch thực tế.
- Nội dung gốc của thông báo chuyển khoản.

---

## 6. Báo cáo vấn đề thanh toán (Payment Report)
Nếu người dùng đã chuyển khoản thành công nhưng không nhận được token (do ngân hàng chậm, lỗi mạng, v.v.), hệ thống cung cấp tính năng **Báo cáo sự cố**:

1. **Người dùng**: Nhấn nút "Báo cáo sự cố" trên hóa đơn bị lỗi.
2. **Admin**: Xem danh sách báo cáo tại tab **"Báo cáo TT"** trong trang Admin.
3. **Xử lý**: Admin có thể kiểm tra thực tế giao dịch ngân hàng và cộng token thủ công cho người dùng.

## 7. Các đoạn mã kỹ thuật

### Mã hóa đơn hàng (Obfuscated Hex)
```python
def encode_payment_id(payment_id: int) -> str:
    secret = 0x5EAFB
    return hex(payment_id ^ secret)[2:].upper()

# Format: {NAME_WEB}NAPTOKEN{HEX_ID}
note = f"{settings.NAME_WEB}NAPTOKEN{encode_payment_id(payment_id)}"
```

### Route Báo cáo sự cố
```python
@router.post("/report")
def create_payment_report(payment_id: int = Form(...), description: str = Form(...)):
    # ... verify payment ownership ...
    db.create_payment_report(user_id, payment_id, description)
```

### Tự động xử lý tiền về (SePay Sync)
```python
# Logic bóc tách mã nạp từ nội dung giao dịch
match = re.search(rf"{settings.NAME_WEB}NAPTOKEN([A-Fa-f0-9]+)", content)
if match:
    hex_id = match.group(1)
    payment_id = decode_payment_id(hex_id)
    # Cộng token và mark completed...
```

## 8. Hướng dẫn dành cho Admin
- **Quản lý gói nạp**: Có thể thêm/xóa/sửa các gói nạp trực tiếp trong trang Admin.
- **Kiểm soát dòng tiền**: Theo dõi lịch sử nạp toàn hệ thống tại tab **"Hóa Đơn"**.
- **Xử lý báo cáo**: Luôn ưu tiên kiểm tra các hóa đơn có báo cáo từ người dùng.
