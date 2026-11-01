---
name: nginx-waf-reverse-proxy
description: "Quản trị Nginx Reverse Proxy, Tường lửa WAF, Stream Proxy (TCP/UDP) & Giám sát Phần cứng Proxmox LXC Container (NPM, WAF SOC, IP Grouping, lxcfs host_proc). Actions: setup, configure, secure, monitor, fix, optimize. Keywords: nginx proxy manager, npm, waf, reverse proxy, stream proxy, proxmox lxc, lxcfs, host_proc, docker on lxc, security tables, real log analysis"
argument-hint: "[setup|configure|secure|monitor] [nginx-waf]"
metadata:
  author: duyvo26
  version: "1.0.0"
---

# Skill: Nginx WAF & Reverse Proxy Manager (Proxmox LXC & Docker)

## Mục tiêu

Cung cấp chuẩn mực kiến trúc, quy tắc triển khai, cấu hình bảo mật và vận hành hệ thống **Nginx Proxy Manager tích hợp Tường lửa WAF & Stream TCP/UDP** chạy trên nền tảng **Docker bên trong Proxmox LXC Container (Docker-in-LXC)**.

Đảm bảo hệ thống đạt độ ổn định cao, hiển thị tài nguyên chuẩn xác, giám sát SOC với dữ liệu log thực tế 100%, bảo vệ an toàn trước các cuộc tấn công quét cổng mà không gây chặn nhầm lưu lượng người dùng hợp lệ.

---

## 1. Kiến trúc Hạ tầng Docker trên Proxmox LXC (Docker-in-LXC)

### Vấn đề cốt lõi của Docker trên LXC
- **Nguyên nhân:** Mặc định khi Docker container khởi chạy trong Proxmox LXC Container, Docker mount `/proc` trực tiếp từ **Linux Kernel của máy chủ mẹ**. Do đó, container sẽ nhìn thấy thông số phần cứng của toàn bộ máy chủ vật lý (ví dụ: 58 GB RAM, 20 Cores CPU) thay vì tài nguyên được giới hạn cho LXC Container (ví dụ: 2.25 GB RAM, 4 Cores CPU).
- **Nguy cơ lỗi Overlay2:** Không được mount đè trực tiếp từng file vào `/proc/...` bên trong container (`- /proc/meminfo:/proc/meminfo:ro`) vì khi chạy `docker cp` hoặc inspect container, Docker daemon sẽ cố gắng remount overlay2 gây lỗi `operation not permitted`.

### Giải pháp Chuẩn mực: Ánh xạ qua `/host_proc`
Trong file `docker-compose.yaml`, bind mount toàn bộ proc ảo của LXC vào thư mục độc lập `/host_proc`:

```yaml
services:
  app:
    image: 'duyvo26-nginx-proxy-manager:latest'
    restart: unless-stopped
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
      - /proc:/host_proc:ro
    network_mode: host
```

### Module Thu thập Tài nguyên (`backend/internal/system-metrics.js`)
Backend luôn ưu tiên đọc qua hàm trợ giúp `getProcFile()`:

```javascript
function getProcFile(filename) {
    const hostPath = `/host_proc/${filename}`;
    if (fs.existsSync(hostPath)) return hostPath;
    return `/proc/${filename}`;
}
```

- **Bộ nhớ RAM:** Đọc `/host_proc/meminfo` lấy `MemTotal`, `MemAvailable` (hoặc `MemFree + Buffers + Cached`), tính chính xác `memUsed` và tỷ lệ `%` RAM thực tế của CT.
- **CPU Cores & Model:** Đọc `/host_proc/cpuinfo` đếm số lượng `processor : \d+` và lấy `model name`.
- **Tải hệ thống & Uptime:** Đọc `/host_proc/loadavg` và `/host_proc/uptime`.

---

## 2. Quản trị Stream Proxy (TCP/UDP) & Nhóm theo IP

### Thiết kế Nhóm luồng (Grouped Streams by IP)
Khi hệ thống quản lý nhiều dịch vụ Stream (MySQL 3306, Redis 6379, WireGuard UDP, Minecraft 25565...), hiển thị phân tán theo từng cổng gây khó kiểm soát. Cần hỗ trợ:
1. **Gom nhóm theo IP Đích (Forwarding IP):** Bảng tổng hợp hiển thị rõ từng máy chủ đích nhận lưu lượng, số lượng cổng đang mở và danh sách các cổng chuyển tiếp.
2. **Chọn hàng loạt (Multi-Select):** Cho phép tích chọn từng Stream hoặc chọn tất cả trong một IP đích để thực hiện thao tác xóa hoặc đổi trạng thái đồng loạt.
3. **Bộ lọc & Tìm kiếm tức thì:** Tìm kiếm theo Cổng vào (Incoming Port), IP Đích (Forward IP), hoặc Ghi chú.

---

## 3. Tường lửa WAF & Trung tâm Giám sát SOC

### Nguyên tắc Dữ liệu Thực tế (100% Real Logs)
- Tuyệt đối **không sinh dữ liệu mẫu/mock ngẫu nhiên** trên màn hình bảo mật Production.
- Đọc và phân tích trực tiếp từ:
  - Nginx Default / Fallback access logs (`/data/logs/fallback_access.log`).
  - Nginx Default / Fallback error logs (`/data/logs/fallback_error.log`).
  - Nginx Stream logs (`/data/logs/stream-*.log`).
