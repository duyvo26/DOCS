---
name: server-security-hardening
description: "Củng cố & Kiểm tra Bảo mật Toàn diện Máy chủ VPS/Production (Server Security & Hardening). Actions: audit, scan, configure, harden, fix, review. Keywords: server security, hardening, nginx security, fail2ban, ufw firewall, secret rotation, file permissions, php fpm security, security headers, leak protection, app.db leak"
argument-hint: "[audit|harden|fix] [server-security]"
metadata:
  author: duyvo26
  version: "1.0.0"
---

# Skill: Củng cố & Kiểm tra Bảo mật Máy chủ VPS/Production (Server Security & Hardening)

## Mục tiêu

Thiết lập, rà soát và củng cố an ninh toàn diện cho hệ thống máy chủ Linux (Ubuntu/Debian) vận hành các dịch vụ Web (Nginx, FastAPI/Python, PHP-FPM, SQLite/MySQL, WireGuard). Đảm bảo ngăn chặn triệt để nguy cơ rò rỉ cơ sở dữ liệu (`app.db`), lộ file môi trường (`.env`), tấn công brute-force SSH, tấn công dò quét cổng và thực thi mã độc từ xa.

---

## 1. Kiến trúc Phòng thủ Đa tầng (Defense in Depth)

```
┌─────────────────────────────────────────────────────────────────┐
│                     Internet / Cloudflare                       │
│    (Chống DDoS, SSL Edge, Ẩn IP gốc nếu qua Proxy)             │
└────────────────────────────────┬────────────────────────────────┘
                                 │
┌────────────────────────────────▼────────────────────────────────┐
│                   Hạ tầng Mạng & Tường lửa (OS)                 │
│      UFW: Default Deny Incoming (Chỉ mở 22, 80, 443, VPN)       │
│      Fail2ban: Tự động khóa IP brute-force SSH/Nginx            │
└────────────────────────────────┬────────────────────────────────┘
                                 │
┌────────────────────────────────▼────────────────────────────────┐
│                   Cổng vào Web Server (Nginx)                   │
│   - server_tokens off; (Ẩn phiên bản hệ điều hành & Nginx)      │
│   - Chặn tuyệt đối \.(db|sqlite|log|env|git|sh|py|sql|bak|conf) │
│   - Chặn file/thư mục ẩn bắt đầu bằng dấu chấm (/\.)            │
│   - Cô lập thư mục lưu trữ nội bộ (storage/logs, storage/*.db)  │
│   - 4 Security Headers: Frame, Sniff, XSS, Referrer             │
└────────────────────────────────┬────────────────────────────────┘
                                 │
┌────────────────────────────────▼────────────────────────────────┐
│               Môi trường Thực thi (Runtime Environments)        │
│   PHP 8.4-FPM: expose_php = Off; disable_functions shell;       │
│                Chỉ cho phép chạy index.php/router.php gốc       │
│   FastAPI Python: Uvicorn bind 127.0.0.1 (Không mở 0.0.0.0)     │
└────────────────────────────────┬────────────────────────────────┘
                                 │
┌────────────────────────────────▼────────────────────────────────┐
│              Quyền hạn Hệ thống Tệp (File System & Secrets)      │
│   - .env: chmod 600 www-data:www-data (Không dùng SECRET mặc định)
│   - app.db: chmod 660 www-data:www-data (Loại bỏ cờ thực thi +x)│
│   - WireGuard: chmod 600 /etc/wireguard/wg0.conf (root only)    │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Tiêu chuẩn Vàng Cấu hình Nginx (Nginx Hardening)

### 2.1. Quy tắc Chặn File Dữ liệu & Mã nguồn Nhạy cảm
Ngăn ngừa triệt để việc người ngoài tải file SQLite (`app.db`), nhật ký (`.log`) hay mã nguồn `.py`, `.sh`:

```nginx
# 1. Chặn tuyệt đối truy cập toàn bộ file mã nguồn và dữ liệu nhạy cảm
location ~* \.(db|sqlite|sqlite3|log|env|git|sh|py|sql|bak|conf|ini|yaml|yml)$ {
    deny all;
    return 404;
}

