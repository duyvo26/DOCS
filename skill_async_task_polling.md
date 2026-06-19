# Skill: Tac vu Bat dong bo & Polling (Standard Async Workflow)

## Muc tieu

Mo ta quy trinh chuan de xu ly cac tac vu nang (Long-running Tasks) nhu xu ly AI, ket xuat bao cao, phan tich du lieu lon. Dam bao trai nghiem nguoi dung khong bi gian doan, tranh loi timeout, cho phep khoi phuc trang thai khi F5.

---

## 1. Tong quan Kien truc

He thong su dung mo hinh **Polling** ket hop voi **Background Tasks** cua FastAPI.

**Luong xu ly:**
1. Frontend gui yeu cau -> API tao `task_id` (UUID) -> Tra ve ngay `task_id`
2. Frontend luu `task_id` vao `localStorage` -> Polling `GET /task/{id}` moi 2-3 giay
3. Backend xu ly background -> Cap nhat trang thai (`done`/`failed`)
4. Frontend nhan ket qua -> Xoa `task_id` khoi `localStorage`

---

## 2. Backend Implementation

### A. Endpoint Khoi tao Task
```python
@router.post("/run-task")
async def start_task(input_data: TaskSchema, background_tasks: BackgroundTasks):
    task_id = str(uuid.uuid4())
    task_store[task_id] = {"status": "processing", "start_time": time.time()}
    background_tasks.add_task(heavy_logic_worker, task_id, input_data)
    return {"task_id": task_id}
```

### B. Endpoint Kiem tra Trang thai
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
            // Xu ly ket qua
        }
    }, 2000);
};

// Khoi phuc khi F5
useEffect(() => {
    const savedTaskId = localStorage.getItem('active_task_id');
    if (savedTaskId) startPolling(savedTaskId);
}, []);
```

---

## Quy tac bat buoc

1. Moi task phai co `task_id` UUID duy nhat.
2. Frontend phai luu `task_id` vao `localStorage` de khoi phuc khi F5.
3. Polling interval: 2-3 giay (khong nho hon 1 giay).
4. Khi task hoan thanh, xoa `task_id` khoi `localStorage`.
5. Task het han (timeout) sau 10 phut.

---

## File lien quan

- [Cau truc Du an Tieu chuan (Skill DuyVo26)](./skill_project_structure.md)
- [Kien truc Chatbot & LLM](./skill_chatbot_architecture.md)
- [Thanh toan Polling & Sync](./skill_payment_polling_sync.md)
