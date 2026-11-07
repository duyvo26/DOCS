---
name: wifi-management
description: "Quản lý Kết nối Wi-Fi trên Thiết bị Nhúng & Kiosk Linux (NetworkManager nmcli, Scan, Status, Connect, Disconnect, Touchscreen UI). Actions: setup, configure, implement, review, fix, optimize. Keywords: wifi, wifi management, nmcli, networkmanager, wifi scan, wifi connect, linux wifi, touch wifi settings, iot network"
argument-hint: "[action] [component]"
metadata:
  author: duyvo26
  version: "1.0.0"
---

# Skill: Quản lý Kết nối Wi-Fi trên Thiết bị Nhúng & Kiosk (Wi-Fi Management)

## Mục tiêu

Xây dựng module quản lý kết nối Wi-Fi toàn diện cho máy Kiosk / thiết bị nhúng / Raspberry Pi / x86 Terminal chạy hệ điều hành Linux. Hỗ trợ quét mạng xung quanh, xem trạng thái IP/cường độ sóng, kết nối mạng mới bằng mật khẩu và ngắt kết nối an toàn từ giao diện cảm ứng mà không cần mở Terminal.

---

## 1. Kiến trúc Luồng Xử lý

```
┌────────────────────────────────────────────────────────┐
│             Giao diện Cảm ứng (Touchscreen UI)         │
│  Thẻ trạng thái · Nút Quét mạng · Danh sách Wi-Fi ·    │
│  Hộp thoại nhập mật khẩu & nút Kết nối                 │
└───────────────────────────┬────────────────────────────┘
                            │ Fetch JSON
┌───────────────────────────▼────────────────────────────┐
│                  REST API (Flask / FastAPI)            │
│  GET  /api/wifi/status   (Trạng thái, SSID, IP, sóng)  │
│  GET  /api/wifi/scan     (Quét danh sách mạng)         │
│  POST /api/wifi/connect  (Kết nối SSID + mật khẩu)     │
│  POST /api/wifi/disconnect (Ngắt kết nối)              │
└───────────────────────────┬────────────────────────────┘
                            │ Subprocess (timeout an toàn)
┌───────────────────────────▼────────────────────────────┐
│                 Service Backend (Python)               │
│  app/services/wifi.py                                  │
│  - Parser định dạng nmcli -t (xử lý escape '\:')       │
│  - Phân loại bảo mật (WPA2/WPA3/Open)                  │
│  - Xử lý timeout, mapping mã lỗi tiếng Việt            │
└───────────────────────────┬────────────────────────────┘
                            │ CLI Invocation
┌───────────────────────────▼────────────────────────────┐
│           NetworkManager Daemon & nmcli tool           │
│           Linux Kernel Wireless Driver (cfg80211)      │
└────────────────────────────────────────────────────────┘
```

---

## 2. Backend Service Chuẩn (`app/services/wifi.py`)

Tạo module `app/services/wifi.py`:

```python
"""Quan ly ket noi mang Wi-Fi qua NetworkManager (nmcli)."""

from __future__ import annotations

import logging
import platform
import shutil
import subprocess
from typing import TypedDict

logger = logging.getLogger(__name__)


class WifiNetwork(TypedDict):
    ssid: str
    signal: int
    security: str
    connected: bool


class WifiStatus(TypedDict):
    enabled: bool
    connected: bool
    ssid: str | None
    ip: str | None
    signal: int | None
    interface: str | None


def _parse_nmcli_line(line: str) -> list[str]:
    """Tach dong xuat cua nmcli -t (cac cot ngan cach boi dau ':' va ho tro escape '\\:')."""
    parts: list[str] = []
    current: list[str] = []
    escaped = False
    for ch in line:
        if escaped:
            current.append(ch)
            escaped = False
        elif ch == "\\":
            escaped = True
        elif ch == ":":
            parts.append("".join(current))
            current = []
        else:
            current.append(ch)
    parts.append("".join(current))
    return parts


def _find_wifi_interface() -> str | None:
    """Tu dong tim ten card mang Wi-Fi kha dung (vi du: wlp2s0, wlan0)."""
    if platform.system() != "Linux" or not shutil.which("nmcli"):
        return None
    try:
        proc = subprocess.run(
            ["nmcli", "-t", "-f", "DEVICE,TYPE", "dev"],
            capture_output=True,
            text=True,
            timeout=3,
            check=False,
        )
        for line in proc.stdout.splitlines():
            parts = line.strip().split(":")
            if len(parts) >= 2 and parts[1].strip() == "wifi":
                return parts[0].strip()
    except Exception as exc:
        logger.debug("Loi tim card mang wifi: %s", exc)
    return None


def get_wifi_status() -> WifiStatus:
    """Lay trang thai Wi-Fi hien tai cua thiet bi."""
    if platform.system() != "Linux" or not shutil.which("nmcli"):
        # Du lieu mo phong cho moi truong dev/macOS/Windows
        return {
            "enabled": True,
            "connected": True,
            "ssid": "Mô phỏng Wi-Fi",
            "ip": "0.0.0.0",
            "signal": 85,
            "interface": "wlan0",
        }

    iface = _find_wifi_interface()
    if not iface:
        return {
            "enabled": False,
            "connected": False,
            "ssid": None,
            "ip": None,
            "signal": None,
            "interface": None,
        }

    # Kiem tra cong tac vo tuyen (radio)
    enabled = True
    try:
        proc_radio = subprocess.run(
            ["nmcli", "radio", "wifi"],
            capture_output=True,
            text=True,
            timeout=3,
            check=False,
        )
        enabled = proc_radio.stdout.strip().lower() == "enabled"
    except Exception:
        pass

    connected = False
    current_ssid = None
    ip_addr = None
    signal = None

    try:
        proc_dev = subprocess.run(
            ["nmcli", "-t", "-f", "GENERAL.CONNECTION,GENERAL.STATE,IP4.ADDRESS", "dev", "show", iface],
            capture_output=True,
            text=True,
            timeout=4,
            check=False,
        )
        for line in proc_dev.stdout.splitlines():
            if ":" not in line:
                continue
            key, val = line.split(":", 1)
            key, val = key.strip(), val.strip()
            if key == "GENERAL.CONNECTION" and val and val != "--":
                current_ssid = val
            elif key == "GENERAL.STATE":
                connected = "connected" in val.lower()
            elif key.startswith("IP4.ADDRESS") and not ip_addr and val:
                ip_addr = val.split("/")[0]
    except Exception as exc:
        logger.warning("Loi lay thong tin thiet bi wifi %s: %s", iface, exc)

    if connected and current_ssid:
        try:
            proc_sig = subprocess.run(
                ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL", "dev", "wifi"],
                capture_output=True,
                text=True,
                timeout=4,
                check=False,
            )
            for line in proc_sig.stdout.splitlines():
                parts = _parse_nmcli_line(line.strip())
                if len(parts) >= 3 and parts[0].strip() == "*":
                    try:
                        signal = int(parts[2].strip())
                    except ValueError:
                        pass
                    break
        except Exception:
            pass

    return {
        "enabled": enabled,
        "connected": connected and bool(current_ssid),
        "ssid": current_ssid if connected else None,
        "ip": ip_addr if connected else None,
        "signal": signal,
        "interface": iface,
    }


def scan_wifi() -> list[WifiNetwork]:
    """Quet va liet ke danh sach cac mang Wi-Fi kha dung, sap xep theo do uu tien."""
    if platform.system() != "Linux" or not shutil.which("nmcli"):
        return [
            {"ssid": "Wi-Fi Văn Phòng", "signal": 95, "security": "WPA2", "connected": True},
            {"ssid": "Khách_Free", "signal": 70, "security": "", "connected": False},
        ]

    cmd = ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "dev", "wifi", "list"]
    try:
        proc = subprocess.run(
            [*cmd, "--rescan", "yes"],
            capture_output=True,
            text=True,
            timeout=10,
            check=False,
        )
    except subprocess.TimeoutExpired:
        proc = subprocess.run(cmd, capture_output=True, text=True, timeout=5, check=False)
    except Exception as exc:
        logger.warning("Loi goi nmcli scan: %s", exc)
        return []

    networks_by_ssid: dict[str, WifiNetwork] = {}
    for line in proc.stdout.splitlines():
        parts = _parse_nmcli_line(line.strip())
        if len(parts) < 3:
            continue
        in_use = parts[0].strip() == "*"
        ssid = parts[1].strip()
        if not ssid or ssid == "--":
            continue
        try:
            signal = int(parts[2].strip())
        except ValueError:
            signal = 0
        security = parts[3].strip() if len(parts) > 3 else ""

        if ssid in networks_by_ssid:
            existing = networks_by_ssid[ssid]
            if in_use:
                existing["connected"] = True
            if signal > existing["signal"]:
                existing["signal"] = signal
            if security and not existing["security"]:
                existing["security"] = security
        else:
            networks_by_ssid[ssid] = {
                "ssid": ssid,
                "signal": signal,
                "security": security,
                "connected": in_use,
            }

    result = list(networks_by_ssid.values())
    # Mang dang ket noi len dau, tiep theo la cuong do song manh nhat
    result.sort(key=lambda n: (not n["connected"], -n["signal"], n["ssid"].lower()))
    return result


def connect_wifi(ssid: str, password: str = "") -> tuple[bool, str]:
    """Ket noi toi mot mang Wi-Fi theo SSID va mat khau."""
    clean_ssid = (ssid or "").strip()
    if not clean_ssid:
        return False, "Tên mạng (SSID) không được để trống."

    if platform.system() != "Linux" or not shutil.which("nmcli"):
        return True, f"[Mô phỏng] Đã kết nối thành công tới {clean_ssid}"

    clean_pwd = (password or "").strip()
    cmd = ["nmcli", "dev", "wifi", "connect", clean_ssid]
    if clean_pwd:
        cmd.extend(["password", clean_pwd])

    try:
        proc = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=25,
            check=False,
        )
        out = (proc.stdout + " " + proc.stderr).strip()
        if proc.returncode == 0:
            return True, f"Kết nối thành công tới '{clean_ssid}'"

        lower_out = out.lower()
        if "secrets were required" in lower_out or "password" in lower_out:
            return False, "Mật khẩu Wi-Fi không chính xác hoặc mạng yêu cầu mật khẩu."
        if "no network" in lower_out or "not found" in lower_out:
            return False, f"Không tìm thấy sóng mạng '{clean_ssid}'. Vui lòng quét lại."
        if "timeout" in lower_out:
            return False, "Quá thời gian kết nối (Timeout). Vui lòng thử lại."

        return False, f"Lỗi kết nối ({proc.returncode}): {out[:120]}"
    except subprocess.TimeoutExpired:
        return False, "Quá thời gian chờ phản hồi từ thiết bị Wi-Fi (25s)."
    except Exception as exc:
        return False, f"Lỗi hệ thống khi kết nối: {exc}"


def disconnect_wifi() -> tuple[bool, str]:
    """Ngat ket noi Wi-Fi hien tai."""
    if platform.system() != "Linux" or not shutil.which("nmcli"):
        return True, "[Mô phỏng] Đã ngắt kết nối Wi-Fi"

    iface = _find_wifi_interface()
    if not iface:
        return False, "Không tìm thấy card Wi-Fi"

    try:
        proc = subprocess.run(
            ["nmcli", "dev", "disconnect", iface],
            capture_output=True,
            text=True,
            timeout=10,
            check=False,
        )
        if proc.returncode == 0:
            return True, "Đã ngắt kết nối Wi-Fi thành công"
        return False, proc.stderr.strip() or "Không thể ngắt kết nối"
    except Exception as exc:
        return False, f"Lỗi khi ngắt kết nối: {exc}"
```