# 2. Chặn file và thư mục ẩn bắt đầu bằng dấu chấm
location ~ /\. {
    deny all;
    return 404;
}

# 3. Chặn truy cập trực tiếp vào logs và database trong storage
location ~* ^/storage/(logs|tasks|.*\.db$) {
    deny all;
    return 404;
}
```

### 2.2. Bộ 4 Header An toàn Bắt buộc & Ẩn Banner
```nginx
# Ẩn thông tin phiên bản Nginx
server_tokens off;

# Bộ 4 Security Headers bảo vệ người dùng
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
```

### 2.3. Cô lập Thực thi PHP trong Subdomain / Thư mục Static
Tuyệt đối không để Nginx thực thi file `.php` lạ do người dùng tải lên hoặc sinh ra trong các thư mục con:

```nginx
location ~ \.php$ {
    # Chỉ cho phép chạy duy nhất index.php hoặc router.php ở thư mục gốc
    if ($fastcgi_script_name !~* "^/(index|router)\.php$") {
        return 404;
    }
    include snippets/fastcgi-php.conf;
    fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
}
```

---

## 3. Quản lý Khóa Bí Mật & Phân Quyền Tệp (Secrets & Permissions)

### 3.1. Tuyệt đối KHÔNG DÙNG Khóa Mặc định trong Production
* **Lỗ hổng thường gặp**: Copy nguyên chuỗi `SECRET_KEY=auto-create-post-secret-key-32-characters-minimum` từ GitHub lên máy chủ production. Hậu quả: Kẻ tấn công tự rèn JWT token với `sub: "1"` để chiếm quyền Admin.
* **Chuẩn sinh khóa 256-bit**:
```bash
# Sinh chuỗi bí mật an toàn ngẫu nhiên
openssl rand -hex 32
```
* Cập nhật ngay vào `.env` của môi trường production, tuyệt đối không commit `.env` vào Git.

### 3.2. Bảng Phân Quyền Chuẩn (Permissions Matrix)

| Đường dẫn / Tệp | Quyền (Mode) | Chủ sở hữu (Owner) | Mục đích |
| :--- | :---: | :---: | :--- |
| `/var/www/<app>/.env` | `600` | `www-data:www-data` | Chỉ tiến trình web được đọc, ngăn chặn tiến trình khác |
| `/var/www/<app>/storage/*.db` | `660` | `www-data:www-data` | Loại bỏ bit thực thi (`+x`), chỉ cho phép app đọc/ghi |
| `/var/www/<app>/storage/` | `750` | `www-data:www-data` | Ngăn chặn truy cập thư mục từ user ngoài |
| `/etc/wireguard/wg0.conf` | `600` | `root:root` | Bảo vệ Private Key của mạng VPN |

Lệnh áp dụng:
```bash
chown www-data:www-data /var/www/<app>/.env
chmod 600 /var/www/<app>/.env

chown www-data:www-data /var/www/<app>/storage/*.db
chmod 660 /var/www/<app>/storage/*.db
chmod 750 /var/www/<app>/storage/
```

---

## 4. Tường lửa Hệ điều hành (UFW) & Chống Dò Quét (Fail2ban)

### 4.1. Quy trình Thiết lập UFW An toàn
Thực hiện theo thứ tự để không bao giờ bị khóa SSH ra khỏi máy chủ:
```bash
# 1. Thiết lập chính sách mặc định
ufw default deny incoming
ufw default allow outgoing

# 2. Cho phép dải mạng nội bộ (LAN Subnet)
ufw allow from 192.168.2.0/24 comment 'Local LAN Subnet'

# 3. Cho phép cổng dịch vụ thiết yếu
ufw allow 22/tcp comment 'SSH'
ufw allow 80/tcp comment 'HTTP'
ufw allow 443/tcp comment 'HTTPS'

# 4. Cho phép cổng VPN (WireGuard)
ufw allow 45693/udp comment 'WireGuard VPN Port'
ufw allow in on wg0 comment 'WireGuard VPN Interface'

# 5. Kích hoạt tường lửa
ufw --force enable
ufw status verbose
```

### 4.2. Cấu hình Fail2ban Chống Brute-force SSH
Cài đặt và thiết lập Jail riêng `/etc/fail2ban/jail.d/ssh-hardening.local`:
```ini
[sshd]
enabled = true
port = 22
filter = sshd
logpath = /var/log/auth.log
maxretry = 4
bantime = 3600
findtime = 600
```
Khởi động dịch vụ:
```bash
systemctl restart fail2ban
fail2ban-client status sshd
```

---

## 5. Tinh giản & Bảo mật PHP-FPM (PHP Hardening)

Trong file cấu hình `/etc/php/8.4/fpm/php.ini`:
1. **Ẩn phiên bản PHP**:
```ini
expose_php = Off
```
2. **Vô hiệu hóa các hàm thực thi shell nguy hiểm**:
```ini
disable_functions = exec,passthru,shell_exec,system,proc_open,popen,curl_multi_exec,parse_ini_file,show_source
```
3. **Tắt hiển thị lỗi trực tiếp ra màn hình**:
```ini
display_errors = Off
display_startup_errors = Off
log_errors = On
```
Khởi động lại: `systemctl restart php8.4-fpm`.

---

## 6. Kịch bản Kiểm tra Nhanh Tự động (Security Audit 1-Liner)

Chạy bộ lệnh sau trên máy chủ hoặc qua SSH để kiểm tra an toàn hệ thống trong 5 giây:

```bash
echo "=== KIEM TRA AN NINH MAY CHU ==="
echo "1. DB Leak (/storage/app.db):   $(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1/storage/app.db) (Mong đợi: 404)"
echo "2. Env Leak (/.env):             $(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1/.env) (Mong đợi: 404)"
echo "3. Logs Leak (/logs/app.log):    $(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1/storage/logs/app.log) (Mong đợi: 404)"
echo "4. Subdomain PHP Exec Check:     $(curl -s -H 'Host: test.contentnest.io.vn' http://127.0.0.1/shell.php -o /dev/null -w '%{http_code}') (Mong đợi: 404)"
echo "5. UFW Firewall:                 $(ufw status | head -n 1)"
echo "6. Fail2ban SSH:                 $(systemctl is-active fail2ban)"
echo "7. Nginx Version Leaked:         $(curl -sI http://127.0.0.1/ | grep -i '^server:' | tr -d '\r')"
```

---

## 7. Quy tắc Bắt buộc Khi Triển khai (Checklist)

1. **Tuyệt đối không để lọt file `.db`, `.env`, `.log` ra webroot** mà không có rule `location ~* \.(db|...)$ { deny all; return 404; }`.
2. **Không dùng `SECRET_KEY` mẫu**: Phải sinh ngẫu nhiên 256-bit độc lập khi setup server mới.
3. **Phân quyền tối thiểu**: File cấu hình mật luôn là `chmod 600`, thư mục dữ liệu là `chmod 750`.
4. **Luôn kích hoạt UFW và Fail2ban** ngay sau khi cài OS Ubuntu/Debian.
5. **Backend (Uvicorn, Node, Flask)**: Luôn bind vào `127.0.0.1`, không bao giờ bind thẳng ra `0.0.0.0` khi đã có Reverse Proxy.
6. **Frontend Cache-busting**: Mọi cập nhật CSS/JS phải bump version query param (`?v=v1.x.x`) và set header `max-age=120, must-revalidate` để tránh lưu cache lỗi trên Cloudflare/Browser.
