---
name: kiosk-system
description: "Kiến trúc Kiosk Chuyên dụng (Debian/Ubuntu, GNOME Kiosk, Wayland, Chromium Kiosk, Auto-login, Virtual Keyboard, Watchdog). Actions: setup, configure, implement, review, fix, optimize. Keywords: kiosk, kiosk mode, gnome-kiosk, wayland kiosk, chromium kiosk, virtual keyboard, auto-login, embedded linux, touchscreen kiosk"
argument-hint: "[setup|configure|fix] [kiosk-system]"
metadata:
  author: duyvo26
  version: "1.0.0"
---

# Skill: Kiến trúc Kiosk Chuyên dụng (Dedicated Kiosk System)

## Mục tiêu

Thiết kế, cài đặt, cấu hình và vận hành hệ thống Kiosk chuyên dụng (Dedicated Kiosk Terminal / IoT Touchscreen Device / Máy công nghiệp) trên nền Linux (Debian 12/13, Ubuntu Server/Desktop). Đảm bảo giao diện web tự động mở toàn màn hình khi bật máy, chặn hoàn toàn Desktop thông thường, tự phục hồi khi crash và hỗ trợ màn hình cảm ứng mượt mà.

---

## 1. Kiến trúc Tổng quan

```
┌─────────────────────────────────────────────────────────────┐
│                   Phần cứng Kiosk                           │
│  (Màn hình cảm ứng Touchscreen, Camera, Serial, USB, Wifi)  │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│                    Linux OS (Debian/Ubuntu)                 │
│         Kernel + Systemd + Udev + NetworkManager            │
└──────────────┬───────────────────────────────┬──────────────┘
               │                               │
┌──────────────▼─────────────┐   ┌─────────────▼──────────────┐
│ Backend Systemd Service    │   │ Wayland Display Manager    │
│ (Flask / FastAPI Backend)  │   │ GDM Auto-Login Session     │
│ Port 8000 / SQLite / Venv  │   │ (gnome-kiosk / Cage)       │
└──────────────┬─────────────┘   └─────────────┬──────────────┘
               │                               │
               │         HTTP Localhost        │
               └───────────────┬───────────────┘
                               │
                 ┌─────────────▼─────────────┐
                 │ Chromium Kiosk Fullscreen │
                 │ --kiosk --start-fullscreen│
                 │ --password-store=basic    │
                 │ --enable-virtual-keyboard │
                 └───────────────────────────┘
```

### Nguyên tắc khác biệt so với Desktop thông thường:
1. **Không nạp môi trường Desktop nặng nề**: Không GNOME Shell, không Dock, không thanh trạng thái (Top bar), không thông báo hệ thống làm che khuất giao diện vận hành.
2. **Khởi động một ứng dụng duy nhất**: Máy bật lên chỉ thấy ứng dụng web toàn màn hình (`--kiosk`).
3. **Tự phục hồi (Self-Healing)**: Backend chạy qua `systemd` tự khởi động lại nếu lỗi; Chromium chạy trong vòng lặp watchdog để tự bật lại nếu bị đóng.
4. **Trải nghiệm cảm ứng (Touch-First)**: Chống thao tác zoom/pinch ngoài ý muốn, chống vuốt lùi trang (overscroll navigation), tự bật bàn phím ảo khi chạm ô nhập liệu.

---

## 2. Cấu hình Tự động Đăng nhập (Auto-Login) & Session Kiosk

### 2.1 Cài đặt thành phần Kiosk Wayland

Trên Debian 12/13 hoặc Ubuntu:
```bash
sudo apt update
sudo apt install -y gnome-kiosk chromium python3-venv python3-pip
```

### 2.2 Cấu hình GDM3 Auto-Login

Tạo hoặc sửa `/etc/gdm3/daemon.conf`:
```ini
[daemon]
AutomaticLoginEnable=true
AutomaticLogin=pc
```
*(Thay `pc` bằng tên người dùng vận hành của máy).*

### 2.3 Chỉ định Session Kiosk cho User

