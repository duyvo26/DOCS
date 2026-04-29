# Ky thuat chuyen sau: Chia nho Components, Pages & Domain Routing (React Router v6)

Tai lieu nay huong dan cach to chuc mot du an Frontend lon thanh cac **Domain nho doc lap**, moi domain co Router, Components va Pages rieng — giup de bao tri, de scale, va tranh file qua lon.

---

## 1. Tai sao phai chia nho?

| Van de khi khong chia | Giai phap khi chia dung |
|---|---|
| `App.tsx` co hang tram dong | Moi domain co `router.tsx` rieng |
| Component co hang tram dong | Chia theo nguyen tac Single Responsibility |
| Kho tim file khi debug | Cau truc theo domain, ten file ro rang |
| Kho lam viec nhom | Moi nguoi phu trach mot domain |
| Bundle JS qua lon | Lazy loading tung domain (Code Splitting) |

---

## 2. Cau truc Thu muc Chuan theo Domain

```text
frontend/
└── src/
    ├── main.tsx                   # Entry point — Chi mount App + Providers
    ├── App.tsx                    # Root: Boc Providers va gan RootRouter
    │
    ├── router/
    │   └── index.tsx              # RootRouter: Gom tat ca domain routers lai
    │
    ├── contexts/
    │   └── AuthContext.tsx        # Global Auth State (JWT, user info)
    │
    ├── services/
    │   └── api.ts                 # Axios instance + tat ca API functions
    │
    ├── hooks/
    │   └── useAsyncAction.ts      # Custom hook tai su dung
    │
    ├── components/                # Shared UI Components (dung o nhieu domain)
    │   ├── ProtectedRoute.tsx     # Guard: Chan truy cap neu chua dang nhap
    │   ├── AdminRoute.tsx         # Guard: Chan truy cap neu khong phai admin
    │   ├── LoadingSpinner.tsx     # Spinner component tai su dung
    │   └── Layout/
    │       ├── MainLayout.tsx     # Layout co Navbar + Sidebar + Footer
    │       └── AuthLayout.tsx     # Layout cho trang login (khong co Navbar)
    │
    ├── domains/                   # Moi thu muc = 1 Domain nghiep vu doc lap
    │   │
    │   ├── auth/                  # Domain: Xac thuc
    │   │   ├── router.tsx         # Routes: /login, /register, /forgot-password
    │   │   ├── pages/
    │   │   │   ├── LoginPage.tsx
    │   │   │   └── RegisterPage.tsx
    │   │   └── components/
    │   │       ├── LoginForm.tsx
    │   │       └── SocialLoginButton.tsx
    │   │
    │   ├── chat/                  # Domain: Chatbot AI
    │   │   ├── router.tsx         # Routes: /chat, /chat/:sessionId
    │   │   ├── pages/
    │   │   │   └── ChatPage.tsx
    │   │   └── components/
    │   │       ├── MessageBubble.tsx
    │   │       ├── ChatInput.tsx
    │   │       └── ChatHistory.tsx
    │   │
    │   ├── payment/               # Domain: Thanh toan
    │   │   ├── router.tsx         # Routes: /payment, /payment/success
    │   │   ├── pages/
    │   │   │   ├── PackageListPage.tsx
    │   │   │   └── PaymentSuccessPage.tsx
    │   │   └── components/
    │   │       └── PackageCard.tsx
    │   │
    │   └── admin/                 # Domain: Quan tri vien
    │       ├── router.tsx         # Routes: /admin, /admin/users, /admin/settings
    │       ├── pages/
    │       │   ├── DashboardPage.tsx
    │       │   └── UserManagementPage.tsx
    │       └── components/
    │           └── UserTable.tsx
    │
    └── types/
        └── index.ts               # Shared TypeScript types (User, ApiResponse...)
```

---

## 3. Trien khai Root Router (Gom cac Domain)

File `router/index.tsx` la noi ket noi tat ca domain routers lai. Dung `React.lazy` de **lazy-load tung domain** — browser chi tai JS cua domain khi user thuc su truy cap.

