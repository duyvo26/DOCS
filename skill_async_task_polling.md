# Skill: Tác vụ Bất đồng bộ & Polling (Standard Async Workflow)

## Mục tiêu

Mô tả quy trình chuẩn để xử lý các tác vụ nặng (Long-running Tasks) như xử lý AI, kết xuất báo cáo, phân tích dữ liệu lớn. Đảm bảo trải nghiệm người dùng không bị gián đoạn, tránh lỗi timeout, cho phép khôi phục trạng thái khi F5.

---

## 1. Tổng quan Kiến trúc

Hệ thống sử dụng mô hình **Polling** kết hợp với **Background Tasks** của FastAPI.

**Luồng xử lý:**
1. Frontend gửi yêu cầu -> API tạo `task_id` (UUID) -> Trả về ngay `task_id`
2. Frontend lưu `task_id` vào `localStorage` -> Polling `GET /task/{id}` mỗi 2-3 giây
3. Backend xử lý background -> Cập nhật trạng thái (`done`/`failed`)
4. Frontend nhận kết quả -> Xóa `task_id` khỏi `localStorage`

---

## 2. Backend Implementation

### A. Endpoint Khởi tạo Task
```python
@router.post("/run-task")
async def start_task(input_data: TaskSchema, background_tasks: BackgroundTasks):
    task_id = str(uuid.uuid4())
    task_store[task_id] = {"status": "processing", "start_time": time.time()}
    background_tasks.add_task(heavy_logic_worker, task_id, input_data)
    return {"task_id": task_id}
```

### B. Endpoint Kiểm tra Trạng thái
```python
@router.get("/task/{task_id}")
async def check_task(task_id: str):
    return task_store.get(task_id, {"status": "not_found"})
```

---

## 3. Frontend Implementation

```typescript
const startPolling = (taskId: string) => {
    const interval = setInterval(async () => {
        const res = await api.checkTaskStatus(taskId);
        if (res.status === 'done' || res.status === 'failed') {
            clearInterval(interval);
            localStorage.removeItem('active_task_id');
            // Xử lý kết quả
        }
    }, 2000);
};

// Khôi phục khi F5
useEffect(() => {
    const savedTaskId = localStorage.getItem('active_task_id');
    if (savedTaskId) startPolling(savedTaskId);
}, []);
```

---

## Quy tắc bắt buộc

1. Mỗi task phải có `task_id` UUID duy nhất.
2. Frontend phải lưu `task_id` vào `localStorage` để khôi phục khi F5.
3. Polling interval: 2-3 giây (không nhỏ hơn 1 giây).
4. Khi task hoàn thành, xóa `task_id` khỏi `localStorage`.
5. Task hết hạn (timeout) sau 10 phút.

---

## File liên quan

- [Cấu trúc Dự án Tiêu chuẩn (Skill DuyVo26)](./skill_project_structure.md)
- [Kiến trúc Chatbot & LLM](./skill_chatbot_architecture.md)
- [Thanh toán Polling & Sync](./skill_payment_polling_sync.md)
