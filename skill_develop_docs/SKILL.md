---
name: develop-docs
description: "Develop Docs — Hệ thống Tài liệu Phát triển Chuẩn cho mọi dự án. Actions: setup, configure, implement, review, fix, optimize. Keywords: develop docs, developer documentation, project documentation, tài liệu dự án, AGENTS.md, PROJECT_STATUS.md, TASKS.md, ROADMAP.md, CHANGELOG.md, KNOWN_ISSUES.md, docs/ARCHITECTURE.md, TECHNICAL_SPECIFICATION.md, DATABASE.md, API_DOCUMENTATION.md, DEVELOPMENT_GUIDE.md, DEPLOYMENT.md, documentation maintenance"
argument-hint: "[action] [component]"
metadata:
  author: duyvo26
  version: "1.0.0"
---

# Skill: Develop Docs — Hệ thống Tài liệu Phát triển Chuẩn

## Mục tiêu

Mọi dự án code PHẢI có đủ bộ tài liệu phát triển (`develop docs`) để Developer và AI Coding Agent có thể:

- Hiểu cấu trúc, kiến trúc và trạng thái thực tế của dự án.
- Theo dõi công việc đã hoàn thành, đang thực hiện và cần thực hiện.
- Quản lý kế hoạch phát triển, lỗi tồn đọng và lịch sử thay đổi.
- Duy trì tính liên tục giữa các phiên làm việc khác nhau.

Nguyên tắc gốc: **tài liệu phản ánh đúng source code tại thời điểm viết**. Không suy đoán, không ghi nhận tính năng chưa tồn tại là đã hoàn thành, không tạo API/schema/kiến trúc không có thật.

---

## Khi nào dùng skill này

- Dự án mới, chưa có tài liệu phát triển.
- Người dùng yêu cầu "viết docs", "tài liệu dự án", "developer documentation", "develop docs".
- Sau mỗi task code: bắt buộc cập nhật tài liệu theo Mục 6.
- Cần audit tài liệu hiện có so với source code.

### Hành động hỗ trợ

| Action | Ý nghĩa |
|--------|---------|
| `setup` | Khởi tạo toàn bộ bộ tài liệu cho dự án chưa có docs |
| `configure` | Chuẩn hoá cấu trúc và format tài liệu đang có |
| `implement` | Bổ sung tài liệu kỹ thuật còn thiếu |
| `review` | Đối chiếu docs với source, tìm mâu thuẫn và khoảng trống |
| `fix` | Sửa nội dung lệch, cập nhật trạng thái task/project |
| `optimize` | Giảm trùng lặp, rút gọn, cải thiện khả năng bảo trì |

---

## 1. Cấu trúc bộ tài liệu

```text
project/
├── README.md
├── AGENTS.md
├── PROJECT_STATUS.md
├── TASKS.md
├── ROADMAP.md
├── CHANGELOG.md
├── KNOWN_ISSUES.md
└── docs/
    ├── ARCHITECTURE.md
    ├── TECHNICAL_SPECIFICATION.md
    ├── DATABASE.md
    ├── API_DOCUMENTATION.md
    ├── DEVELOPMENT_GUIDE.md
    └── DEPLOYMENT.md
```

### Phân loại và điều kiện tạo

| File | Vai trò | Điều kiện |
|------|---------|-----------|
| `README.md` | Cửa ngõ dự án, cài đặt và chạy thử | Bắt buộc — xem `skill: readme-writing` |
| `AGENTS.md` | Quy tắc làm việc cho Developer và AI Agent | Bắt buộc |
| `PROJECT_STATUS.md` | Trạng thái dự án tại thời điểm cập nhật | Bắt buộc |
| `TASKS.md` | Quản lý công việc chi tiết | Bắt buộc |
| `ROADMAP.md` | Định hướng và các giai đoạn phát triển | Bắt buộc khi dự án có nhiều hơn một giai đoạn hoặc tính năng dự kiến |
| `CHANGELOG.md` | Lịch sử thay đổi thực tế | Bắt buộc |
| `KNOWN_ISSUES.md` | Lỗi và technical debt đã xác minh | Chỉ tạo khi có issue thật, không tạo file rỗng |
| `docs/ARCHITECTURE.md` | Kiến trúc và luồng hoạt động | Bắt buộc với dự án từ 2 module trở lên |
| `docs/TECHNICAL_SPECIFICATION.md` | Đặc tả kỹ thuật chi tiết | Khi có logic nghiệp vụ hoặc ràng buộc kỹ thuật phức tạp |
| `docs/DATABASE.md` | Schema, quan hệ, migrations | Khi dự án có database |
| `docs/API_DOCUMENTATION.md` | Endpoints, params, responses, auth | Khi dự án có API |
| `docs/DEVELOPMENT_GUIDE.md` | Hướng dẫn phát triển | Bắt buộc |
| `docs/DEPLOYMENT.md` | Build, deploy, cấu hình, vận hành | Khi có môi trường deploy thực tế |

