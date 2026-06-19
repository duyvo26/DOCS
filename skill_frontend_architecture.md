# Skill: Kien truc Frontend & API Setup (React/Vite/TypeScript)

## Muc tieu

Cau hinh du an Frontend tieu chuan, tap trung vao quan ly API tap trung (`api.ts`), bao mat JWT phia Frontend, quan ly trang thai nut bam, va dinh huong chia nho Components/Pages.

---

## 1. Stack Cong nghe

- Core: Vite + React (TypeScript)
- Routing: `react-router-dom` v6+
- Styling: Tailwind CSS
- Icon: `lucide-react`
- State: React Context hoac Zustand
- HTTP: `axios`

---

## 2. Quy hoach File API Tap trung

Tat ca API call qua `frontend/src/services/api.ts`:

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

Moi nut bam bat buoc co `isLoading` + `disabled` de chan double-submit:

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

## 4. Bao mat JWT Frontend

- Token xac minh khi app khoi dong qua `GET /auth/me`
- Dung `storage` event de dong bo logout giua cac tab

---

## Quy tac bat buoc

1. Moi API call qua `services/api.ts`, khong goi fetch/axios truc tiep tu component.
2. Nut bam luon co `isLoading` + `disabled`.
3. Token duoc gan tu dong qua Interceptor.
4. Loi 401 redirect `/login` tap trung.
5. Token xac minh voi server khi app load.
6. Khong hardcode URL, dung `VITE_API_URL`.
7. Protected + Admin routes guard.

---

## File lien quan

- [Chia nho Components & Domain Routing](./skill_frontend_routing_components.md)
- [Quan ly SEO Dong](./skill_dynamic_seo_manager.md)
- [Bao mat & Xac thuc](./skill_security_authentication.md)
- [Chuan API Response](./skill_api_response_standard.md)
