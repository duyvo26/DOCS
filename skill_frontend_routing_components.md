# Skill: Chia nho Components, Pages & Domain Routing (React Router v6)

## Muc tieu

To chuc du an Frontend lon thanh cac Domain nho doc lap, moi Domain co Router, Components va Pages rieng — de bao tri, de scale, tranh file qua lon.

---

## 1. Cau truc Thu muc Domain

```text
frontend/src/
├── router/index.tsx        # Root Router: Gom domain routers
├── components/             # Shared UI (ProtectedRoute, AdminRoute, Layout)
├── domains/
│   ├── auth/               # Domain xac thuc
│   │   ├── router.tsx
│   │   ├── pages/          # LoginPage, RegisterPage
│   │   └── components/     # LoginForm, SocialLoginButton
│   ├── chat/               # Domain chatbot AI
│   │   ├── router.tsx
│   │   ├── pages/          # ChatPage
│   │   └── components/     # MessageBubble, ChatInput
│   ├── payment/            # Domain thanh toan
│   │   └── ...
│   └── admin/              # Domain quan tri
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

- **ProtectedRoute**: Chan user chua dang nhap
- **AdminRoute**: Chan user khong phai admin
- Redirect ve trang cu sau khi login thanh cong

---

## Quy tac bat buoc

1. Moi domain doc lap trong `domains/{ten}/`, co router, pages, components rieng.
2. Root Router trong `router/index.tsx`, dung `React.lazy` + `Suspense`.
3. Dung `ProtectedRoute` cho route can xac thuc.
4. Dung `AdminRoute` cho route admin.
5. `App.tsx` chi boc Providers, khong chua UI.
6. Qua 80 dong trong 1 component: can nhac tach nho.

---

## File lien quan

- [Kien truc Frontend & API Setup](./skill_frontend_architecture.md)
- [Quan ly SEO Dong](./skill_dynamic_seo_manager.md)
- [Bao mat & Xac thuc](./skill_security_authentication.md)
- [Cau truc Du an Tieu chuan (Skill DuyVo26)](./skill_project_structure.md)