```tsx
// frontend/src/router/index.tsx
import React, { Suspense } from 'react';
import { createBrowserRouter, RouterProvider, Outlet, Navigate } from 'react-router-dom';
import MainLayout from '../components/Layout/MainLayout';
import AuthLayout from '../components/Layout/AuthLayout';
import ProtectedRoute from '../components/ProtectedRoute';
import AdminRoute from '../components/AdminRoute';
import LoadingSpinner from '../components/LoadingSpinner';

// Lazy load tung domain de toi uu bundle size.
// Moi domain chi duoc tai khi user navigate toi.
const AuthRouter = React.lazy(() => import('../domains/auth/router'));
const ChatRouter = React.lazy(() => import('../domains/chat/router'));
const PaymentRouter = React.lazy(() => import('../domains/payment/router'));
const AdminRouter = React.lazy(() => import('../domains/admin/router'));

const router = createBrowserRouter([
    // ------------------------------------------------------------------
    // NHOM 1: Auth Routes — Khong can dang nhap
    // ------------------------------------------------------------------
    {
        element: <AuthLayout><Outlet /></AuthLayout>,
        children: [
            {
                path: '/login',
                element: <Suspense fallback={<LoadingSpinner />}><AuthRouter /></Suspense>,
            },
        ],
    },

    // ------------------------------------------------------------------
    // NHOM 2: App Routes — Yeu cau dang nhap (ProtectedRoute)
    // ------------------------------------------------------------------
    {
        element: (
            <ProtectedRoute>
                <MainLayout><Outlet /></MainLayout>
            </ProtectedRoute>
        ),
        children: [
            { index: true, path: '/', element: <Navigate to="/chat" replace /> },
            {
                path: '/chat/*',
                element: <Suspense fallback={<LoadingSpinner />}><ChatRouter /></Suspense>,
            },
            {
                path: '/payment/*',
                element: <Suspense fallback={<LoadingSpinner />}><PaymentRouter /></Suspense>,
            },
        ],
    },

    // ------------------------------------------------------------------
    // NHOM 3: Admin Routes — Yeu cau quyen Admin
    // ------------------------------------------------------------------
    {
        path: '/admin/*',
        element: (
            <AdminRoute>
                <MainLayout><Outlet /></MainLayout>
            </AdminRoute>
        ),
        children: [
            {
                path: '*',
                element: <Suspense fallback={<LoadingSpinner />}><AdminRouter /></Suspense>,
            },
        ],
    },
]);

export const RootRouter = () => <RouterProvider router={router} />;
```

---

## 4. Domain Router (Vi du: Domain `chat`)

Moi domain tu quan ly cac route noi bo cua minh:

```tsx
// frontend/src/domains/chat/router.tsx
import { Routes, Route } from 'react-router-dom';
import ChatPage from './pages/ChatPage';

// Domain chat quan ly route bat dau tu /chat
const ChatRouter = () => (
    <Routes>
        <Route index element={<ChatPage />} />             {/* /chat */}
        <Route path=":sessionId" element={<ChatPage />} /> {/* /chat/abc-123 */}
    </Routes>
);

export default ChatRouter;
```

---

## 5. Protected Route Guards

### 5.1. ProtectedRoute — Chan user chua dang nhap

```tsx
// frontend/src/components/ProtectedRoute.tsx
import { Navigate, useLocation } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import LoadingSpinner from './LoadingSpinner';

interface Props { children: React.ReactNode; }

const ProtectedRoute = ({ children }: Props) => {
    const { user, isAuthLoading } = useAuth();
    const location = useLocation();

    // Dang xac minh token voi server — khong redirect voi
    if (isAuthLoading) return <LoadingSpinner fullScreen />;

    // Chua dang nhap — Redirect ve /login, luu lai URL hien tai de quay lai sau
    if (!user) {
        return <Navigate to="/login" state={{ from: location }} replace />;
    }

    return <>{children}</>;
};

export default ProtectedRoute;
```

