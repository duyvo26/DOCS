
# Cơ chế Gửi Task và Kiểm tra trạng thái Task (GPT Checker)

Tài liệu này mô tả chi tiết quy trình xử lý bất đồng bộ (Asynchronous Processing) cho tính năng kiểm tra văn bản GPT (AI Detection) trong hệ thống. Cơ chế này giúp đảm bảo trải nghiệm người dùng mượt mà, tránh timeout khi xử lý các đoạn văn bản dài và cho phép phục hồi trạng thái khi người dùng tải lại trang (F5).

---

## 1. Tổng quan Kiến trúc

Hệ thống sử dụng mô hình **Polling** (Hỏi vòng) kết hợp với **Background Tasks** (Tác vụ nền) của FastAPI.

### Luồng xử lý chính:
1.  **Frontend** gửi văn bản cần kiểm tra lên API (`POST /predict`).
2.  **API Backend**:
    *   Tạo một `task_id` (UUID) duy nhất.
    *   Khởi tạo trạng thái `processing` trong bộ nhớ tạm (In-Memory).
    *   Đẩy tác vụ xử lý AI nặng vào hàng đợi xử lý nền (Background Task).
    *   Trả về ngay `task_id` cho Frontend (Không chờ kết quả AI).
3.  **Frontend**:
    *   Nhận `task_id`.
    *   Lưu `task_id` và nội dung văn bản vào `localStorage` (để phục hồi nếu F5).
    *   Liên tục gọi API (`GET /task/{task_id}`) mỗi 2 giây để kiểm tra trạng thái.
4.  **Backend (Background Worker)**:
    *   Thực hiện chạy mô hình AI (PhoBERT) để phân tích.
    *   Khi hoàn tất, cập nhật trạng thái `done` và kết quả vào bộ nhớ tạm.
    *   Lưu lịch sử vào Database và trừ tiền (token) của người dùng.
5.  **Frontend**:
    *   Nhận được trạng thái `done` từ API.
    *   Hiển thị kết quả cho người dùng.
    *   Xóa `task_id` khỏi `localStorage`.

---

## 2. Chi tiết API Backend (`app/routers/gpt_checker.py`)

### A. Endpoint Khởi tạo Task (`POST /api/v1/gpt-checker/predict`)
*   **Chức năng**: Tiếp nhận yêu cầu kiểm tra văn bản.
*   **Xử lý**:
    *   Kiểm tra số dư Token của người dùng.
    *   Tính toán chi phí dự kiến.
    *   Tạo `task_id` bằng UUID4.
    *   Sử dụng `BackgroundTasks` của FastAPI để chạy hàm `background_prediction_task`.
*   **Lưu ý quan trọng**: Hàm `background_prediction_task` được định nghĩa là **đồng bộ (def)** thay vì bất đồng bộ (`async def`) để FastAPI tự động chạy trong ThreadPool, tránh chặn (block) Event Loop chính của server. điều này giúp server vẫn phản hồi các request khác (như `auth/check`) trong khi đang chạy AI.

```python
# app/routers/gpt_checker.py

@router.post("/predict")
async def start_predict_gpt(text_input: TextInput, background_tasks: BackgroundTasks, ...):
    # ... logic kiểm tra token ...
    
    task_id = str(uuid.uuid4())
    # Lưu trạng thái ban đầu
    task_results[task_id] = {"status": "processing", "timestamp": time.time()}

    # Đẩy vào background task (Lưu ý: hàm background_prediction_task là def thường)
    background_tasks.add_task(background_prediction_task, task_id, text_input.text, ...)

    return {"task_id": task_id}
```

### B. Endpoint Kiểm tra Trạng thái (`GET /api/v1/gpt-checker/task/{task_id}`)
*   **Chức năng**: Trả về trạng thái hiện tại của task.
*   **Phản hồi**:
    *   Nếu đang chạy: `{"status": "processing", ...}`
    *   Nếu hoàn tất: Cho `{"status": "done", "data": ...}` chứa kết quả phân tích chi tiết.

### C. Xử lý Nền (`background_prediction_task`)
*   **Chức năng**: Chạy mô hình AI và cập nhật kết quả.
*   **Quy trình**:
    1.  Gọi `predictor.check_full_text(text)` để phân tích.
    2.  Trừ tiền trong tài khoản người dùng (`user_db.change_token_balance`).
    3.  Lưu log vào bảng `gpt_checker_logs`.
    4.  Cập nhật `task_results[task_id]` với trạng thái `done` và kết quả JSON.

---

## 3. Cơ chế Frontend (`frontend/components/GPTCheckerView.tsx`)

### A. Gửi và Lưu Task
Khi người dùng bấm "Kiểm tra":
```typescript
const handleCheck = async () => {
  setIsLoading(true);
  // Gọi API tạo task
  const result = await api.predictGPT(textInput);
  
  // QUAN TRỌNG: Lưu Task ID và Văn bản vào LocalStorage để phục hồi khi F5
  localStorage.setItem('current_gpt_task_id', result.task_id);
  localStorage.setItem('current_gpt_task_text', textInput);
  
  // Bắt đầu polling
  pollTaskStatus(result.task_id);
};
```

### B. Polling (Hỏi vòng)
Frontend sử dụng `setInterval` để hỏi server mỗi 2 giây:
```typescript
const pollTaskStatus = (taskId: string) => {
  pollIntervalRef.current = setInterval(async () => {
    try {
      const res = await api.getGPTTaskStatus(taskId);
      
      if (res.status === 'done' || res.status === 'failed') {
        // Xóa task khỏi storage khi xong
        localStorage.removeItem('current_gpt_task_id');
        localStorage.removeItem('current_gpt_task_text');
        
        setIsLoading(false);
        if (res.status === 'done') {
           // Hiển thị kết quả...
        }
      }
    } catch (err) {
      // Xử lý lỗi 404 (Task bị mất trên server do restart)
      if (err.message.includes('404')) {
         localStorage.removeItem('current_gpt_task_id');
         // KHÔNG xóa text để người dùng có thể thử lại
         toast.error("Task không tồn tại...");
         setIsLoading(false);
      }
    }
  }, 2000);
};
```

### C. Phục hồi khi Reload (F5)
Sử dụng `useEffect` chạy 1 lần khi mount component để kiểm tra task dang dở:
```typescript
useEffect(() => {
  // Kiểm tra LocalStorage ngay khi vào trang
  const savedTaskId = localStorage.getItem('current_gpt_task_id');
  const savedText = localStorage.getItem('current_gpt_task_text');
  
  if (savedTaskId) {
     setIsLoading(true);
     // Khôi phục văn bản cũ vào ô nhập liệu
     if (savedText) setTextInput(savedText);
     // Khôi phục trạng thái đang xử lý
     setTask({ status: 'processing', timestamp: Date.now() });
     // Tiếp tục polling
     pollTaskStatus(savedTaskId);
  }
}, []);
```