Cập nhật file `/var/lib/AccountsService/users/<username>`:
```ini
[User]
Session=gnome-kiosk-script-wayland
XSession=gnome-kiosk-script-wayland
SystemAccount=false
```

Khi máy khởi động, GDM3 sẽ tự động đăng nhập user trực tiếp vào session `gnome-kiosk-script-wayland`, phiên này sẽ thực thi script tại `~/.local/bin/gnome-kiosk-script`.

---

## 3. Script Khởi chạy Kiosk Chuẩn (`start-kiosk.sh`)

Tạo file `~/.local/bin/gnome-kiosk-script` (hoặc đặt trong repo rồi symlink):

```bash
#!/usr/bin/env bash
set -e

# 1. Đợi backend khởi động và phản hồi sẵn sàng trước khi nạp trang
while ! curl -s http://127.0.0.1:8000/health >/dev/null && ! curl -s http://127.0.0.1:8000/ >/dev/null; do
  sleep 0.5
done

# 2. Xoá cờ crash cũ nếu có để Chromium không hiện popup khôi phục tab
USER_DATA_DIR="${HOME}/.config/chromium-kiosk"
if [ -f "${USER_DATA_DIR}/Default/Preferences" ]; then
  sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/' "${USER_DATA_DIR}/Default/Preferences" 2>/dev/null || true
fi

# 3. Vòng lặp Watchdog: Nếu Chromium tắt hoặc bị tắt, tự mở lại ngay lập tức
while true; do
  chromium \
    --kiosk \
    --start-fullscreen \
    --no-first-run \
    --no-default-browser-check \
    --password-store=basic \
    --enable-virtual-keyboard \
    --disable-infobars \
    --disable-session-crashed-bubble \
    --disable-translate \
    --disable-features=Translate \
    --disable-pinch \
    --overscroll-history-navigation=0 \
    --autoplay-policy=no-user-gesture-required \
    --check-for-update-interval=31536000 \
    --user-data-dir="${USER_DATA_DIR}" \
    "http://127.0.0.1:8000"
  
  sleep 1
done
```

Cấp quyền thực thi:
```bash
chmod +x ~/.local/bin/gnome-kiosk-script
```

---

## 4. Bảng Flags Chromium "Sống Còn" Cho Kiosk

| Flag | Mục đích | Hậu quả nếu thiếu |
|---|---|---|
| `--kiosk` | Khóa trình duyệt ở chế độ Kiosk (ẩn URL bar, tabs, menu) | Người vận hành thấy thanh địa chỉ |
| `--start-fullscreen` | Chiếm toàn bộ độ phân giải màn hình | Xuất hiện viền cửa sổ |
| `--password-store=basic` | **CỰC KỲ QUAN TRỌNG**: Tắt lưu trữ khóa qua GNOME Keyring | **Hệ thống auto-login sẽ bị chặn bởi popup bắt nhập mật khẩu "Unlock Login Keyring"** |
| `--enable-virtual-keyboard` | Tự động kích hoạt bàn phím ảo cảm ứng khi chạm vào ô `<input>` | Không gõ được chữ/mật khẩu trên màn hình cảm ứng |
| `--disable-infobars` | Ẩn các thanh cảnh báo của trình duyệt | Hiện cảnh báo bảo mật hoặc extension |
| `--disable-session-crashed-bubble` | Tắt popup "Restore pages? Chromium didn't shut down correctly" | Người dùng thấy hộp thoại phiền phức khi máy bị ngắt điện đột ngột |
| `--disable-pinch` | Tắt cử chỉ chụm/zoom bằng nhiều ngón tay | Giao diện bị phóng to làm vỡ layout |
| `--overscroll-history-navigation=0` | Chặn vuốt mép màn hình để Back/Forward | Người dùng vô tình vuốt làm thoát trang |
| `--user-data-dir=...` | Tạo thư mục cấu hình riêng biệt | Tránh xung đột với trình duyệt cá nhân của hệ thống |

---

## 5. Dịch vụ Backend Systemd Chuẩn

