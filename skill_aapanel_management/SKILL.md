---
name: aapanel-management
description: "Quản trị aaPanel / Baota Panel, Triển khai Ứng dụng (Python, Node.js, Go, Java, Web Tĩnh), Quản lý Reverse Proxy, Di chuyển Supervisor sang Python Project & Xử lý Lỗi Chuyên sâu (502 Bad Gateway, Kẹt Port, Path Collision Bug, Debug Reload Traps). Actions: setup, deploy, migrate, troubleshoot, fix, optimize. Keywords: aapanel, baota, btpanel, supervisor migration, python project, reverse proxy, 502 bad gateway, werkzeug debug trap, path collision, bt reload"
argument-hint: "[deploy|migrate|troubleshoot] [project-name]"
metadata:
  author: duyvo26
  version: "1.0.0"
---

# Skill: aaPanel / Baota Panel Management & Production Operations

## Mục tiêu

Cung cấp chuẩn mực kiến trúc, quy tắc triển khai, di chuyển dịch vụ (Supervisor sang Python Project), và cẩm nang xử lý sự cố chuyên sâu trên **aaPanel (Baota Panel)** chạy trên máy chủ Linux vật lý hoặc Proxmox LXC Container / VM.

---

## 1. Kiến trúc Quản lý Dự án của aaPanel

### 1.1 Cơ chế Vận hành của Python Project Manager
- **Cơ sở dữ liệu trung tâm:** `/www/server/panel/data/default.db` (bảng `sites` chứa cột `project_config` định dạng JSON).
- **Thư mục kịch bản khởi chạy:** `/www/server/python_project/vhost/scripts/<project_name>_cmd.sh`.
- **Thư mục lưu PID:** `/www/server/python_project/vhost/pids/<project_name>.pid`.
- **Thư mục nhật ký (Logs):** `/www/wwwlogs/python/<project_name>/error.log`.
- **Quản lý môi trường ảo (venv):** `/www/server/pyporject_evn/versions/` hoặc venv cục bộ trong mã nguồn (`<project_dir>/.venv`).

---

## 2. Quy trình Di chuyển từ Supervisor sang Python Project

Khi hệ thống có các ứng dụng đang chạy dưới **Supervisor 3.0.6** và cần đưa về giao diện **Python Project** để quản lý tập trung:

### 2.1 Bước 1: Khảo sát cấu hình Supervisor
1. Đọc file cấu hình Supervisor:
   `/www/server/panel/plugin/supervisor/profile/<program_name>.ini`
   Hoặc file tổng hợp: `/www/server/panel/plugin/supervisor/config.json`.
2. Xác định:
   - Thư mục chạy (`directory`).
   - Lệnh khởi động (`command`), biến môi trường (như `JAVA_HOME`, `JVM_PATH` nếu có).
   - Cổng mạng lắng nghe (`port`) và môi trường ảo (`.venv`).

### 2.2 Bước 2: Chuẩn hóa Script Khởi chạy (`exec`)
Trong script khởi chạy (`.start.sh` hoặc `start.sh`), **bắt buộc** thêm `exec` trước lệnh gọi Python:
```bash
#!/bin/bash
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export JVM_PATH=$JAVA_HOME/lib/server/libjvm.so

cd /www/project_dir
source .venv/bin/activate
exec python3 app.py
```
> **Tại sao cần `exec`:** Khi chạy `exec`, tiến trình Python sẽ thay thế trực tiếp tiến trình bash cha. Lệnh ghi PID của aaPanel (`echo $! > project.pid`) sẽ bắt đúng PID của Python. Nếu thiếu `exec`, PID được lưu là tiến trình bash; khi bash kết thúc, Python trở thành tiến trình mồ côi (orphan), khiến aaPanel báo sai trạng thái hoặc không thể tắt tiến trình khi bấm Stop.

### 2.3 Bước 3: Dừng và Gỡ bỏ khỏi Supervisor
Dừng tiến trình và dọn dẹp cấu hình Supervisor để tránh tranh chấp cổng (Port In Use):
```bash
/www/server/panel/pyenv/bin/supervisorctl -c /etc/supervisor/supervisord.conf stop <program_name>:*
rm -f /www/server/panel/plugin/supervisor/profile/<program_name>.ini
/www/server/panel/pyenv/bin/supervisorctl -c /etc/supervisor/supervisord.conf update
```

