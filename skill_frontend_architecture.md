# Kỹ thuật chuyên sâu: Cấu trúc Frontend & API Setup (React/Tailwind)

Tài liệu này hướng dẫn cách cấu hình dự án Frontend tiêu chuẩn, tập trung vào việc quản lý API tập trung (`api.ts`) và định hướng sử dụng framework UI.

---

## 1. Stack Công nghệ Khuyên dùng

Để đảm bảo hiệu năng và dễ bảo trì, các dự án Frontend AI nên sử dụng:
- **Core**: Vite + React (TypeScript).
- **Styling**: Tailwind CSS (Cài đặt mặc định qua `npx tailwindcss init -p`). Cực kỳ phù hợp để xây dựng giao diện hiện đại, responsive nhanh mà không cần viết CSS thuần.
- **Icon**: `lucide-react` hoặc `react-icons`.
- **State Management**: React Context (cho các state đơn giản như User/Auth) hoặc Zustand.
- **HTTP Client**: `axios` (Khuyên dùng) hoặc `fetch` API nguyên bản.

---

## 2. Quy hoạch File API Tập trung (`api.ts`)

Tuyệt đối không viết rải rác các lệnh `fetch` hay `axios` trong từng Component. Mọi lời gọi Backend phải được gom về một file dịch vụ duy nhất: `frontend/api.ts` (hoặc `frontend/services/api.ts`).

### 2.1. Cấu hình Axios Instance và API Prefix
Theo chuẩn hệ thống, Backend FastAPI luôn được prefix bằng `/api/v1`. Chúng ta sẽ thiết lập điều này ngay từ đầu.

```typescript
// frontend/api.ts
import axios from 'axios';

// 1. Cấu hình URL Gốc từ biến môi trường
// Nếu không có, fallback về localhost
const BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:2643';

// 2. Tạo Instance với Prefix /api/v1 chuẩn
const apiClient = axios.create({
    baseURL: `${BASE_URL}/api/v1`,
    headers: {
        'Content-Type': 'application/json',
    },
    timeout: 10000, // Timeout 10s tránh treo app
});

// 3. Interceptor: Tự động đính kèm Token vào mọi Request
apiClient.interceptors.request.use((config) => {
    const token = localStorage.getItem('access_token');
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
});

// 4. Interceptor: Bắt lỗi tập trung (ví dụ: hết hạn token)
apiClient.interceptors.response.use(
    (response) => response,
    (error) => {
        if (error.response?.status === 401) {
            // Tự động logout nếu token sai/hết hạn
            localStorage.removeItem('access_token');
            window.location.href = '/login';
        }
        return Promise.reject(error);
    }
);
```

### 2.2. Khai báo các Hàm Gọi API (Service Functions)
Gom nhóm các API theo chức năng (Auth, Chatbot, Payment...) và định nghĩa rõ Type cho tham số (Payload).

```typescript
// frontend/api.ts (tiếp theo)

// --- AUTH API ---
export const authApi = {
    login: async (data: LoginPayload) => {
        const response = await apiClient.post('/auth/login', data);
        return response.data;
    },
    checkAuth: async () => {
        const response = await apiClient.get('/auth/check');
        return response.data; // Trả về thông tin user
    }
};

// --- CHATBOT API ---
export const chatbotApi = {
    sendMessage: async (question: string) => {
        const response = await apiClient.post('/chat', { question });
        return response.data; 
    }
};

// --- PAYMENT API ---
export const paymentApi = {
    createPayment: async (packageId: number) => {
        const response = await apiClient.post('/payment/create', { package_id: packageId });
        return response.data;
    }
};
```

---

## 3. Cách sử dụng trong Component

Với cấu trúc trên, việc gọi API trong Component (như `App.tsx` hoặc `ChatView.tsx`) trở nên cực kỳ ngắn gọn và dễ đọc:

```tsx
import { useState } from 'react';
import { chatbotApi } from './api';

const ChatInterface = () => {
    const [input, setInput] = useState('');
    const [answer, setAnswer] = useState('');

    const handleSend = async () => {
        try {
            // Rất ngắn gọn, không cần lo Header hay Base URL
            const res = await chatbotApi.sendMessage(input);
            setAnswer(res.answer);
        } catch (error) {
            console.error("Lỗi gọi chatbot", error);
            // Có thể dùng toast.error("Có lỗi xảy ra!") ở đây
        }
    };

    return (
        <div className="p-4 bg-white rounded-lg shadow-md border border-gray-200"> {/* Dùng Tailwind */}
            <input 
                className="w-full p-2 border rounded mb-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                value={input} 
                onChange={(e) => setInput(e.target.value)} 
            />
            <button 
                className="bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
                onClick={handleSend}
            >
                Gửi câu hỏi
            </button>
            <div className="mt-4 text-gray-800">
                {answer}
            </div>
        </div>
    );
};
```

## 4. Tóm tắt Tiêu chuẩn Frontend
1. **Biến môi trường**: Luôn bắt đầu bằng `VITE_` (ví dụ: `VITE_API_URL`) khi dùng Vite.
2. **API Endpoint**: Mọi URL đều nên có versioning (ví dụ: `/api/v1/`) để dễ dàng nâng cấp server mà không làm hỏng app cũ.
3. **Tailwind CSS**: Khuyến khích sử dụng Tailwind để viết CSS trực tiếp vào `className`, giúp code đồng nhất, dễ scale và không cần lo đặt tên class (BEM).