Quy tắc: chỉ tạo tài liệu thực sự phù hợp với dự án. Không tạo file rỗng hoặc nội dung giả để đủ số lượng.

### Bộ tối thiểu theo loại dự án

| Loại dự án | Tài liệu tối thiểu |
|------------|--------------------|
| Backend API | README, AGENTS, PROJECT_STATUS, TASKS, CHANGELOG, docs/ARCHITECTURE, docs/DATABASE, docs/API_DOCUMENTATION, docs/DEVELOPMENT_GUIDE, docs/DEPLOYMENT |
| Full-stack | Như Backend API, thêm mô tả frontend trong ARCHITECTURE và DEVELOPMENT_GUIDE |
| CLI / Library | README, AGENTS, PROJECT_STATUS, TASKS, CHANGELOG, docs/ARCHITECTURE, docs/DEVELOPMENT_GUIDE |
| AI / RAG | Như Backend API, thêm luồng AI, prompt, model và vector store trong TECHNICAL_SPECIFICATION |

---

## 2. Phase 1 — Analyze Project (chỉ đọc, không sửa source)

Trước khi tạo tài liệu, kiểm tra và ghi lại:

1. Cấu trúc thư mục và các thành phần chính.
2. Ngôn ngữ lập trình, framework và thư viện đang sử dụng.
3. Kiến trúc hệ thống và cách các module tương tác.
4. Database, schema, migrations và quan hệ dữ liệu.
5. API, services, controllers và các integrations.
6. Các tính năng đã triển khai (kèm bằng chứng: file, route, test).
7. Các tính năng đang triển khai hoặc còn dang dở.
8. Các lỗi, giới hạn kỹ thuật và technical debt có thể xác minh.
9. Cấu hình môi trường, cách cài đặt, chạy và kiểm thử.
10. Trạng thái Git hiện tại nếu có.

Tuyệt đối không thay đổi source code trong giai đoạn này.

---

## 3. Phase 2 — Build Documentation

### Thứ tự thực hiện

1. Đọc source theo checklist Phase 1.
2. Viết tài liệu kỹ thuật trước: `ARCHITECTURE` → `TECHNICAL_SPECIFICATION` → `DATABASE` → `API_DOCUMENTATION` → `DEVELOPMENT_GUIDE` → `DEPLOYMENT`.
3. Viết tài liệu quy trình: `AGENTS.md` → `README.md` (kế thừa skill `readme-writing`).
4. Viết tài liệu trạng thái: `PROJECT_STATUS` → `TASKS` → `ROADMAP` → `CHANGELOG` → `KNOWN_ISSUES`.
5. Chạy Final Verification (Mục 8) và báo cáo kết quả.

### Xử lý tài liệu đã tồn tại

- Đọc và kế thừa nội dung cũ trước khi ghi.
- Chuẩn hoá format, không xoá hoặc ghi đè khi chưa kiểm tra.
- Ghi rõ phần đã cập nhật, phần còn `UNVERIFIED`.
- Nếu tài liệu cũ mâu thuẫn với source, sửa theo source và ghi chú lý do.

---

## 4. Quy chuẩn nội dung từng file gốc

### AGENTS.md

Phải có đủ các phần:

- Vai trò và mục tiêu dự án.
- Quy tắc lập trình và coding conventions (liên kết `skill: coding-conventions`, `skill: execution-rules`).
- Cấu trúc source code.
- Quy trình làm việc của Developer và AI Agent.
- Lệnh cài đặt, chạy, build và test.
- Nguyên tắc bắt buộc khi chỉnh sửa source code.
- Quy định cập nhật tài liệu sau mỗi task (trỏ về Mục 6 của skill này).

### PROJECT_STATUS.md

Phản ánh trạng thái tại thời điểm cập nhật:

- Tổng quan tiến độ.
- Module đã hoàn thành (kèm bằng chứng xác nhận).
- Module đang phát triển.
- Module chưa triển khai.
- Công việc đang được ưu tiên.
- Công việc tiếp theo.
- Vấn đề đang bị chặn.
- Thời điểm cập nhật gần nhất.

Mẫu:

```markdown
# PROJECT STATUS

Cập nhật lần cuối: YYYY-MM-DD HH:mm (timezone)

## Tổng quan
{Tóm tắt 2-4 dòng về tiến độ hiện tại}

## Module đã hoàn thành
| Module | Trạng thái | Bằng chứng |
|--------|-----------|------------|
| auth | Completed | app/routers/auth.py, test/test_auth.py |

## Module đang phát triển
| Module | Trạng thái | Phần còn thiếu |
|--------|-----------|----------------|

## Module chưa triển khai
- {Danh sách}

## Ưu tiên hiện tại
1. {Việc đang ưu tiên}

## Công việc tiếp theo
- {Việc kế tiếp}

## Vấn đề đang bị chặn
- {Blocker và lý do}
```

### TASKS.md

Mỗi task phải có: Task ID duy nhất, tên, mô tả, trạng thái, ưu tiên, phạm vi ảnh hưởng, Acceptance Criteria, Dependencies.

Nhóm task theo module hoặc chức năng. Trạng thái hợp lệ: `TODO`, `IN_PROGRESS`, `BLOCKED`, `IN_REVIEW`, `DONE`, `CANCELLED`.

Mẫu:

```markdown
# TASKS

## Module: {tên module}

| ID | Task | Status | Priority | Scope |
|----|------|--------|----------|-------|
| TASK-001 | {Tên công việc} | TODO | High | app/routers/auth.py |

### TASK-001 — {Tên công việc}

- Trạng thái: TODO
- Ưu tiên: High | Medium | Low
- Phạm vi ảnh hưởng: {file/module}
- Mô tả: {Mô tả ngắn gọn, kiểm chứng được}
- Acceptance Criteria:
  - [ ] {Tiêu chí 1}
  - [ ] {Tiêu chí 2}
- Dependencies: {TASK-xxx hoặc Không}
- Ghi chú: {Thông tin bổ sung nếu có}
```

### ROADMAP.md

- Định hướng phát triển.
- Các giai đoạn triển khai và milestones.
- Tính năng dự kiến.
- Dependencies và thứ tự ưu tiên.
- Điều kiện hoàn thành từng giai đoạn.

Không tự đặt thời hạn nếu chưa có dữ liệu hoặc yêu cầu từ người quản lý dự án.

### CHANGELOG.md

Theo format Keep a Changelog, chỉ ghi thay đổi thực tế:

- `Added`: tính năng mới.
- `Changed`: thay đổi chức năng.
- `Fixed`: sửa lỗi.
- `Removed`: thành phần bị loại bỏ.
- `Security`: thay đổi liên quan bảo mật.

Không ghi tính năng dự kiến vào CHANGELOG.

Mẫu:

```markdown
# CHANGELOG

## [Unreleased]

### Added
- {Mô tả tính năng mới}

### Changed
- {Mô tả thay đổi}

### Fixed
- {Mô tả lỗi đã sửa}

### Removed
- {Thành phần đã bỏ}

### Security
- {Thay đổi bảo mật}
```

### KNOWN_ISSUES.md

Mỗi issue phải có: mô tả, nguyên nhân (nếu đã xác định), mức độ nghiêm trọng, phạm vi ảnh hưởng, cách tái hiện, hướng xử lý, trạng thái khắc phục.

Mẫu:

```markdown
# KNOWN ISSUES

## ISSUE-001 — {Tên lỗi}

- Mức độ: Critical | High | Medium | Low
- Trạng thái: Open | Investigating | Fixed | Won't Fix
- Phạm vi ảnh hưởng: {module/endpoint}
- Mô tả: {Hiện tượng}
- Nguyên nhân: {Nếu đã xác định, ghi rõ}
- Cách tái hiện:
  1. {Bước 1}
  2. {Bước 2}
- Hướng xử lý: {Đề xuất}
```

---

## 5. Quy chuẩn tài liệu trong docs/

Tất cả nội dung phải dựa trên source code thực tế. Không tự tạo API, database schema hoặc kiến trúc không tồn tại.

| File | Nội dung bắt buộc |
|------|-------------------|
| `ARCHITECTURE.md` | Sơ đồ tổng quan, phân lớp, module và luồng request chính. Dùng Mermaid nếu phù hợp. |
| `TECHNICAL_SPECIFICATION.md` | Đặc tả chức năng, ràng buộc kỹ thuật, xử lý lỗi, hiệu năng, bảo mật. |
| `DATABASE.md` | Danh sách bảng, cột, kiểu dữ liệu, khóa, quan hệ, migrations, index. |
| `API_DOCUMENTATION.md` | Method, path, auth, request params/body, response mẫu, mã lỗi. |
| `DEVELOPMENT_GUIDE.md` | Cài đặt môi trường, chạy dev, test, coding flow, quy ước, troubleshooting. |
| `DEPLOYMENT.md` | Yêu cầu hạ tầng, build, cấu hình môi trường, quy trình deploy, rollback, vận hành. |

