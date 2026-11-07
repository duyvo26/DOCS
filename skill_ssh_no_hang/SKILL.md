---
name: ssh-no-hang
description: "Tránh treo SSH khi chạy tác vụ dài / restart service: detach process đúng cách (nohup+setsid+disown), kill theo PID, poll bounded, kiểm tra readiness qua HTTP. Actions: setup, configure, fix, optimize. Keywords: SSH hang, treo SSH, nohup, setsid, disown, detach, background process, restart uvicorn, restart service, long-running, deploy"
argument-hint: "[setup|fix|optimize]"
metadata:
  author: duyvo26
  version: "1.0.0"
---

# Skill: SSH No-Hang — Tránh treo SSH khi chạy tác vụ dài

## Vấn đề

Khi chạy lệnh dài (deploy, restart uvicorn, build, migration) qua SSH, session thường **không trả prompt** dù lệnh đã xong, vì process con kế thừa file descriptor của SSH channel.

## Nguyên nhân chính

1. **Process con giữ fd của SSH channel** (stdout/stderr/socket) → sshd giữ kênh mở.
2. **Kill/restart timing sai** — sleep cố định quá ngắn, curl kiểm tra quá sớm.
3. **`pkill -f pattern`** match cả chính SSH command line → kill nhầm.
4. **Không detach đúng** — chỉ `nohup ... &` chưa đủ.

## Quy tắc bắt buộc

### 1. Detach hoàn toàn process mới

```bash
nohup setsid bash -c 'cd /path/to/repo && exec bash start.sh' \
  </dev/null >/tmp/svc.log 2>&1 &
disown
exit 0
```

- `setsid` tách session mới (không còn controlling terminal).
- `disown` gỡ khỏi shell job list.
- `exit 0` ép SSH trả về ngay.
- stdio redirect hoàn toàn vào file, không kế thừa socket SSH.

### 2. Kill old process theo PID, không theo pattern

```bash
PID=$(pgrep -f '/uvicorn api:app' | head -n1)
[ -n "$PID" ] && kill "$PID" 2>/dev/null || true

# Poll bounded (tối đa 30s) thay vì sleep cố định
for i in $(seq 1 30); do
  pgrep -f '/uvicorn api:app' >/dev/null || break
  sleep 1
done
```

### 3. Kiểm tra readiness qua HTTP

```bash
for i in $(seq 1 60); do
  code=$(curl -sS -o /dev/null -w '%{http_code}' --max-time 3 http://127.0.0.1:8000/docs 2>/dev/null || echo 000)
  [ "$code" = "200" ] && break
  sleep 1
done
```

### 4. Bọc SSH bằng timeout

```bash
timeout 120 ssh pc@host "bash /tmp/restart.sh"
```

### 5. Dùng systemd/screen/tmux cho service dài

Thay vì spawn từ SSH, tạo service unit:

```ini
# /etc/systemd/system/gaussian-splatting.service
[Service]
ExecStart=/path/.venv/bin/uvicorn api:app --host 0.0.0.0 --port 8000
Restart=always
```

Restart: `sudo systemctl restart gaussian-splatting` — SSH chỉ chạy lệnh ngắn.

### 6. Kiểm tra fd leak

```bash
lsof -p <PID> | grep -i socket
```

Đảm bảo mọi child process redirect stdio vào file.

## Checklist trước khi chạy lệnh dài qua SSH

- [ ] Process mới được `setsid` + `disown` + `exit 0`
- [ ] stdio redirect hoàn toàn (không kế thừa SSH socket)
- [ ] Kill old process theo PID + poll bounded
- [ ] Readiness check qua HTTP
- [ ] Bọc bằng `timeout`
- [ ] Không dùng `pkill -f` với pattern rộng

## Quy tắc

1. Mọi lệnh dài qua SSH **PHẢI** detach theo mẫu trên.
2. Không sleep mù — luôn poll readiness.
3. Ưu tiên systemd/screen cho service production.
4. Nếu session vẫn treo → kill PID ssh client local: `pkill -f 'ssh ... host bash /tmp/...'`.
