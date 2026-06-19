# Skill: Hệ thống Thanh toán Tự động (Polling & Sync)

## Mục tiêu

Luồng nạp tiền tự động không cần Webhook, sử dụng Polling kết hợp với SePay API để đối soát giao dịch ngân hàng.

---

## 1. Luồng xử lý

1. Frontend gọi `POST /payment/create` với `package_id`
2. Backend tạo record `payments` (status: `pending`), trả về `HEX_ID`
3. Frontend hiển thị QR + nội dung chuyển khoản: `{NAME_WEB}NAPTOKEN{HEX_ID}`
4. Frontend Polling `GET /payment/status/{id}` mỗi 5-10 giây
5. Backend gọi SePay API -> So khớp content + amount -> Nạp token cho user

---

## 2. Logic So khớp (Reconciliation)

```python
def check_sepay_transactions(payment_record):
    pattern = rf"{prefix}([A-Fa-f0-9]+)"
    history = sepay_api.get_last_20_transactions()
    for tx in history:
        match = re.search(pattern, tx.get('content', ''), re.IGNORECASE)
        if match and match.group(1).upper() == target_hex and amount >= expected:
            return True, tx['id']
    return False, None
```

---

## 3. Quản lý Trạng thái

| Status | Ý nghĩa |
|--------|---------|
| `pending` | Đợi tiền về |
| `completed` | Đã nhận tiền, đã nạp token |
| `failed` | Hết hạn (60p) hoặc bị hủy |

---

## 4. Bảo mật XOR

```python
SECRET_XOR_KEY = 0x5EAFB
def encode_payment_id(p_id: int) -> str:
    return hex(p_id ^ SECRET_XOR_KEY)[2:].upper()
```

---

## Quy tắc bắt buộc

1. Dùng XOR để mã hóa payment ID, không dùng ID thuần.
2. SePay API gọi qua `requests`, timeout 10s.
3. Polling 5-10 giây, không nhỏ hơn.
4. Khi phát hiện giao dịch khớp, cập nhật balance và status trong cùng transaction.
5. Lưu `SEPAY_API_KEY` trong `.env`, không hardcode.

---

## File liên quan

- [Tác vụ Bất đồng bộ & Polling](./skill_async_task_polling.md)
- [Cấu hình Môi trường (.env)](./skill_env_configuration.md)
- [Cấu trúc Dự án Tiêu chuẩn (Skill DuyVo26)](./skill_project_structure.md)
- [Bảo mật & Xác thực](./skill_security_authentication.md)
