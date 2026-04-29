# Ky thuat chuyen sau: Cau truc Frontend & API Setup (React/Vite/TypeScript)

Tai lieu nay huong dan cach cau hinh du an Frontend tieu chuan, tap trung vao viec quan ly API tap trung (`api.ts`), **bao mat JWT phia Frontend**, **quan ly trang thai nut bam**, va dinh huong chia nho Components/Pages.

Xem them: De co huong dan day du ve chia nho Components, Pages va Domain Routing, doc `skill_frontend_routing_components.md`.

---

## 1. Stack Cong nghe Khuyen dung

De dam bao hieu nang va de bao tri, cac du an Frontend AI nen su dung:
- **Core**: Vite + React (TypeScript).
- **Routing**: `react-router-dom` v6+ (bat buoc khi du an co nhieu trang).
- **Styling**: Tailwind CSS (Cai dat mac dinh qua `npx tailwindcss init -p`).
- **Icon**: `lucide-react` hoac `react-icons`.
- **State Management**: React Context (cho Auth/User) hoac Zustand (cho state phuc tap hon).
- **HTTP Client**: `axios` (Khuyen dung, ho tro Interceptor tot hon `fetch` thuan).

---

## 2. Quy hoach File API Tap trung (`api.ts`)

Tuyet doi khong viet rai rac cac lenh `fetch` hay `axios` trong tung Component. Moi loi goi Backend phai duoc gom ve mot file dich vu duy nhat: `frontend/src/services/api.ts`.

### 2.1. Cau hinh Axios Instance, API Prefix va JWT Interceptor

Theo chuan he thong, Backend FastAPI luon duoc prefix bang `/api/v1`. Interceptor tu dong dinh kem JWT token vao moi request va xu ly loi 401 tap trung.

```typescript
// frontend/src/services/api.ts
import axios from 'axios';

// 1. Cau hinh URL Goc tu bien moi truong Vite
const BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:2643';

// 2. Tao Instance voi Prefix /api/v1 chuan
const apiClient = axios.create({
    baseURL: `${BASE_URL}/api/v1`,
    headers: { 'Content-Type': 'application/json' },
    timeout: 15000, // 15s cho cac tac vu AI
});

// ------------------------------------------------------------------
// REQUEST INTERCEPTOR: Dinh kem JWT Token
// ------------------------------------------------------------------
// Moi request se tu dong co header Authorization neu user da dang nhap.
// Day la diem bao mat quan trong nhat o Frontend.
apiClient.interceptors.request.use((config) => {
    const token = localStorage.getItem('access_token');
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
}, (error) => Promise.reject(error));

// ------------------------------------------------------------------
// RESPONSE INTERCEPTOR: Xu ly loi bao mat tap trung
// ------------------------------------------------------------------
apiClient.interceptors.response.use(
    (response) => response,
    (error) => {
        const status = error.response?.status;

        if (status === 401) {
            // Token sai hoac het han: Xoa token va redirect ve login.
            // Dam bao user khong bao gio o trang thai "gia dang nhap".
            console.warn('[API] Token het han hoac khong hop le. Dang logout...');
            localStorage.removeItem('access_token');
            localStorage.removeItem('user_info');
            window.location.href = '/login';
        }

        if (status === 403) {
            // User da dang nhap nhung khong co quyen (non-admin goi admin API).
            console.error('[API] Khong co quyen truy cap tai nguyen nay.');
        }

        return Promise.reject(error);
    }
);

export default apiClient;
```

### 2.2. Khai bao cac Ham Goi API (Service Functions)

Gom nhom cac API theo domain chuc nang (Auth, Chatbot, Payment...) va dinh nghia ro kieu TypeScript cho Payload.

```typescript
// frontend/src/services/api.ts (tiep theo)
import apiClient from './apiClient';

// --- AUTH API ---
export interface LoginPayload { email: string; password: string; }
export const authApi = {
    login: async (data: LoginPayload) => {
        const response = await apiClient.post('/auth/login', data);
        return response.data; // Tra ve { token, user }
    },
    getMe: async () => {
        // Goi API nay de xac minh token con hop le khi app khoi dong
        const response = await apiClient.get('/auth/me');
        return response.data;
    },
    logout: () => {
        localStorage.removeItem('access_token');
        localStorage.removeItem('user_info');
    },
};

// --- CHATBOT API ---
export const chatbotApi = {
    sendMessage: async (question: string) => {
        const response = await apiClient.post('/chat', { question });
        return response.data;
    },
};

// --- PAYMENT API ---
export const paymentApi = {
    createPayment: async (packageId: number) => {
        const response = await apiClient.post('/payment/create', { package_id: packageId });
        return response.data;
    },
};
```

---

## 3. Quan ly Trang thai Nut Bam (Button Loading State)

**Van de cot loi**: Neu khong quan ly dung, nguoi dung co the bam nut nhieu lan trong khi API dang xu ly, gay ra double submission hoac race condition. Nut PHAI bi disable trong khi dang goi API.

