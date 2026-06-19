# Skill: Chia nhỏ Components, Pages & Domain Routing (React Router v6)

## Mục tiêu

Tổ chức dự án Frontend lớn thành các Domain nhỏ độc lập, mỗi Domain có Router, Components và Pages riêng — dễ bảo trì, dễ scale, tránh file quá lớn.

---

## 1. Cấu trúc Thư mục Domain

```text
frontend/src/
├── router/index.tsx        # Root Router: Gom domain routers
├── components/             # Shared UI (ProtectedRoute, AdminRoute, Layout)
├── domains/
│   ├── auth/               # Domain xác thực
│   │   ├── router.tsx
│   │   ├── pages/          # LoginPage, RegisterPage
│   │   └── components/     # LoginForm, SocialLoginButton
│   ├── chat/               # Domain chatbot AI
│   │   ├── router.tsx
│   │   ├── pages/          # ChatPage
│   │   └── components/     # MessageBubble, ChatInput
│   ├── payment/            # Domain thanh toán
│   │   └── ...
│   └── admin/              # Domain quản trị
│       └── ...
```

---

## 2. Root Router — Lazy Load Domain

```tsx
const AuthRouter = React.lazy(() => import('../domains/auth/router'));
const ChatRouter = React.lazy(() => import('../domains/chat/router'));

const router = createBrowserRouter([
    { element: <AuthLayout><Outlet /></AuthLayout>,
      children: [{ path: '/login', element: <Suspense><AuthRouter /></Suspense> }] },
    { element: <ProtectedRoute><MainLayout><Outlet /></MainLayout></ProtectedRoute>,
      children: [{ path: '/chat/*', element: <Suspense><ChatRouter /></Suspense> }] },
]);
```

---

## 3. Domain Router

```typescript
// frontend/src/domains/chat/router.tsx
const ChatRouter = () => (
    <Routes>
        <Route index element={<ChatPage />} />
        <Route path=":sessionId" element={<ChatPage />} />
    </Routes>
);
```

---

## 4. Route Guards

- **ProtectedRoute**: Chặn user chưa đăng nhập
- **AdminRoute**: Chặn user không phải admin
- Redirect về trang cũ sau khi login thành công

---

## Quy tắc bắt buộc

1. Mỗi domain độc lập trong `domains/{ten}/`, có router, pages, components riêng.
2. Root Router trong `router/index.tsx`, dùng `React.lazy` + `Suspense`.
3. Dùng `ProtectedRoute` cho route cần xác thực.
4. Dùng `AdminRoute` cho route admin.
5. `App.tsx` chỉ bọc Providers, không chứa UI.
6. Quá 80 dòng trong 1 component: cân nhắc tách nhỏ.

---

## File liên quan

- [Kiến trúc Frontend & API Setup](./skill_frontend_architecture.md)
- [Quản lý SEO Động](./skill_dynamic_seo_manager.md)
- [Bảo mật & Xác thực](./skill_security_authentication.md)
- [Cấu trúc Dự án Tiêu chuẩn (Skill DuyVo26)](./skill_project_structure.md)
