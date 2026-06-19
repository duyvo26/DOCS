# Skill: Kiến trúc Frontend & API Setup (React/Vite/TypeScript)

## Mục tiêu

Cấu hình dự án Frontend tiêu chuẩn, tập trung vào quản lý API tập trung (`api.ts`), bảo mật JWT phía Frontend, quản lý trạng thái nút bấm, và định hướng chia nhỏ Components/Pages.

---

## 1. Stack Công nghệ

- Core: Vite + React (TypeScript)
- Routing: `react-router-dom` v6+
- Styling: Tailwind CSS
- Icon: `lucide-react`
- State: React Context hoặc Zustand
- HTTP: `axios`

---

## 2. Quy hoạch File API Tập trung

Tất cả API call qua `frontend/src/services/api.ts`:

```typescript
const apiClient = axios.create({
    baseURL: `${BASE_URL}/api/v1`,
    headers: { 'Content-Type': 'application/json' },
});

// Request Interceptor: Gan JWT tu dong
apiClient.interceptors.request.use((config) => {
    const token = localStorage.getItem('access_token');
    if (token) config.headers.Authorization = `Bearer ${token}`;
    return config;
});

// Response Interceptor: Xu ly loi 401 tap trung
apiClient.interceptors.response.use(
    (res) => res,
    (error) => {
        if (error.response?.status === 401) {
            localStorage.removeItem('access_token');
            window.location.href = '/login';
        }
        return Promise.reject(error);
    }
);
```

---

## 3. Button Loading State

Mọi nút bấm bắt buộc có `isLoading` + `disabled` để chặn double-submit:

```typescript
const [isLoading, setIsLoading] = useState(false);

const handleSend = async () => {
    if (!input.trim() || isLoading) return;
    setIsLoading(true);
    try { /* API call */ }
    finally { setIsLoading(false); }
};
```

---

## 4. Bảo mật JWT Frontend

- Token xác minh khi app khởi động qua `GET /auth/me`
- Dùng `storage` event để đồng bộ logout giữa các tab

---

## Quy tắc bắt buộc

1. Mọi API call qua `services/api.ts`, không gọi fetch/axios trực tiếp từ component.
2. Nút bấm luôn có `isLoading` + `disabled`.
3. Token được gán tự động qua Interceptor.
4. Lỗi 401 redirect `/login` tập trung.
5. Token xác minh với server khi app load.
6. Không hardcode URL, dùng `VITE_API_URL`.
7. Protected + Admin routes guard.

---

## File liên quan

- [Chia nhỏ Components & Domain Routing](./skill_frontend_routing_components.md)
- [Quản lý SEO Động](./skill_dynamic_seo_manager.md)
- [Bảo mật & Xác thực](./skill_security_authentication.md)
- [Chuẩn API Response](./skill_api_response_standard.md)
