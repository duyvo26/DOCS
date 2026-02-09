# Hướng dẫn Cấu hình SEO & Website

Tài liệu này hướng dẫn cách sử dụng tính năng quản lý SEO và cấu hình Website trực tiếp từ trang quản trị Admin.

## 1. Các thành phần quản lý
Hệ thống cho phép bạn điều chỉnh các thông số quan trọng của website mà không cần can thiệp trực tiếp vào mã nguồn:

- **Tiêu đề Website (SEO Title)**: Tương ứng với thẻ `<title>`.
- **Mô tả Website (SEO Description)**: Tương ứng với thẻ meta `description`.
- **Từ khóa SEO (Keywords)**: Tương ứng với thẻ meta `keywords`.
- **Tác giả (SEO Author)**: Tương ứng với thẻ meta `author`.
- **Logo Website**: Ảnh đại diện chính, đồng thời là ảnh chia sẻ (OG Image).
- **Favicon**: Biểu tượng trên tab trình duyệt.

## 2. Cơ chế đồng bộ hóa (Two-way Sync)
Hệ thống sử dụng cơ chế đồng bộ hai chiều giữa **Cơ sở dữ liệu (Database)** và **File vật lý (`frontend/index.html`)**:

### Từ Admin xuống File (Lưu cấu hình)
Khi bạn nhấn **"Lưu Thay Đổi Cấu Hình"**:
1. Dữ liệu được lưu vào bảng `settings` trong Database.
2. Backend tự động quét file `frontend/index.html`.
3. Sử dụng Regex thông minh để ghi đè các thẻ HTML tương ứng.
4. Cập nhật đồng bộ các thẻ mạng xã hội như `og:title`, `og:description`, `og:image`, `twitter:title`,...

### Từ File lên Admin (Sync từ HTML)
Tính năng **"Sync từ HTML"** cho phép:
1. Đọc nội dung thực tế đang có trong file `index.html`.
2. Điền tự động vào các ô nhập liệu trong Admin GUI.
3. Hữu ích khi bạn vừa cập nhật file thủ công hoặc muốn khôi phục dữ liệu từ mã nguồn.

## 3. Lưu ý quan trọng
- **Định dạng ảnh**: Nên sử dụng ảnh định dạng `.png` hoặc `.svg` cho Logo và Favicon để có độ sắc nét tốt nhất.
- **Dung lượng ảnh**: Ảnh Logo nên có kích thước vuông (ví dụ 512x512) để hiển thị đẹp khi chia sẻ lên Zalo/Facebook.
- **SEO Keywords**: Các từ khóa nên ngăn cách nhau bằng dấu phẩy (,).

## 4. Kỹ thuật (Dành cho Developer)
Các hàm xử lý chính nằm tại:
- **Backend**: `app/routers/admin.py` -> `update_index_html_seo` và `extract_seo_from_index_html`.
- **Frontend**: `frontend/components/AdminView.tsx` -> Tab `settings`.

Cơ chế cập nhật file sử dụng `re.sub` với flag `re.IGNORECASE | re.DOTALL` để đảm bảo nhận diện chính xác kể cả khi thẻ HTML nằm trên nhiều dòng.

## 5. Các đoạn mã quan trọng

### Cập nhật SEO (Backend)
```python
def update_index_html_seo(site_title, description, keywords, author, favicon_url, logo_url):
    # Regex thông minh xử lý mọi định dạng meta tag
    def update_meta(html_content, key, value, is_property=False):
        attr_name = "property" if is_property else "name"
        pattern = fr'<meta\s+[^>]*?{attr_name}=["\']{re.escape(key)}["\'][^>]*?>'
        new_tag = f'<meta {attr_name}="{key}" content="{value}">'
        # Logic replace hoặc insert...
```

### Sync từ mã nguồn (Frontend)
```tsx
const handleSyncFromFile = async () => {
    const res = await api.adminSyncFromHtml();
    setData((prev) => ({ ...prev, ...res }));
    toast.success('Đã tải SEO từ file HTML vào giao diện.');
};
```

### Route API Admin
```python
@router.get("/sync-from-html")
async def sync_from_html(admin: dict = Depends(get_current_admin)):
    html_seo = extract_seo_from_index_html()
    return html_seo
```
