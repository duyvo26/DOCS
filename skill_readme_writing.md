# Huong dan Viet README.md Chuan (README Writing Guide)

Tai lieu nay quy dinh cach viet file `README.md` chuan cho moi du an. File README la cua ngo dau tien de Developer, AI Agent va doi tac hieu du an — viet khong day du dan den mat thoi gian debug, thieu thong tin trien khai, hoac kem bao mat.

---

## 1. Cau truc README Bat buoc (Mandatory Structure)

Moi du an BAT BUOC phai co file `README.md` tai thu muc goc voi cau truc sau day:

```
README.md
├── 1. Tong quan du an (Project Overview)
├── 2. Yeu cau he thong (System Requirements)
├── 3. Cai dat & Chay thu cuc bo (Local Setup)
├── 4. Cau hinh bien moi truong (Environment Variables)
├── 5. Cau truc thu muc (Project Structure)
├── 6. Danh sach API Endpoint (API Reference)
└── 7. Huong dan Trien khai (Deployment)
```

---

## 2. Mau README day du (Full Template)

```markdown
# Ten Du An

Mo ta ngan gon mot dong ve muc dich du an.

## Tong quan (Overview)

Mo ta ro rang cac chuc nang chinh, ai dung, van de du an giai quyet.
Viet o dang van xuoi, khong phai bullet list.

---

## Yeu cau He thong (System Requirements)

- Python >= 3.10
- Node.js >= 18.x
- SQLite (hoac PostgreSQL >= 14)
- RAM toi thieu 4GB (AI model chay tot hon voi 8GB)

---

## Cai dat & Chay thu cuc bo (Local Setup)

### 1. Clone va tao moi truong ao (Backend)

git clone https://github.com/your-org/your-repo.git
cd your-repo

python -m venv .venv
.venv\Scripts\activate          # Windows
# source .venv/bin/activate     # Linux / macOS

pip install -r requirements.txt

### 2. Cau hinh bien moi truong

cp .env.example .env
# Mo file .env va dien cac gia tri thuc

### 3. Khoi dong Backend

uvicorn app.main:app --reload --port 2643

### 4. Cai dat & Chay Frontend

cd frontend
npm install
npm run dev

App Frontend se chay tai: http://localhost:5173
API Backend chay tai: http://localhost:2643

---

## Cau hinh Bien Moi truong (Environment Variables)

Tao file `.env` tu mau `.env.example`. Cac bien bat buoc:

| Bien               | Mo ta                                  | Vi du                       |
|--------------------|----------------------------------------|-----------------------------|
| SECRET_KEY         | Khoa bi mat ky JWT (toi thieu 32 ky tu)| changeme-use-strong-secret  |
| GEMINI_API_KEY     | API Key cua Google Gemini              | AIzaSy...                   |
| DATABASE_URL       | Duong dan den SQLite hoac PostgreSQL   | sqlite:///./data.db         |
| VITE_API_URL       | URL Backend de Frontend goi API       | http://localhost:2643       |
| ALLOWED_ORIGINS    | Danh sach domain duoc phep CORS        | http://localhost:5173       |

**Luu y bao mat:**
- File `.env` KHONG DUOC commit len Git (kiem tra `.gitignore`).
- File `.env.example` chi chua ten bien va mo ta, KHONG chua gia tri thuc.

---

## Cau truc Thu muc (Project Structure)

project_root/
├── app/                    # Backend Core (FastAPI)
│   ├── main.py             # Entry point, CORS, Middleware
│   ├── config.py           # Load bien moi truong
│   ├── models/             # Database schemas & queries
│   ├── routers/            # API endpoints (auth, chat, payment)
│   └── security/           # JWT, password hashing
├── chatbot/                # AI Engine (LangGraph workflows)
├── frontend/               # Frontend (Vite + React + TypeScript)
│   └── src/
│       ├── domains/        # Domain-based component structure
│       ├── services/       # api.ts - Axios instance
│       └── contexts/       # AuthContext, global state
├── utils/                  # Storage (uploads, downloads, vectors)
├── .env                    # Bien moi truong (KHONG commit)
├── .env.example            # Mau bien moi truong (commit duoc)
└── requirements.txt        # Python dependencies

---

## Danh sach API Endpoint (API Reference)

Tat ca endpoint deu co prefix `/api/v1`.
Backend chay tai `http://localhost:2643`.

