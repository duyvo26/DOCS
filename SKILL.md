---
name: duyvo26
description: "Bộ sưu tập 25 skill phát triển dự án AI (FastAPI + AI Engine + Frontend). Actions: setup project, init skill, load skill, use skill, deploy, chuan hoa code. Keywords: code theo chuẩn, chuẩn hoá code, standards, comment, docstring, duyvo26, DuyVo26, skill collection, skill hub, project architecture, AI project"
argument-hint: "[setup|init|help] [skill-name]"
metadata:
  author: duyvo26
  version: "1.0.0"
---

# Skill: DuyVo26 — Bộ sưu tập 22 Skill Phát triển Dự án AI

## Mô tả

Tổng hợp 25 skill phát triển dự án AI (FastAPI + AI Engine + Frontend) — bao gồm kiến trúc, coding conventions, AI RAG workflow, bảo mật, thanh toán, frontend, git, và documentation.

## Kích hoạt (Triggers)

Khi người dùng yêu cầu hoặc đề cập đến bất kỳ chủ đề nào sau đây, AI **PHẢI** load skill con tương ứng trước khi code:

### Cách sử dụng

Mỗi skill con được gọi bằng:
```
skill: <name>
```
(Ví dụ: `skill: ai-rag-workflow`)

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

#### Nhóm Xác thực, Môi trường & Bảo mật
| Stt | name | Khi nào dùng |
|-----|------|--------------|
| 7 | skill: env-configuration | .env, .gitignore, Pydantic Settings, secrets |
| 8 | skill: sql-compatibility | Raw SQL, MySQL, SQLite, parameter binding, SQL injection |
| 9 | skill: dependencies-management | Packages: FastAPI, LangGraph, JWT, zustand, zod |
| 10 | skill: security-authentication | JWT, bcrypt, RBAC, OAuth, security checklist |
| 11 | skill: google-oauth-redirect | Google OAuth login via Backend Redirect |
| 12 | skill: hybrid-app-login | Mobile app login (Flutter/React Native) via WebView + Polling |

#### Nhóm Tác vụ & Thanh toán
| Stt | name | Khi nào dùng |
|-----|------|--------------|
| 13 | skill: async-task-polling | Background Tasks + Polling cho tác vụ AI nặng |
| 14 | skill: payment-polling-sync | SePay, bank transaction auto sync, polling |

#### Nhóm Frontend
| Stt | name | Khi nào dùng |
|-----|------|--------------|
| 15 | skill: frontend-architecture | API setup, JWT Interceptor, Axios, frontend structure |
| 16 | skill: frontend-routing-components | React Router v6, domain routing, lazy loading, ProtectedRoute |
| 17 | skill: dynamic-seo-manager | Dynamic SEO, meta tags, index.html, link sharing |

#### Nhóm Code Standards & Documentation
| Stt | name | Khi nào dùng |
|-----|------|--------------|
| 18 | skill: coding-conventions | Naming, type hinting, docstring, no emoji |
| 19 | skill: git-workflow | Branch strategy, conventional commits, git commands |
| 20 | skill: execution-rules | 8 rules: Router, Service, Import, File Splitting, OOP |
| 21 | skill: readme-writing | README.md 7-section structure |
| 22 | skill: logging-monitoring | Structured logging, RotatingFileHandler, no print |
| 23 | skill: api-response-standard | ApiSuccess/ApiError, global exception handler |
| 24 | skill: codebase-mapper | Codebase analysis, map.md, header documentation |

#### Skill Nền tảng
| Stt | name | Khi nào dùng |
|-----|------|--------------|
| 25 | skill: project-structure | Cấu trúc thư mục chuẩn, sơ đồ tổng thể, hướng dẫn khởi chạy. Luôn load skill này đầu tiên trên mọi dự án mới. |

## Quy tắc

1. Khi nhận được yêu cầu thuộc bất kỳ chủ đề nào trong danh mục trên, AI **PHẢI** gọi skill con tương ứng trước.
2. Luôn load **skill: project-structure** đầu tiên khi làm việc với dự án mới.
3. Có thể load nhiều skill cùng lúc nếu yêu cầu liên quan đến nhiều chủ đề.