### 3.1. Pattern Chuan: `isLoading` State tren Nut Bam

Day la pattern bat buoc cho moi nut bam kich hoat mot tac vu async:

```tsx
// frontend/src/components/ChatInterface.tsx
import { useState } from 'react';
import { chatbotApi } from '../services/api';

const ChatInterface = () => {
    const [input, setInput] = useState('');
    const [answer, setAnswer] = useState('');
    const [isLoading, setIsLoading] = useState(false);

    const handleSend = async () => {
        // Chac chan chan double-click bang guard truoc khi bat dau
        if (!input.trim() || isLoading) return;

        setIsLoading(true); // Khoa nut truoc khi goi API
        try {
            const res = await chatbotApi.sendMessage(input);
            setAnswer(res.answer);
        } catch (error) {
            console.error('Loi goi chatbot', error);
        } finally {
            // Dung `finally` de dam bao nut LUON duoc mo khoa
            // du API tra loi thanh cong hay that bai.
            setIsLoading(false);
        }
    };

    return (
        <div className="p-4 bg-white rounded-lg shadow-md">
            <input
                className="w-full p-2 border rounded mb-2"
                value={input}
                onChange={(e) => setInput(e.target.value)}
                disabled={isLoading}
            />
            <button
                onClick={handleSend}
                disabled={isLoading}
                className={`py-2 px-4 rounded font-bold text-white transition-all
                    ${isLoading
                        ? 'bg-blue-400 cursor-not-allowed opacity-70'
                        : 'bg-blue-600 hover:bg-blue-700 cursor-pointer'
                    }`}
            >
                {isLoading ? 'Dang xu ly...' : 'Gui cau hoi'}
            </button>

            {answer && <div className="mt-4 text-gray-800">{answer}</div>}
        </div>
    );
};
```

**Giai thich thiet ke:**
- `disabled={isLoading}`: Cam bam khi dang xu ly — day la bao ve bat buoc, khong tuy chon.
- `finally { setIsLoading(false) }`: Dung `finally` chu khong phai de `setIsLoading` trong `try`. Neu de trong `try`, loi API se khien nut bi khoa mai mai vi block `catch` khong reset state.
- Guard `if (isLoading) return`: Tang bao ve thu hai phong truong hop goi ham truc tiep tu noi khac.

### 3.2. Custom Hook `useAsyncAction` — Tai su dung Pattern Loading

Khi co nhieu nut can loading state, tao mot Custom Hook de tranh lap code:

```typescript
// frontend/src/hooks/useAsyncAction.ts
import { useState, useCallback } from 'react';

/**
 * Hook giup quan ly trang thai loading cho bat ky tac vu async nao.
 * Su dung hook nay thay vi viet isLoading/setIsLoading thu cong o moi component.
 *
 * @param asyncFn - Ham async can thuc thi
 * @returns { execute, isLoading, error }
 */
export function useAsyncAction<T>(
    asyncFn: (...args: unknown[]) => Promise<T>
) {
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState<Error | null>(null);

    const execute = useCallback(async (...args: unknown[]) => {
        setIsLoading(true);
        setError(null);
        try {
            const result = await asyncFn(...args);
            return result;
        } catch (err) {
            setError(err as Error);
            throw err; // Re-throw de component co the xu ly them neu can
        } finally {
            setIsLoading(false);
        }
    }, [asyncFn]);

    return { execute, isLoading, error };
}

// Vi du su dung:
// const { execute: sendMessage, isLoading } = useAsyncAction(chatbotApi.sendMessage);
// <button onClick={() => sendMessage(input)} disabled={isLoading}>Gui</button>
```

---

## 4. Bao mat JWT Phia Frontend (Frontend Security)

API Backend da co JWT. Phia Frontend cung can co cac lop bao ve tuong ung.

### 4.1. Luu Token An toan

```typescript
// [Phu hop hau het du an]:
localStorage.setItem('access_token', token);
// Axios Interceptor se tu lay va gan vao moi request.

// [Bao mat hon cho production]:
// Yeu cau Backend tra token qua Set-Cookie (httpOnly flag).
// Browser tu luu cookie, JS khong the doc — chong tan cong XSS hoan toan.
// Frontend KHONG can goi localStorage.setItem() nua.
// Cookie se tu dong duoc gui kem moi request cung domain.

// TUYET DOI KHONG:
// window.__myToken = token; — Bien global, XSS doc duoc ngay
```

### 4.2. Xac minh Token khi App Khoi dong

Token luu trong localStorage co the da bi revoke phia server (admin ban user, doi mat khau...). Phai xac minh voi server khi app load len, khong chi kiem tra su ton tai trong localStorage:

