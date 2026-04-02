# QUY TRÌNH XỬ LÝ BÁO CÁO: TỪ DOCX SANG CẤU TRÚC MARKDOWN (AI AGENT READY)

Tài liệu này mô tả quy trình kỹ thuật để chuyển đổi một file báo cáo nghiệp vụ (DOCX/PDF) sang định dạng Markdown, trích xuất cấu trúc mục lục và phân mảnh nội dung để phục vụ các dự án AI, RAG (Retrieval-Augmented Generation) hoặc chấm điểm tự động.

---

## 1. Công nghệ và Thư viện sử dụng

Để đạt được hiệu quả cao nhất trong việc giữ nguyên định dạng bảng biểu, hình ảnh (nếu cần) và văn bản, các thư viện sau được tin dùng:

| Thư viện | Vai trò | Lý do chọn |
| :--- | :--- | :--- |
| **Microsoft MarkItDown** | Chuyển đổi DOCX -> MD | Thư viện mới nhất từ Microsoft, xử lý cực tốt dữ liệu từ Office sang Markdown sạch. |
| **Python Regex (re)** | Trích xuất cấu trúc | Tìm kiếm các Heading (#) và các đoạn tiêu đề in đậm (**Title**) đa dòng. |
| **Pathlib** | Quản lý file | Đảm bảo tương thích đường dẫn trên cả Windows và Linux. |

---

## 2. Quy trình thực hiện (Workflow)

### Bước 1: Chuyển đổi sang Markdown sạch
Thay vì đọc text thô (raw text) làm mất cấu trúc chương hồi, chúng ta sử dụng `MarkItDown` để giữ lại:
- Đánh dấu Heading (Chương 1, 1.1, 1.2...).
- Định dạng bảng biểu (Tables) dưới dạng Markdown Table.
- Các danh sách (Bulleted/Numbered lists).

```python
from markitdown import MarkItDown

def convert_docx_to_md(docx_path):
    md = MarkItDown()
    result = md.convert(docx_path)
    return result.markdown # Trả về chuỗi Markdown hoàn chỉnh
```

### Bước 2: Quét cấu trúc (Structure Scanning)
Sử dụng một `MarkdownScanner` để nhận diện phân cấp của báo cáo.
- **Level 1**: Thường là các dòng in đậm đơn độc hoặc `# Heading 1`.
- **Level 2-6**: Các Heading Markdown chuẩn `##`, `###`...

### Bước 3: Phân mảnh nội dung (Mapping Sections)
Hệ thống sẽ ghi nhớ "Dòng bắt đầu" và "Dòng kết thúc" của mỗi mục. Điều này cực kỳ quan trọng để AI Agent có thể trích xuất chính xác "Mục 2.2 nói về cái gì" mà không bị lẫn sang mục khác.

---

## 3. Cấu trúc Output mẫu (Bản đồ cấu trúc)

Sau khi xử lý, chúng ta sẽ có một "Bản đồ" (Map) như sau:

| Cấp độ | Tiêu đề mục | Dòng tham chiếu |
| :--- | :--- | :--- |
| L1 | **CHƯƠNG 1: GIỚI THIỆU** | [10:145] |
| L2 | &nbsp;&nbsp;&nbsp;&nbsp;1.1 Mục tiêu dự án | [12:40] |
| L2 | &nbsp;&nbsp;&nbsp;&nbsp;1.2 Phạm vi thực hiện | [41:145] |
| L1 | **CHƯƠNG 2: KIẾN TRÚC HỆ THỐNG** | [146:500] |

---

## 4. Ứng dụng cho các dự án khác

Quy trình này có thể áp dụng ngay cho các bài toán:

1.  **AI Grader (Chấm điểm tự động)**: Đối chiếu từng mục trong báo cáo với yêu cầu (Rubric) hoặc so khớp với mã nguồn (Code) tại mục tương ứng.
2.  **Smart RAG**: Thay vì chia nhỏ file theo số ký tự (Chunk size - dễ gây mất ngữ cảnh), chúng ta chia theo **Chương/Mục**. AI sẽ đọc trọn vẹn một ý tưởng trong một tiêu đề.
3.  **Auto Summary**: Tự động tạo bản tóm tắt cho từng chương lớn mà không cần con người copy-paste.
4.  **Báo cáo đối soát (Audit)**: Tự động phát hiện các mục bị bỏ trống hoặc nội dung không liên quan đến tiêu đề trong các hồ sơ thầu, đồ án.

---

## 5. Mã nguồn tham khảo (Core Logic)

Cốt lõi của việc trích xuất nằm ở Regex nhận diện tiêu đề:

```python
# Nhận diện Heading Markdown
md_pattern = r"(?m)^(#{1,6})\s+(.+)$"

# Nhận diện Tiêu đề in đậm (thường dùng trong Word khi chuyển sang MD)
bold_pattern = r"(?m)^\s*\*\*(.*?)\*\*\s*$"
```

VIỆC KẾT HỢP HAI MẪU NÀY GIÚP BAO PHỦ 99% CÁC LOẠI ĐỊNH DẠNG BÁO CÁO HIỆN NAY.

---

## 6. CODE DEMO CHI TIẾT (SỬ DỤNG CHO DỰ ÁN MỚI)

Dưới đây là một script Python mẫu để bạn có thể sao chép và bắt đầu xử lý file báo cáo ngay lập tức.

```python
import re
from pathlib import Path
from markitdown import MarkItDown

# 1. Chuyển đổi DOCX sang Markdown
def convert_to_md(docx_path):
    md = MarkItDown()
    return md.convert(docx_path).markdown

# 2. Quét cấu trúc Headings
def get_structure_map(content):
    # Regex tìm Heading từ L1 đến L3
    md_pattern = r"(?m)^(#{1,3})\s+(.+)$"
    # Tìm Title in đậm (thường ở L1 khi Word được chuyển sang MD)
    bold_pattern = r"(?m)^\s*\*\*(.*?)\*\*\s*$"
    
    headings = []
    
    # Quét in đậm (L1)
    for m in re.finditer(bold_pattern, content):
        line = content.count('\n', 0, m.start()) + 1
        headings.append({"level": 1, "title": m.group(1).strip(), "line": line, "pos": m.start()})
    
    # Quét chuẩn Heading Markdown (L2, L3...)
    for m in re.finditer(md_pattern, content):
        level = len(m.group(1)) + 1 # +1 vì thường bold đã là L1
        headings.append({"level": level, "title": m.group(2).strip(), "line": content.count('\n', 0, m.start()) + 1, "pos": m.start()})
    
    # Sắp xếp theo dòng thực tế
    headings.sort(key=lambda x: x['pos'])
    return headings

# --- CHẠY THỬ NGHIỆM ---
path_doc = "path/to/your/report.docx"
if Path(path_doc).exists():
    # Bước 1: Convert
    md_content = convert_to_md(path_doc)
    
    # Bước 2: Trích xuất cấu trúc
    structure = get_structure_map(md_content)
    
    # Bước 3: Hiển thị bảng mục lục
    print(f"| Cấp độ | Tiêu đề chương/mục | Dòng |")
    print(f"|---|---|---|")
    for h in structure:
        indent = "&nbsp;" * (h['level'] - 1) * 4
        print(f"| L{h['level']} | {indent}{h['title']} | {h['line']} |")
    
    # Bước 4: Lưu file MD để xử lý RAG/AI
    Path("report_output.md").write_text(md_content, encoding="utf-8")
```

Script trên giúp bạn nhanh chóng biến một file Word cồng kềnh thành một **bảng chỉ mục (Index Table)** cực kỳ giá trị để đẩy vào Prompt của AI hoặc hệ thống tìm kiếm nội dung theo chương.