Quy tắc liên kết: root docs trỏ tới `docs/` bằng đường dẫn tương đối, không sao chép nội dung giữa các file.

---

## 6. Hệ thống trạng thái thống nhất

| Trạng thái | Mã | Điều kiện |
|-----------|----|-----------|
| Completed | `DONE` | Đã triển khai, có test và Acceptance Criteria được xác nhận |
| In Progress | `IN_PROGRESS` | Đang triển khai, chưa hoàn tất |
| Planned | `TODO` | Đã lên kế hoạch nhưng chưa thực hiện |
| Blocked | `BLOCKED` | Không thể tiếp tục do phụ thuộc hoặc trở ngại |
| In Review | `IN_REVIEW` | Code xong, đang chờ review hoặc kiểm thử |
| Cancelled | `CANCELLED` | Đã hủy, ghi rõ lý do |

Không đánh dấu `DONE` chỉ vì code đã được viết. Phải kiểm tra implementation, test và Acceptance Criteria. Nếu chưa thể xác minh, ghi rõ `UNVERIFIED`.

---

## 7. Quy trình cập nhật tài liệu sau mỗi task (bắt buộc)

Áp dụng cho mọi Developer và AI Coding Agent làm việc trên dự án.

1. Kiểm tra lại các thay đổi thực tế trong source code.
2. Cập nhật trạng thái task trong `TASKS.md`.
3. Cập nhật `PROJECT_STATUS.md` nếu trạng thái dự án thay đổi.
4. Cập nhật `CHANGELOG.md` nếu có thay đổi đáng chú ý.
5. Cập nhật `KNOWN_ISSUES.md` nếu phát hiện hoặc khắc phục lỗi.
6. Cập nhật tài liệu kỹ thuật nếu kiến trúc, API, database hoặc quy trình phát triển thay đổi.
7. Kiểm tra tính nhất quán giữa các file Markdown.

Không cập nhật tài liệu theo kiểu hình thức. Chỉ cập nhật những nội dung thực sự bị ảnh hưởng.

---

## 8. Nguyên tắc bắt buộc

- Không chỉnh sửa source code trong nhiệm vụ tài liệu.
- Không tự ý thay đổi cấu hình dự án.
- Không xóa hoặc ghi đè tài liệu hiện có nếu chưa kiểm tra.
- Ưu tiên kế thừa và chuẩn hóa tài liệu hiện có.
- Không sao chép cùng một nội dung vào nhiều file.
- Không ghi thông tin giả định như sự thật.
- Sử dụng Markdown rõ ràng, có heading, bảng và checklist khi phù hợp.
- Tài liệu phải ngắn gọn nhưng đầy đủ, dễ đọc và dễ bảo trì.
- Sử dụng tiếng Việt cho nội dung giải thích, giữ nguyên các thuật ngữ kỹ thuật tiếng Anh cần thiết.
- Không dùng emoji trong bất kỳ file Markdown nào.

---

## 9. Final Verification

Sau khi hoàn thành:

1. Kiểm tra toàn bộ file đã tạo.
2. Đối chiếu nội dung với source code.
3. Kiểm tra các đường dẫn liên kết giữa tài liệu.
4. Kiểm tra không có thông tin mâu thuẫn.
5. Kiểm tra task và trạng thái dự án nhất quán.
6. Xác nhận những nội dung chưa kiểm chứng đã được đánh dấu `UNVERIFIED`.

---

## 10. Báo cáo kết quả

Trả về báo cáo cuối cùng gồm:

- Những file đã tạo.
- Những file đã cập nhật.
- Tổng quan trạng thái dự án được phát hiện.
- Số lượng task `DONE`, `IN_PROGRESS`, `TODO`, `BLOCKED`.
- Các vấn đề kỹ thuật đáng chú ý.
- Những nội dung chưa thể xác minh.
- Các đề xuất ưu tiên phát triển tiếp theo.

Deliverable: một hệ thống tài liệu Markdown hoàn chỉnh, phản ánh chính xác dự án hiện tại và có thể sử dụng lâu dài cho cả Developer lẫn AI Coding Agent.

---

## File liên quan

- [Cấu trúc Dự án Tiêu chuẩn (Skill DuyVo26)](skill: project-structure)
- [Viết README.md Chuẩn](skill: readme-writing)
- [Codebase Mapper (map.md)](skill: codebase-mapper)
- [Git Workflow & Commit Convention](skill: git-workflow)
- [Tiêu chuẩn Viết Code (Coding Conventions)](skill: coding-conventions)
- [Quy tắc Thực thi Bắt buộc (Execution Rules)](skill: execution-rules)
