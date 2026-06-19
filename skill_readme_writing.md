# Skill: Viet README.md Chuan (README Writing Guide)

## Muc tieu

Quy dinh cach viet file `README.md` chuan cho moi du an. README la cua ngo dau tien de Developer, AI Agent va doi tac hieu du an.

---

## 1. Cau truc README Bat buoc (7 phan)

```
1. Tong quan du an (Project Overview)
2. Yeu cau he thong (System Requirements)
3. Cai dat & Chay thu cuc bo (Local Setup)
4. Cau hinh bien moi truong (Environment Variables)
5. Cau truc thu muc (Project Structure)
6. Danh sach API Endpoint (API Reference)
7. Huong dan Trien khai (Deployment)
```

Xem mau README day du trong file source.

---

## 2. Quy tac Viet README

- Viet bang tieng Viet thuan hoac thuan Anh, khong tron lan.
- Khong dung emoji.
- Code block phai co nhan ngon ngu (` ```bash `, ` ```python `).
- Bang bien moi truong phai day du: ten, mo ta, vi du.
- Buoc cai dat phai copy-paste chay duoc ngay.
- Cap nhat README khi thay doi cau truc du an.

---

## 3. Quy tac .env.example

```bash
# .env.example — File nay DUOC commit len Git
SECRET_KEY=your-secret-key-here
API_KEY=your-api-key
# ... placeholder, khong phai gia tri that
```

---

## Checklist truoc khi commit README

- [ ] Co day du 7 phan chinh
- [ ] Buoc cai dat da test chay thu
- [ ] Bang bien moi truong dong bo voi `.env.example`
- [ ] Cau truc thu muc khop voi thuc te
- [ ] Khong co emoji
- [ ] Code block co nhan ngon ngu

---

## File lien quan

- [Cau truc Du an Tieu chuan (Skill DuyVo26)](./skill_project_structure.md)
- [Cau hinh Moi truong (.env)](./skill_env_configuration.md)
- [Tieu chuan Viet Code (Coding Conventions)](./skill_coding_conventions.md)
