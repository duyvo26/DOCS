# Skill: Quan ly SEO Dong (Dynamic SEO Manager)

## Muc tiet

Thay the truc tiep Meta Tag trong file tinh `index.html` cua React giup chia se link hieu qua (Facebook, Zalo). Su dung co che Dynamic HTML Modification: ghi truc tiep vao file vat ly thay vi render bang Javascript.

---

## 1. Co che Dong bo Hai chieu

### A. Push: DB xuong File HTML
Khi Admin luu, he thong:
1. Luu vao bang `settings` trong DB
2. Dung Regex de thay the gia tri trong `frontend/index.html`

```python
def update_index_html_seo(title, description, keywords, author):
    content = read("frontend/index.html")
    content = re.sub(r'<title>.*?</title>', f'<title>{title}</title>', content)
    # Thay meta tags...
    write("frontend/index.html", content)
```

### B. Pull: File HTML len UI
Admin co the nhan "Sync tu HTML" de lay gia tri tu file vao DB.

---

## 2. Quan ly Tai Nguyen (Logo, Favicon)

- Sanitize filename bang `uuid.uuid4()` + `os.path.basename()`
- Luu vao `utils/download/`
- Tra ve URL: `/api/v1/download/{filename}`

---

## Quy tac bat buoc

1. Luon su dung Regex de thay the, khong dung string replace thuan.
2. File `index.html` phai co cac placeholder meta tags mac dinh.
3. Backup file truoc khi ghi de.
4. Logo upload < 500KB.
5. Kiem tra Canonical, Robot tags sau khi update.

---

## File lien quan

- [Kien truc Frontend & API Setup](./skill_frontend_architecture.md)
- [Chia nho Components & Domain Routing](./skill_frontend_routing_components.md)
- [Cau hinh Moi truong (.env)](./skill_env_configuration.md)