### 2.4 Bước 4: Đăng ký Dự án vào aaPanel Python Project
Sử dụng API nội bộ hoặc script Python để tạo cấu hình trong `default.db`:
```python
import sys
sys.path.insert(0, "/www/server/panel/class_v2")
sys.path.insert(0, "/www/server/panel/class")
import public
from projectModelV2.pythonModel import main as pyModel

m = pyModel()
get_obj = public.dict_obj()
get_obj.pjname = "<project_name>"
get_obj.path = "/www/<project_dir>"
get_obj.port = "<port>"
get_obj.stype = "command"
get_obj.user = "root"
get_obj.python_bin = "/usr/bin/python3.10"
get_obj.project_cmd = "bash .start.sh"
get_obj.auto_run = True
get_obj.framework = "python"
get_obj.env_list = "[]"
get_obj.env_file = ""
get_obj.requirement_path = "/www/<project_dir>/requirements.txt"
get_obj.auto_start = True

res = m.CreateProject(get_obj)
```

---

## 3. Các Lỗi Nghiêm Trọng Cần Lưu Ý & Cách Khắc Phục

### 3.1 Bug Core aaPanel: Nhận Nhầm Tiền Tố Đường Dẫn (Path Prefix Collision)
- **Triệu chứng:** Một dự án (ví dụ `/www/code`) bấm Start thì không chạy, nhưng bấm Stop lại làm tắt dự án khác (`/www/code_emini`).
- **Nguyên nhân:** Tại `/www/server/panel/class_v2/projectModelV2/pythonModel.py` (dòng ~1243), code gốc kiểm tra:
  ```python
  if v_path in i.exe() and i.cwd().startswith(path.rstrip("/")):
  ```
  Nếu có 2 thư mục `/www/code` và `/www/code_emini`, chuỗi `"/www/code_emini".startswith("/www/code")` trả về `True`, khiến aaPanel tưởng dự án đã chạy và bỏ qua không kích hoạt script khởi động.
- **Cách khắc phục:** Sửa điều kiện so sánh thư mục thành:
  ```python
  if v_path in i.exe() and (i.cwd() == path.rstrip("/") or i.cwd().startswith(path.rstrip("/") + "/")):
  ```
  Sau đó chạy `bt reload`.

### 3.2 Lỗi Kẹt Port do Flask Werkzeug Reloader (`debug=True`)
- **Triệu chứng:** Khởi động dự án Python báo `Address already in use` trên port (ví dụ: 8501).
- **Nguyên nhân:** Chạy `app.run(..., debug=True)` sinh ra tiến trình con watcher (watchdog). Khi aaPanel stop hoặc restart, chỉ có tiến trình cha bị kill; tiến trình con vẫn sống và giữ chặt port.
- **Cách khắc phục:** 
  1. Trên môi trường production / server, **luôn đặt `debug=False`** (hoặc `use_reloader=False`).
  2. Dùng lệnh `pkill -9 -f <script_name>` để giải phóng port bị kẹt trước khi khởi động lại.

### 3.3 Lỗi 502 Bad Gateway trên Reverse Proxy (Nginx / NPM)
Khi Nginx báo `502 Bad Gateway` trỏ về dự án aaPanel:
1. Kiểm tra backend có đang LISTEN không:
   `netstat -tlnp | grep <PORT>`
2. Thử curl trực tiếp tại máy chủ aaPanel:
   `curl -I http://127.0.0.1:<PORT>`
3. Nếu ứng dụng có cấu hình SSL riêng (như Gradio chạy `cert.pem` / `key.pem`), upstream của Reverse Proxy bắt buộc phải trỏ giao thức `https://<IP>:<PORT>` thay vì `http://`.

---

## 4. Bảng Tra cứu Lệnh Nhanh Vận hành aaPanel

| Thao tác | Câu lệnh Terminal |
|---|---|
| Khởi động lại giao diện aaPanel | `bt reload` |
| Xem trạng thái dịch vụ aaPanel | `bt status` |
| Xem thông tin đăng nhập admin panel | `bt 14` |
| Đổi mật khẩu admin panel | `bt 5` |
| Sửa lỗi / Cập nhật aaPanel | `bt 16` |
| Kiểm tra cổng mạng đang lắng nghe | `netstat -tlnp` |
| Xem log lỗi dự án Python | `tail -f /www/wwwlogs/python/<project_name>/error.log` |
