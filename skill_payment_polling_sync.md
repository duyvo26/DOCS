# Skill: He thong Thanh toan Tu dong (Polling & Sync)

## Muc tieu

Luong nap tien tu dong khong can Webhook, su dung Polling ket hop voi SePay API de doi soat giao dich ngan hang.

---

## 1. Luong xu ly

1. Frontend goi `POST /payment/create` voi `package_id`
2. Backend tao record `payments` (status: `pending`), tra ve `HEX_ID`
3. Frontend hien thi QR + noi dung chuyen khoan: `{NAME_WEB}NAPTOKEN{HEX_ID}`
4. Frontend Polling `GET /payment/status/{id}` moi 5-10 giay
5. Backend goi SePay API -> So khop content + amount -> Nap token cho user

---

## 2. Logic So khop (Reconciliation)

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

## 3. Quan ly Trang thai

| Status | Y nghia |
|--------|---------|
| `pending` | Doi tien ve |
| `completed` | Da nhan tien, da nap token |
| `failed` | Het han (60p) hoac bi huy |

---

## 4. Bao mat XOR

```python
SECRET_XOR_KEY = 0x5EAFB
def encode_payment_id(p_id: int) -> str:
    return hex(p_id ^ SECRET_XOR_KEY)[2:].upper()
```

---

## Quy tac bat buoc

1. Dung XOR de ma hoa payment ID, khong dung ID thuan.
2. SePay API goi qua `requests`, timeout 10s.
3. Polling 5-10 giay, khong nho hon.
4. Khi phat hien giao dich khop, cap nhat balance va status trong cung transaction.
5. Luu `SEPAY_API_KEY` trong `.env`, khong hardcode.

---

## File lien quan

- [Tac vu Bat dong bo & Polling](./skill_async_task_polling.md)
- [Cau hinh Moi truong (.env)](./skill_env_configuration.md)
- [Cau truc Du an Tieu chuan (Skill DuyVo26)](./skill_project_structure.md)
- [Bao mat & Xac thuc](./skill_security_authentication.md)
