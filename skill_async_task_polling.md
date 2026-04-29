# Quy trình xử lý Tác vụ Bất đồng bộ & Polling (Standard Async Workflow)

Tài liệu này mô tả chi tiết quy trình chuẩn để xử lý các tác vụ nặng (Long-running Tasks) như xử lý AI, kết xuất báo cáo, hoặc phân tích dữ liệu lớn. Cơ chế này đảm bảo trải nghiệm người dùng không bị gián đoạn, tránh lỗi timeout và cho phép khôi phục trạng thái làm việc khi người dùng tải lại trang (F5).

---

## 1. Tổng quan Kiến trúc

Hệ thống sử dụng mô hình **Polling** (Hỏi vòng) kết hợp với **Background Tasks** (Tác vụ nền) của FastAPI.

### Luồng xử lý chính:
1.  **Frontend**: Gửi yêu cầu thực hiện tác vụ lên API (ví dụ: `POST /task/run`).
2.  **API Backend**:
    *   Tạo một `task_id` (UUID) duy nhất cho phiên làm việc.
    *   Khởi tạo trạng thái `processing` trong bộ nhớ tạm (In-Memory cache/store).
    *   Đẩy logic xử lý chính vào hàng đợi tác vụ nền (FastAPI `BackgroundTasks`).
    *   Trả về ngay `task_id` cho Frontend mà không chờ kết quả xử lý.
3.  **Frontend**:
    *   Nhận `task_id` và lưu vào `localStorage` kèm theo các tham số đầu vào (để phục hồi nếu người dùng reload trang).
    *   Thiết lập cơ chế gọi API (`GET /task/{task_id}`) định kỳ mỗi 2-3 giây để kiểm tra trạng thái.
4.  **Backend (Background Task)**:
    *   Thực hiện logic nghiệp vụ nặng (xử lý dữ liệu, gọi AI, v.v.).
    *   Khi hoàn tất hoặc gặp lỗi, cập nhật trạng thái (`done` hoặc `failed`) và kết quả vào bộ nhớ tạm.
    *   Cập nhật Database và trừ phí/token (nếu có).
5.  **Frontend**:
    *   Khi nhận được trạng thái kết thúc (`done`/`failed`), hiển thị kết quả hoặc thông báo lỗi.
    *   Xóa thông tin task khỏi `localStorage`.

---

## 2. Chi tiết Triển khai Backend (`app/routers/[feature_name].py`)

### A. Endpoint Khởi tạo Task
*   **Chức năng**: Tiếp nhận yêu cầu và cấp ID tác vụ.
*   **Lưu ý**: Hàm xử lý nền nên là hàm đồng bộ (`def`) để FastAPI chạy trong ThreadPool riêng, tránh gây nghẽn Event Loop.

```python
# Ví dụ cấu trúc chuẩn
@router.post("/run-task")
async def start_task(input_data: TaskSchema, background_tasks: BackgroundTasks):
    # 1. Kiểm tra điều kiện (quyền hạn, số dư, validate đầu vào...)
    
    # 2. Tạo ID duy nhất
    task_id = str(uuid.uuid4())
    
    # 3. Đánh dấu trạng thái đang xử lý vào store tạm
    task_store[task_id] = {"status": "processing", "start_time": time.time()}

    # 4. Đẩy vào background task
    background_tasks.add_task(heavy_logic_worker, task_id, input_data)

    return {"task_id": task_id}
```

### B. Endpoint Kiểm tra Trạng thái (`GET /task/{task_id}`)
Trả về trạng thái hiện tại của task từ store tạm. Store này có thể được xóa định kỳ sau một khoảng thời gian (TTL).

### C. Hàm xử lý nghiệp vụ (`heavy_logic_worker`)
Thực hiện các bước: Chạy logic -> Cập nhật DB -> Cập nhật trạng thái Store.

---

## 3. Cơ chế Frontend (React Component)

### A. Quản lý trạng thái và LocalStorage
Lưu `task_id` ngay khi bắt đầu để đảm bảo tính bền vững (Persistence).

```typescript
const startTask = async () => {
  setIsLoading(true);
  const result = await api.initiateTask(data);
  
  // Lưu để phục hồi khi F5
  localStorage.setItem('active_task_id', result.task_id);
  localStorage.setItem('active_task_input', JSON.stringify(data));
  
  startPolling(result.task_id);
};
```

### B. Cơ chế Polling (Hỏi vòng)
Sử dụng `setInterval` và dọn dẹp (cleanup) khi task kết thúc hoặc component unmount.

```typescript
const startPolling = (taskId: string) => {
  const interval = setInterval(async () => {
    const res = await api.checkTaskStatus(taskId);
    
    if (res.status === 'done' || res.status === 'failed') {
      clearInterval(interval);
      localStorage.removeItem('active_task_id');
      localStorage.removeItem('active_task_input');
      setIsLoading(false);
      // Xử lý hiển thị kết quả...
    }
  }, 2000);
};
```

### C. Khôi phục trạng thái (Auto-resume)
Sử dụng `useEffect` để kiểm tra các tác vụ còn dang dở khi người dùng quay lại trang.

```typescript
useEffect(() => {
  const savedTaskId = localStorage.getItem('active_task_id');
  if (savedTaskId) {
     setIsLoading(true);
     // Tự động tiếp tục hỏi vòng trạng thái
     startPolling(savedTaskId);
  }
}, []);
```
