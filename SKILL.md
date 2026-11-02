---
name: duyvo26
description: "Bộ sưu tập 31 skill cốt lõi & Hệ sinh thái 500+ AI Skills toàn diện (FastAPI + AI Engine + Frontend + Kiosk + Server Hardening + Nginx WAF + aaPanel + Impeccable + TasteSkill). Actions: setup project, init skill, load skill, use skill, deploy, chuan hoa code, install all skills. Keywords: code theo chuẩn, chuẩn hoá code, standards, comment, docstring, duyvo26, DuyVo26, skill collection, skill hub, project architecture, AI project, kiosk, wifi, server security, hardening, nginx waf, reverse proxy, aapanel, impeccable, tasteskill, install_all_skills"
argument-hint: "[setup|init|help|install-all] [skill-name]"
metadata:
  author: duyvo26
  version: "1.5.0"
---

# Skill: DuyVo26 — Bộ sưu tập 31 Skill Cốt Lõi & Hệ Sinh Thái 500+ AI Skills

## Mô tả

Tổng hợp 31 skill cốt lõi phát triển dự án AI, hệ thống Kiosk, Tường lửa Nginx WAF, aaPanel Management và Bảo mật Máy chủ Production (FastAPI + AI Engine + Frontend + Kiosk System + Server Hardening + Nginx Proxy Manager WAF + aaPanel) cùng hệ sinh thái 500+ AI Skills toàn diện (Impeccable, TasteSkill Anti-Slop, PPT Master, Graphify, Cloud, DevOps, Web3, Trading, v.v.).

Hỗ trợ tự động thiết lập và cài đặt trọn bộ sang bất kỳ máy tính mới nào qua 1 dòng lệnh duy nhất.

## Kích hoạt (Triggers)

Khi người dùng yêu cầu hoặc đề cập đến bất kỳ chủ đề nào sau đây, AI **PHẢI** load skill con tương ứng trước khi code:

### Cách sử dụng

Mỗi skill con được gọi bằng:
```
skill: <name>
```
(Ví dụ: `skill: ai-rag-workflow`, `skill: server-security-hardening`)

### Danh mục Skill

#### Nhóm AI & RAG
| Stt | name | Khi nào dùng |
|-----|------|--------------|
| 1 | skill: ai-rag-workflow | RAG workflow, LangGraph, retrieval, grading document, token management |
| 2 | skill: chatbot-architecture | LLM init, prompt management, agent, chatbot module structure |
| 3 | skill: openrouter-integration | OpenRouter, multi-model AI (GPT, Claude, Gemini, Llama) |
| 4 | skill: 9router-integration | 9Router LLM Gateway, combo model, stream SSE, fallback 3 tầng |
| 5 | skill: zalo-bot | Zalo Bot config & ops: webhook, Zalo ID, RBAC, chat history |
| 6 | skill: docx-to-md-parser | DOCX → Markdown, heading extraction, document ingestion |

#### Nhóm Xác thực, Môi trường & Bảo mật Máy chủ
| Stt | name | Khi nào dùng |
|-----|------|--------------|
| 7 | skill: env-configuration | .env, .gitignore, Pydantic Settings, secrets |
| 8 | skill: sql-compatibility | Raw SQL, MySQL, SQLite, parameter binding, SQL injection |
| 9 | skill: dependencies-management | Packages: FastAPI, LangGraph, JWT, zustand, zod |
| 10 | skill: security-authentication | JWT, bcrypt, RBAC, OAuth, security checklist |
| 11 | skill: server-security-hardening | Củng cố an ninh máy chủ, Nginx chặn .db/.env, UFW, Fail2ban, JWT secret rotation, PHP hardening |
| 12 | skill: google-oauth-redirect | Google OAuth login via Backend Redirect |
| 13 | skill: hybrid-app-login | Mobile app login (Flutter/React Native) via WebView + Polling |

#### Nhóm Tác vụ & Thanh toán
| Stt | name | Khi nào dùng |
|-----|------|--------------|
| 14 | skill: async-task-polling | Background Tasks + Polling cho tác vụ AI nặng |
| 15 | skill: payment-polling-sync | SePay, bank transaction auto sync, polling |

#### Nhóm Frontend
| Stt | name | Khi nào dùng |
|-----|------|--------------|
| 16 | skill: frontend-architecture | API setup, JWT Interceptor, Axios, frontend structure |
| 17 | skill: frontend-routing-components | React Router v6, domain routing, lazy loading, ProtectedRoute |
| 18 | skill: dynamic-seo-manager | Dynamic SEO, meta tags, index.html, link sharing |

