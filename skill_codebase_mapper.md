# Skill: Codebase Mapper — Phan tich Codebase va Tao map.md

## Muc tieu

Tu dong phan tich codebase va tao tai lieu dieu huong giup AI va lap trinh vien hieu nhanh cau truc du an.

---

## Cac buoc thuc hien

### Buoc 1: Phan tich codebase

- Doc cac file duoc cung cap.
- Xac dinh chuc nang chinh cua tung file.
- Xac dinh moi quan he giua cac file.
- Xac dinh cac file quan trong doi voi luong hoat dong cua he thong.

### Buoc 2: Tao Header Documentation cho file

Neu file chua co phan mo ta dau file, tao header phu hop.

Header can bao gom:
- Ten file
- Chuc nang chinh
- Vai tro trong he thong
- File lien quan (neu co)

### Buoc 3: Cap nhat map.md

Tao hoac cap nhat file `map.md`.

Muc dich cua `map.md`:
- La ban do tong quan cua codebase.
- Liet ke cac file quan trong.
- Mo ta chuc nang tung file.
- Giup AI hieu cau truc du an truoc khi chinh sua code.

### Buoc 4: Duy tri map.md

Khi:
- Them file moi
- Xoa file
- Doi chuc nang file
- Refactor cau truc du an

AI phai cap nhat lai `map.md`.

---

## Quy tac

1. Khong mo ta cac file qua nho hoac file sinh tu dong.
2. Uu tien cac file co logic nghiep vu.
3. Mo ta ngan gon, ro rang.
4. Khong suy doan chuc nang neu chua doc ma nguon.
5. Luon cap nhat `map.md` khi phat hien thay doi kien truc.
6. Header file phai phan anh dung chuc nang thuc te cua file.

---

## Ket qua mong muon

- Moi file quan trong co header mo ta.
- Du an co file `map.md` day du.
- AI moi tham gia du an co the doc `map.md` de hieu nhanh codebase.
- Viec bao tri va refactor tro nen de dang hon.
- Khi co nhieu du an, moi du an co folder rieng chua `map_{ten_du_an}.md` de tham khao.

---

## Ghi chu khi nguoi dung yeu cau "chuan hoa code"

Khi nguoi dung yeu cau chuan hoa code cho mot du an cu the (VD: "chuan hoa code chatbot-luat"), BAT BUOC:

1. Tao file `map.md` trong thu muc goc cua du an do (neu chua co).
2. Folder `{ten_du_an}/` (do nguoi dung tao tay) trong thu muc DOCS chua file `map_{ten_du_an}.md` de tham khao cau truc.
   - VD: `chatbot-luat/map_chatbot-luat.md`
3. Noi dung `map_{ten_du_an}.md`:
   - Ten du an
   - Mo ta tong quan
   - Danh sach file quan trong (duong dan, chuc nang, vai tro)
   - So do luong xu ly chinh (neu co)
   - File lien quan
4. Cap nhat `map.md` tong the (neu co) de dan den folder du an moi.

---

## File lien quan

- [Cau truc Du an Tieu chuan (Skill DuyVo26)](./skill_project_structure.md)
- [Tieu chuan Viet Code (Coding Conventions)](./skill_coding_conventions.md)
- [Cau hinh Moi truong (.env)](./skill_env_configuration.md)
