# Skill: DuyVo26 — Bộ sưu tập 22 Skill Phát triển Dự án AI

## Mô tả

Tổng hợp 22 skill phát triển dự án AI (FastAPI + AI Engine + Frontend) — bao gồm kiến trúc, coding conventions, AI RAG workflow, bảo mật, thanh toán, frontend, git, và documentation.

## Kích hoạt (Triggers)

Khi người dùng yêu cầu hoặc đề cập đến bất kỳ chủ đề nào sau đây, AI **PHẢI** load skill con tương ứng trước khi code:

### Cách sử dụng

Mỗi skill con được gọi bằng:
```
skill: Tên Skill
```

### Danh mục Skill

#### Nhóm AI & RAG
| Stt | Tên Skill | Khi nào dùng |
|-----|-----------|--------------|
| 1 | skill: AI RAG Workflow — LangGraph & Retrieval-Augmented Generation | Khi cần luồng RAG, LangGraph, retrieval, grading document, quản lý token |
| 2 | skill: Kiến trúc Chatbot & LLM (Chatbot Architecture Skill) | Khi cần khởi tạo LLM, quản lý Prompt, xây dựng Agent, cấu trúc chatbot/ |
| 3 | skill: Kết nối OpenRouter (Đa nền tảng AI) | Khi cần tích hợp OpenRouter, đa model AI (GPT, Claude, Gemini, Llama) |
| 4 | skill: Parser DOCX to MD — Chuyển đổi báo cáo sang Markdown có cấu trúc | Khi cần chuyển đổi DOCX sang Markdown có headings để nạp vào AI |

#### Nhóm Xác thực, Môi trường & Bảo mật
| Stt | Tên Skill | Khi nào dùng |
|-----|-----------|--------------|
| 5 | skill: Cấu hình Môi trường (.env & .gitignore) | Khi cần .env, .gitignore, Pydantic Settings, bảo mật secret |
| 6 | skill: Viết Mã SQL Đa nền tảng (SQLite & MySQL) | Khi cần raw SQL tương thích đa driver, parameter binding |
| 7 | skill: Quản lý Thư viện (Dependencies Management) | Khi cần danh sách package (FastAPI, LangGraph, JWT, zustand, zod...) |
| 8 | skill: Bảo mật & Xác thực Toàn diện (Security & Authentication) | Khi cần JWT, bcrypt, RBAC, OAuth, bảo mật frontend |
| 9 | skill: Đăng nhập Google OAuth (Redirect Flow) | Khi cần đăng nhập Google qua Backend Redirect |
| 10 | skill: Đăng nhập Hybrid App (Cloud-Sync Polling) | Khi cần đăng nhập cho App Mobile (Flutter/React Native) |

#### Nhóm Tác vụ & Thanh toán
| Stt | Tên Skill | Khi nào dùng |
|-----|-----------|--------------|
| 11 | skill: Tác vụ Bất đồng bộ & Polling (Standard Async Workflow) | Khi cần Background Tasks + Polling cho tác vụ AI nặng |
| 12 | skill: Hệ thống Thanh toán Tự động (Polling & Sync) | Khi cần đối soát giao dịch ngân hàng qua SePay |

#### Nhóm Frontend
| Stt | Tên Skill | Khi nào dùng |
|-----|-----------|--------------|
| 13 | skill: Kiến trúc Frontend & API Setup (React/Vite/TypeScript) | Khi cần setup API tập trung, JWT Interceptor, cấu trúc frontend/ |
| 14 | skill: Chia nhỏ Components, Pages & Domain Routing (React Router v6) | Khi cần domain-based routing, lazy loading, ProtectedRoute |
| 15 | skill: Quản lý SEO Động (Dynamic SEO Manager) | Khi cần SEO động, thay thẻ meta trong index.html |

#### Nhóm Code Standards & Documentation
| Stt | Tên Skill | Khi nào dùng |
|-----|-----------|--------------|
| 16 | skill: Tiêu chuẩn Viết Code & Đặt tên (Coding Conventions) | Khi cần quy tắc đặt tên, type hinting, docstring, cấm emoji |
| 17 | skill: Git Workflow & Commit Convention | Khi cần branch strategy, conventional commits, git commands |
| 18 | skill: Quy tắc Thực thi Bắt buộc (Execution Rules) | Khi cần 8 quy tắc cứng về Router, Service, Import, File Splitting, OOP |
| 19 | skill: Viết README.md Chuẩn (README Writing Guide) | Khi cần viết README.md theo chuẩn 7 phần |
| 20 | skill: Logging & Monitoring Chuẩn (Structured Logging) | Khi cần Python logging, RotatingFileHandler, log level rules |
| 21 | skill: Chuẩn API Response (Standard API Response Format) | Khi cần ApiSuccess/ApiError format, global exception handler |
| 22 | skill: Codebase Mapper — Phân tích Codebase và Tạo map.md | Khi cần phân tích codebase, tạo map.md, header documentation |

#### Skill Nền tảng
| Stt | Tên Skill | Khi nào dùng |
|-----|-----------|--------------|
| 23 | skill: DuyVo26 — Cấu trúc Dự án Tiêu chuẩn & Hướng dẫn Phát triển | Khi cần cấu trúc thư mục chuẩn, sơ đồ tổng thể, hướng dẫn khởi chạy. Luôn load skill này đầu tiên trên mọi dự án mới. |

## Quy tắc

1. Khi nhận được yêu cầu thuộc bất kỳ chủ đề nào trong danh mục trên, AI **PHẢI** gọi skill con tương ứng trước.
2. Luôn load **skill: DuyVo26 — Cấu trúc Dự án Tiêu chuẩn & Hướng dẫn Phát triển** đầu tiên khi làm việc với dự án mới.
3. Có thể load nhiều skill cùng lúc nếu yêu cầu liên quan đến nhiều chủ đề.