- **Phân loại Tấn công:**
  - `Scanner / Probing`: Truy vấn các path nhạy cảm (`/.env`, `/wp-login.php`, `/.git`, `/actuator`).
  - `SQL Injection (SQLi)`: Khớp regex chứa `UNION SELECT`, `OR 1=1`, `INFORMATION_SCHEMA`.
  - `Cross-Site Scripting (XSS)`: Khớp `<script>`, `onerror=`, `javascript:`.
  - `Path Traversal (LFI/RFI)`: Khớp `../`, `/etc/passwd`, `/win.ini`.
  - `Port Scanning / Probing`: Kết nối TCP/UDP thô vào các cổng mở nhưng không hoàn tất handshake.

### Bản đồ Tấn công Thế giới (SOC World Map)
- Tích hợp Geolocation từ cơ sở dữ liệu GeoIP offline/lightweight.
- Hiển thị tọa độ (Latitude, Longitude), quốc gia, cờ, loại tấn công và thời gian diễn ra theo thời gian thực.
- Cột sự kiện Live Stream có khả năng tạm dừng (Pause) hoặc cuộn mượt khi có đợt tấn công lớn.

---

## 4. Chiến lược Chặn IP An toàn (Tránh Tự Ban Nhầm Hệ Thống)

### Bài học cốt lõi
> [!CAUTION]
> **Không áp dụng cơ chế tự động cấm (Auto-Ban) quét toàn bộ log lỗi nếu ngưỡng quá thấp hoặc không phân biệt mạng nội bộ / dịch vụ quét định kỳ.**
> Việc tự động ghi `deny <ip>;` vào Nginx mỗi khi có 3 kết nối lỗi sẽ dẫn đến cấm nhầm:
> - Địa chỉ IP của chính quản trị viên khi đăng nhập lỗi hoặc refresh liên tục.
> - Địa chỉ IP mạng nội bộ (LAN 192.168.x.x, Proxmox 172.16.x.x, Loopback 127.0.0.1).
> - Các dịch vụ Healthcheck hoặc Webhook ngoài Internet.

### Quy tắc Vận hành An toàn
1. **Ưu tiên Cấm Thủ công (Manual Ban) hoặc Xác nhận:** Người vận hành chủ động bấm nút "Cấm IP" từ bảng phân tích Top Attacking IPs.
2. **Danh sách Trắng Tuyệt đối (Whitelist CIDR):**
   - Luôn tự động bỏ qua và cấm ghi `deny` đối với:
     - `127.0.0.1/8`, `::1`
     - Mạng riêng RFC 1918: `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`
     - Mạng máy chủ Cloudflare / Reverse Proxy tin cậy.
3. **Cơ chế Nhúng Nginx chuẩn xác:**
   - File cấu hình IP cấm: `/data/nginx/custom/banned_ips.conf`.
   - Nhúng an toàn vào cả HTTP/HTTPS và Stream:
     - `/data/nginx/custom/http_top.conf` -> `include /data/nginx/custom/banned_ips.conf;`
     - `/data/nginx/custom/stream.conf` -> `include /data/nginx/custom/banned_ips.conf;`
   - Khi không có IP nào bị cấm, file phải chứa `# No banned IPs` để tránh lỗi cú pháp Nginx.

---

## 5. Chuẩn UI/UX Tabler & Tối ưu Giao diện

1. **Thành phần ScrollView & Sticky Headers:**
   - Mọi bảng dữ liệu có trên 20 bản ghi (Banned IPs, Attack Events, Whitelist, Grouped Streams) phải được bọc trong container `ScrollView` có thanh cuộn mỏng (6px) và `position: sticky; top: 0` trên thanh tiêu đề `<thead>`.
2. **Nút "Go to Top" cuộn mượt:**
   - Tự động hiển thị khi cuộn màn hình xuống quá `220px`.
   - Bấm vào cuộn mượt lên đỉnh với hiệu ứng `smooth`.
3. **Biểu đồ Donut Responsive:**
   - Không đặt kích thước pixel cố định cứng (`width: 220px`) trong các cột hẹp (`col-sm-5`).
   - Sử dụng Flexbox (`d-flex flex-column flex-sm-row`) và co giãn đường kính SVG phù hợp (`160px` hoặc tỉ lệ `viewBox`) để chữ ở tâm và chú thích không bao giờ bị đè lên nhau.
4. **Hỗ trợ Đa ngôn ngữ (Song ngữ Toàn diện EN/VI):**
   - Mọi nhãn, thông báo, card phần cứng, trạng thái mạng đều phải có khóa trong `frontend/src/locale/lang/en.json` và `vi.json`.
   - Không hiển thị hard-code tiếng Anh hoặc tiếng Việt xen kẽ không đồng bộ.

---

## 6. Sổ tay Lệnh Vận hành & Cứu hộ Nhanh (Cheat Sheet)

```bash
# 1. Kiểm tra trạng thái container và tài nguyên thực tế
docker exec root-app-1 head -n 5 /host_proc/meminfo
docker exec root-app-1 grep -c processor /host_proc/cpuinfo

# 2. Kiểm tra cú pháp Nginx bên trong container
docker exec root-app-1 nginx -t

# 3. Reload Nginx không gián đoạn dịch vụ
docker exec root-app-1 nginx -s reload

# 4. Cứu hộ: Xóa sạch danh sách cấm khi bị chặn nhầm
echo "# Empty banned IPs" > /root/data/nginx/custom/banned_ips.conf
echo "# Empty http_top" > /root/data/nginx/custom/http_top.conf
echo "# Empty stream" > /root/data/nginx/custom/stream.conf
echo "[]" > /root/data/waf_banned.json
docker exec root-app-1 nginx -s reload

# 5. Lưu trạng thái container vào image sau khi cập nhật
docker commit root-app-1 duyvo26-nginx-proxy-manager:latest
```