```tsx
// frontend/src/contexts/AuthContext.tsx
import { createContext, useContext, useState, useEffect } from 'react';
import { authApi } from '../services/api';

interface AuthContextType {
    user: User | null;
    isAuthLoading: boolean;
    login: (token: string, user: User) => void;
    logout: () => void;
}

const AuthContext = createContext<AuthContextType | null>(null);

export const AuthProvider = ({ children }: { children: React.ReactNode }) => {
    const [user, setUser] = useState<User | null>(null);
    const [isAuthLoading, setIsAuthLoading] = useState(true);

    useEffect(() => {
        const verifyToken = async () => {
            const token = localStorage.getItem('access_token');
            if (!token) {
                setIsAuthLoading(false);
                return;
            }
            try {
                // Goi API de server xac minh token con hop le
                const userData = await authApi.getMe();
                setUser(userData);
            } catch {
                // Token loi hoac het han — Interceptor da xu ly redirect
                setUser(null);
            } finally {
                setIsAuthLoading(false);
            }
        };
        verifyToken();
    }, []);

    const login = (token: string, userData: User) => {
        localStorage.setItem('access_token', token);
        setUser(userData);
    };

    const logout = () => {
        authApi.logout();
        setUser(null);
    };

    return (
        <AuthContext.Provider value={{ user, isAuthLoading, login, logout }}>
            {children}
        </AuthContext.Provider>
    );
};

export const useAuth = () => {
    const ctx = useContext(AuthContext);
    if (!ctx) throw new Error('useAuth phai duoc dung ben trong AuthProvider');
    return ctx;
};
```

---

## 6. Thong bao Loi cho Nguoi dung (User-Facing Error Feedback)

`console.error` chi de developer xem, nguoi dung khong bao gio thay. Moi loi API phai duoc hien thi thanh thong bao ro rang cho nguoi dung.

### 6.1. Pattern Toast Notification co ban (khong can thu vien)

```tsx
// frontend/src/hooks/useToast.ts
import { useState, useCallback } from 'react';

type ToastType = 'success' | 'error' | 'warning';

interface Toast {
    id: number;
    message: string;
    type: ToastType;
}

export function useToast() {
    const [toasts, setToasts] = useState<Toast[]>([]);

    const showToast = useCallback((message: string, type: ToastType = 'error') => {
        const id = Date.now();
        setToasts(prev => [...prev, { id, message, type }]);
        // Tu dong xoa sau 4 giay
        setTimeout(() => {
            setToasts(prev => prev.filter(t => t.id !== id));
        }, 4000);
    }, []);

    return { toasts, showToast };
}
```

### 6.2. Lay thong bao loi tu API Response

Ket hop voi chuan `ApiError` (xem `skill_api_response_standard.md`), lay message tu response:

```tsx
// frontend/src/components/ChatInterface.tsx
const { showToast } = useToast();

const handleSend = async () => {
    if (!input.trim() || isLoading) return;
    setIsLoading(true);
    try {
        const res = await chatbotApi.sendMessage(input);
        setAnswer(res.data.answer);
        // Khong can showToast khi thanh cong — UI da phan anh ket qua
    } catch (error: unknown) {
        // Lay message tu ApiError standard, fallback ve thong bao chung
        const message =
            (error as { response?: { data?: { message?: string } } })
            ?.response?.data?.message
            ?? 'Co loi xay ra. Vui long thu lai.';
        showToast(message, 'error');
    } finally {
        setIsLoading(false);
    }
};
```

### 6.3. Quy tac hien thi loi cho nguoi dung

| Truong hop | Hien thi cho nguoi dung | Luu log |
|---|---|---|
| Loi 401 (het token) | Khong can toast — Interceptor tu redirect `/login` | Khong can |
| Loi 400 (validation) | Toast voi `error.response.data.message` | Khong can |
| Loi 403 (khong quyen) | Toast: "Ban khong co quyen thuc hien hanh dong nay" | Khong can |
| Loi 404 | Toast: "Khong tim thay du lieu" | Khong can |
| Loi 500 (server error) | Toast: "Loi he thong. Vui long thu lai sau." | Co (console.error) |
| Loi mang (network) | Toast: "Mat ket noi. Kiem tra lai mang cua ban." | Co (console.error) |

---

## 7. Tom tat Tieu chuan Frontend

| # | Tieu chuan | Ly do |
|---|------------|-------|
| 1 | Bien moi truong bat dau bang `VITE_` | Vite chi expose bien co prefix nay ra browser |
| 2 | API Endpoint co versioning `/api/v1/` | Nang cap backend khong lam hong frontend cu |
| 3 | Nut bam luon co `isLoading` + `disabled` | Ngan double-submission va race condition |
| 4 | Moi API call qua file `services/api.ts` | De debug, bao tri, va thay doi Base URL |
| 5 | JWT duoc gan tu dong qua Interceptor | Khong can nho gan header thu cong |
| 6 | Loi 401 redirect ve `/login` tap trung | User khong bao gio o trang thai gia dang nhap |
| 7 | Token xac minh khi app khoi dong qua `/auth/me` | Dam bao token server-side van con hieu luc |
| 8 | Loi API hien thi toast cho nguoi dung | `console.error` chi developer thay, user khong biet gi |
| 9 | Protected Routes dung HOC/Wrapper | Xem `skill_frontend_routing_components.md` |