### 5.2. AdminRoute — Chan user khong phai admin

```tsx
// frontend/src/components/AdminRoute.tsx
import { Navigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import LoadingSpinner from './LoadingSpinner';

interface Props { children: React.ReactNode; }

const AdminRoute = ({ children }: Props) => {
    const { user, isAuthLoading } = useAuth();

    if (isAuthLoading) return <LoadingSpinner fullScreen />;

    // Chua dang nhap — ve login
    if (!user) return <Navigate to="/login" replace />;

    // Da dang nhap nhung khong phai admin — ve trang chinh, khong bao loi
    if (!user.is_admin) return <Navigate to="/" replace />;

    return <>{children}</>;
};

export default AdminRoute;
```

### 5.3. Redirect ve trang cu sau khi dang nhap thanh cong

```tsx
// frontend/src/domains/auth/pages/LoginPage.tsx
import { useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../../../contexts/AuthContext';
import { authApi } from '../../../services/api';

const LoginPage = () => {
    const { login } = useAuth();
    const navigate = useNavigate();
    const location = useLocation();

    // Lay URL ma user dang co truy cap truoc khi bi chan
    const from = (location.state as { from?: Location })?.from?.pathname || '/';

    const handleLogin = async (email: string, password: string) => {
        const data = await authApi.login({ email, password });
        login(data.token, data.user);
        navigate(from, { replace: true }); // Quay ve dung trang user muon vao
    };

    // ...
};
```

---

## 6. Cach Chia nho mot Page lon thanh Components

### Nguyen tac tach Component:
1. Qua 80 dong: Can nhac tach.
2. Tai su dung o noi khac: Bat buoc tach thanh shared component.
3. Logic phuc tap rieng: Tach thanh component + custom hook.

### Vi du tach `ChatPage.tsx`:

```tsx
// [SAI] Tat ca trong mot file (tren 200 dong):
const ChatPage = () => {
    // 50 dong state va logic...
    // 80 dong render history...
    // 40 dong input form...
};

// [DUNG] Moi phan la mot component rieng:
// frontend/src/domains/chat/pages/ChatPage.tsx
import ChatHistory from '../components/ChatHistory';   // Chi hien thi lich su
import ChatInput from '../components/ChatInput';       // Chi xu ly input + gui
import ChatHeader from '../components/ChatHeader';     // Chi hien thi header

const ChatPage = () => {
    const [messages, setMessages] = useState<Message[]>([]);

    const handleNewMessage = (msg: Message) => {
        setMessages(prev => [...prev, msg]);
    };

    // ChatPage chi quan ly state tong the va phoi hop cac component con
    return (
        <div className="flex flex-col h-screen">
            <ChatHeader />
            <ChatHistory messages={messages} />
            <ChatInput onMessageSent={handleNewMessage} />
        </div>
    );
};
```

---

## 7. App.tsx — Don gian toi da

Sau khi chia dung, `App.tsx` chi con nhiem vu boc Providers:

```tsx
// frontend/src/App.tsx
import { AuthProvider } from './contexts/AuthContext';
import { RootRouter } from './router';

// App.tsx chi boc Providers — khong chua bat ky logic UI nao
const App = () => (
    <AuthProvider>
        <RootRouter />
    </AuthProvider>
);

export default App;
```

---

## 8. Checklist Chia Domain

Truoc khi tao mot domain moi, hay kiem tra:

- Tao thu muc `src/domains/<ten-domain>/`
- Tao `router.tsx` trong domain
- Tao thu muc `pages/` (cac trang day du) va `components/` (cac phan nho)
- Dang ky domain router trong `src/router/index.tsx`
- Boc route bang `ProtectedRoute` hoac `AdminRoute` neu can
- Dung `React.lazy()` + `Suspense` de lazy-load domain
- Cac API call cua domain dung ham tu `src/services/api.ts`
- State global (user, token) dung `AuthContext`, khong truyen props xuong nhieu cap