---

## 3. Khai báo REST API (`app/routes/device.py` hoặc `wifi.py`)

```python
from flask import Blueprint, jsonify, request
from app.services import wifi

bp = Blueprint("wifi", __name__, url_prefix="/api/wifi")

@bp.get("/status")
def wifi_status():
    return jsonify(wifi.get_wifi_status())

@bp.get("/scan")
def wifi_scan():
    return jsonify({"networks": wifi.scan_wifi()})

@bp.post("/connect")
def wifi_connect():
    data = request.get_json(silent=True) or {}
    ok, message = wifi.connect_wifi(
        ssid=data.get("ssid", ""),
        password=data.get("password", "")
    )
    return jsonify({"ok": ok, "message": message}), (200 if ok else 400)

@bp.post("/disconnect")
def wifi_disconnect():
    ok, message = wifi.disconnect_wifi()
    return jsonify({"ok": ok, "message": message}), (200 if ok else 400)
```

---

## 4. Giao diện Cảm ứng Tối ưu (HTML/CSS/JS)

### 4.1 HTML
```html
<div class="settings-block">
  <div class="section-head">
    <span class="label">Mạng Wi-Fi</span>
    <button type="button" class="btn btn-ghost btn-sm" id="btn-wifi-scan">
      <span>Quét mạng</span>
    </button>
  </div>

  <!-- Thẻ trạng thái kết nối -->
  <div class="wifi-status-card" id="wifi-status-card">
    <div class="wifi-status-indicator" id="wifi-status-indicator"></div>
    <div class="wifi-status-info">
      <span class="wifi-status-title" id="wifi-status-title">Đang kiểm tra kết nối…</span>
      <span class="wifi-status-sub" id="wifi-status-sub">—</span>
    </div>
    <button type="button" class="btn btn-ghost btn-sm" id="btn-wifi-disconnect" hidden>Ngắt kết nối</button>
  </div>

  <!-- Danh sách mạng -->
  <div class="wifi-list" id="wifi-list"></div>

  <!-- Form kết nối khi bấm vào 1 mạng -->
  <div class="wifi-connect-box" id="wifi-connect-box" hidden>
    <div class="wifi-connect-head">
      <span>Kết nối: <strong id="wifi-selected-ssid">—</strong></span>
      <span class="wifi-selected-sec" id="wifi-selected-sec"></span>
    </div>
    <div class="settings-form">
      <label class="settings-field" id="wifi-pwd-field">
        <span class="label">Mật khẩu Wi-Fi</span>
        <div style="display:flex;gap:6px;">
          <input type="password" class="settings-input" id="wifi-password" placeholder="Nhập mật khẩu" style="flex:1;" />
          <button type="button" class="btn btn-ghost btn-sm" id="btn-wifi-toggle-pwd">Hiện</button>
        </div>
      </label>
      <div class="sheet-actions">
        <button type="button" class="btn btn-primary" id="btn-wifi-connect">Kết nối</button>
        <button type="button" class="btn btn-ghost" id="btn-wifi-cancel">Huỷ</button>
      </div>
      <p class="pin-error" id="wifi-connect-error" hidden></p>
    </div>
  </div>
</div>
```