### Xac thuc (Auth)

| Method | Endpoint              | Xac thuc | Mo ta                          |
|--------|-----------------------|----------|--------------------------------|
| POST   | /api/v1/auth/login    | Khong    | Dang nhap, nhan JWT token      |
| GET    | /api/v1/auth/me       | Bearer   | Lay thong tin user hien tai    |

### Chatbot

| Method | Endpoint              | Xac thuc | Mo ta                          |
|--------|-----------------------|----------|--------------------------------|
| POST   | /api/v1/chat          | Bearer   | Gui cau hoi, nhan tra loi AI   |

### Thanh toan (Payment)

| Method | Endpoint                    | Xac thuc | Mo ta                     |
|--------|-----------------------------|----------|---------------------------|
| POST   | /api/v1/payment/create      | Bearer   | Tao giao dich thanh toan  |
| GET    | /api/v1/payment/status/{id} | Bearer   | Kiem tra trang thai GD    |

---

## Huong dan Trien khai (Deployment)

### Tren Linux/Proxmox (Khong Docker)

1. Cai dat he thong:
   apt update && apt install python3-pip nodejs npm

2. Cai thu vien:
   pip install -r requirements.txt
   cd frontend && npm install && npm run build

3. Cai dat systemd service (Backend):
   Xem file `deploy/app.service` de tham khao.

4. Cai dat Nginx reverse proxy:
   Xem file `deploy/nginx.conf` de tham khao.

---

## Lien he & Tai lieu Ky thuat

- Tai lieu Skill: `c:/AI_CODE/DOCS/`
- Bao loi: Tao Issue tren GitHub repository.
```

---

## 3. Quy tac viet README

### Quy tac bat buoc:

1. **Viet bang tieng Viet thuan** (hoac thuan Anh) — khong tron lan hai thu tieng mot cach tuy tien.
2. **Khong dung emoji** trong file README (xem quy tac no-emoji tai `skill_coding_conventions.md`).
3. **Code block phai co nhan ngon ngu** (` ```bash `, ` ```python `, ` ```typescript `).
4. **Bang bien moi truong phai day du**: Moi bien mot hang, co mo ta va vi du.
5. **Buoc cai dat phai co the chay ngay** — nguoi doc copy-paste vao terminal la chay duoc.
6. **Cap nhat README moi khi thay doi cau truc du an** hoac them bien moi truong moi.

### Quy tac cua file `.env.example`:

```bash
# .env.example — File nay DUOC commit len Git
# Huong dan: Sao chep file nay thanh .env roi dien gia tri thuc

# Bao mat
SECRET_KEY=your-secret-key-here-minimum-32-chars
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=60

# AI
GEMINI_API_KEY=your-google-gemini-api-key
GEMINI_MODEL=gemini-2.0-flash

# Database
DATABASE_URL=sqlite:///./utils/data.db

# Frontend
VITE_API_URL=http://localhost:2643
ALLOWED_ORIGINS=http://localhost:5173
```

**Quy tac `.env.example`:**
- Co comment giai thich tung bien.
- Gia tri la placeholder mo ta (`your-...`), KHONG phai gia tri thuc.
- Nhom cac bien theo chuc nang bang comment phan cach.

---

## 4. Danh sach kiem tra truoc khi commit README

- [ ] Co day du 7 phan chinh (xem muc 1)
- [ ] Buoc cai dat da duoc test chay thu tren may sach
- [ ] Bang bien moi truong dong bo voi file `.env.example`
- [ ] Cau truc thu muc khop voi thu muc thuc te cua du an
- [ ] Khong co emoji
- [ ] Code block co nhan ngon ngu
- [ ] Duong dan file trong README la duong dan tuong doi (khong hardcode may ca nhan)