#### Nhóm Code Standards & Documentation
| Stt | name | Khi nào dùng |
|-----|------|--------------|
| 19 | skill: coding-conventions | Naming, type hinting, docstring, no emoji |
| 20 | skill: git-workflow | Branch strategy, conventional commits, git commands |
| 21 | skill: execution-rules | 11 rules: Router, Service, File Splitting, UI Contrast, Unified Auth, Cache Busting |
| 22 | skill: readme-writing | README.md 7-section structure |
| 23 | skill: logging-monitoring | Structured logging, RotatingFileHandler, no print |
| 24 | skill: api-response-standard | ApiSuccess/ApiError, global exception handler |
| 25 | skill: codebase-mapper | Codebase analysis, map.md, header documentation |

#### Nhóm Hạ tầng, Mạng & Bảo mật Máy chủ (Infrastructure & Server Security)
| Stt | name | Khi nào dùng |
|-----|------|--------------|
| 26 | skill: server-security-hardening | Củng cố & kiểm tra bảo mật VPS/Production, UFW, Fail2ban, chống lộ .env, app.db, secret rotation |
| 27 | skill: nginx-waf-reverse-proxy | Quản trị Nginx Reverse Proxy, Tường lửa WAF, SOC Live World Map, Stream Proxy IP Grouping, Giám sát phần cứng Proxmox LXC & Docker |
| 28 | skill: aapanel-management | Quản trị aaPanel / Baota Panel, triển khai Python/Node/Go/Java, di chuyển Supervisor sang Python Project, sửa lỗi 502, fix bug core aaPanel |

#### Nhóm Kiosk & Hệ thống Thiết bị (Hardware & Kiosk System)
| Stt | name | Khi nào dùng |
|-----|------|--------------|
| 29 | skill: kiosk-system | Kiosk chuyên dụng, Wayland, Chromium Kiosk, Auto-login, Virtual Keyboard, Watchdog |
| 30 | skill: wifi-management | Quản lý kết nối Wi-Fi qua NetworkManager (nmcli), scan, status, connect, disconnect, touch UI |

#### Skill Nền tảng
| Stt | name | Khi nào dùng |
|-----|------|--------------|
| 31 | skill: project-structure | Cấu trúc thư mục chuẩn, sơ đồ tổng thể, hướng dẫn khởi chạy. Luôn load skill này đầu tiên trên mọi dự án mới. |

## Hệ sinh thái Kỹ năng Toàn Diện (500+ Skills) & Cài đặt Máy Mới

Bên cạnh 31 skill cốt lõi của DuyVo26, máy trạm hiện đang vận hành đầy đủ hệ sinh thái **503+ Unique Skills**:
- **aaPanel / Baota Suite (8 skills)**: Quản trị và triển khai ứng dụng server aaPanel.
- **Frontend Design & Anti-Slop (2 skills)**: `impeccable` (v4.8.0) và `taste-skill` (v2 - Awwwards Art Direction).
- **Thuyết trình Slide AI (1 skill)**: `ppt-master`.
- **Đồ thị Codebase (1 skill)**: `graphify` (v0.9.97).
- **Thư viện Kỹ năng Mở rộng (460+ skills)**: AWS, GCP, Docker, K8s, Web3, DeFi, Quant, Game Dev, Robotics.

👉 Chi tiết toàn bộ danh mục được lưu tại: [`FULL_SKILLS_MANIFEST.md`](FULL_SKILLS_MANIFEST.md)

### 🚀 Lệnh Cài Đặt 1 Chạm Cho Máy Mới (1-Line Installer)
Để nhân bản và cài đủ 100% bộ skill này sang máy tính khác (macOS / Linux):
```bash
curl -fsSL https://raw.githubusercontent.com/duyvo26/DOCS/main/install_all_skills.sh | bash
```

## Quy tắc

1. Khi nhận được yêu cầu thuộc bất kỳ chủ đề nào trong danh mục trên, AI **PHẢI** gọi skill con tương ứng trước.
2. Luôn load **skill: project-structure** đầu tiên khi làm việc với dự án mới.
3. Có thể load nhiều skill cùng lúc nếu yêu cầu liên quan đến nhiều chủ đề.