---

## Quy tắc bắt buộc

1. **Luôn xử lý ký tự escape `\:`**: Output của `nmcli -t` dùng dấu hai chấm để phân tách cột, các SSID hoặc BSSID có chứa dấu `:` sẽ bị escape thành `\:`. Không được dùng `.split(":")` đơn thuần.
2. **Bắt buộc có timeout cho subprocess**: Lệnh kết nối Wi-Fi có thể treo vĩnh viễn nếu sóng chập chờn. Giới hạn timeout 10s cho scan, 25s cho connect.
3. **Không ghi mật khẩu Wi-Fi ra file log**: Tuyệt đối không log tham số `password` trong logger để đảm bảo an toàn an ninh mạng nội bộ.
4. **Không chạy backend dưới quyền root**: Cấu hình quyền `nmcli` cho user thường thông qua Polkit hoặc Sudoers NOPASSWD.
5. **Cung cấp nút Hiện/Ẩn mật khẩu**: Bắt buộc trên màn hình cảm ứng để người vận hành kiểm tra tránh gõ nhầm.

---

## Troubleshooting

| Triệu chứng | Nguyên nhân thường gặp | Cách xử lý |
|---|---|---|
| Báo lỗi "Secrets were required, but not provided" | Nhập sai mật khẩu hoặc kết nối mạng có bảo mật mà không gửi mật khẩu | Kiểm tra lại mật khẩu Wi-Fi |
| Quét trả về mảng rỗng | Card Wi-Fi đang bận quét hoặc bị tắt radio | Kiểm tra `nmcli radio wifi`, chạy lại lệnh rescan |
| `nmcli: command not found` | Hệ thống chưa cài NetworkManager | Cài đặt `sudo apt install -y network-manager` |
| Kết nối thành công nhưng không có Internet/IP | DHCP server của router Wi-Fi chậm hoặc hết dải IP | Chờ 3-5 giây để NetworkManager nhận phát IP qua DHCP |

---

## File liên quan

- [Kiến trúc Kiosk Chuyên dụng](skill: kiosk-system)
- [Bảo mật & Xác thực Toàn diện](skill: security-authentication)
- [Cấu trúc Dự án Tiêu chuẩn](skill: project-structure)