Tạo file `/etc/systemd/system/<app-name>-backend.service`:

```ini
[Unit]
Description=May Phan Tich - Dedicated Backend Service
After=network.target

[Service]
Type=simple
User=pc
Group=pc
WorkingDirectory=/opt/may-phan-tich
Environment="PATH=/opt/may-phan-tich/.venv/bin:/usr/local/bin:/usr/bin:/bin"
Environment="PYTHONUNBUFFERED=1"
Environment="APP_TIMEZONE=Asia/Ho_Chi_Minh"
ExecStart=/opt/may-phan-tich/.venv/bin/python3 run.py
Restart=always
RestartSec=2
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

Kích hoạt và chạy dịch vụ:
```bash
sudo systemctl daemon-reload
sudo systemctl enable <app-name>-backend.service
sudo systemctl start <app-name>-backend.service
```

---

## 6. Phân Quyền Phần Cứng & Tắt Máy Không Cần Mật Khẩu

Kiosk thường cần kết nối Camera, Cổng Serial điều khiển động cơ, Ổ USB và lệnh tắt máy.

### 6.1 Gán nhóm ngoại vi cho user
```bash
sudo usermod -aG video,dialout,plugdev pc
```

### 6.2 Cấp quyền tắt máy qua Sudoers (NOPASSWD)
Tạo file `/etc/sudoers.d/pc-kiosk`:
```text
pc ALL=(ALL) NOPASSWD: /sbin/shutdown, /sbin/reboot, /usr/bin/nmcli
```
Cấp quyền file:
```bash
sudo chmod 0440 /etc/sudoers.d/pc-kiosk
```

---

## Quy tắc bắt buộc

1. **Luôn dùng `--password-store=basic`** cho Chromium khi chạy Auto-login để không bao giờ bị hỏi mật khẩu GNOME Keyring.
2. **Không chạy trình duyệt dưới quyền `root`** — chạy dưới user thường (`pc`), cấp quyền thiết bị qua Linux Groups (`video`, `dialout`).
3. **Phải kiểm tra backend sẵn sàng** (`while ! curl ...; do sleep 0.5; done`) trước khi mở Chromium để không bao giờ xuất hiện màn hình báo lỗi mạng `ERR_CONNECTION_REFUSED`.
4. **Chống vuốt điều hướng**: Bắt buộc có `--disable-pinch` và `--overscroll-history-navigation=0` cho mọi màn hình cảm ứng.
5. **Cấu hình múi giờ hệ thống chuẩn**: Luôn đặt `timedatectl set-timezone Asia/Ho_Chi_Minh` để đồng hồ và logs luôn chính xác theo giờ địa phương.

---

## Troubleshooting

| Triệu chứng | Nguyên nhân thường gặp | Cách xử lý |
|---|---|---|
| Khởi động bị kẹt hỏi mật khẩu "Unlock Keyring" | Auto-login không mở khóa GNOME Keyring | Thêm cờ `--password-store=basic` và xóa `~/.local/share/keyrings/*` |
| Máy vẫn hiện Desktop GNOME sau khi khởi động | GDM load session mặc định thay vì Kiosk | Sửa `/var/lib/AccountsService/users/<user>` đặt `Session=gnome-kiosk-script-wayland` |
| Bấm vào ô input không hiện bàn phím ảo | Thiếu cờ virtual keyboard | Thêm `--enable-virtual-keyboard` vào lệnh chạy Chromium |
| Tắt máy hoặc cúp điện đột ngột xong mở lên báo "Restore pages" | Cờ `exit_type` bị ghi là `Crashed` | Thêm lệnh `sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/'` trong script khởi chạy |
| Camera không mở được (`Permission Denied`) | User chưa thuộc nhóm `video` | Chạy `sudo usermod -aG video <user>` |

---

## File liên quan

- [Cấu trúc Dự án Tiêu chuẩn](skill: project-structure)
- [Quản lý Mạng Wi-Fi](skill: wifi-management)
- [Logging & Monitoring Chuẩn](skill: logging-monitoring)
