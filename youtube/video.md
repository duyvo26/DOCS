Dưới đây là tài liệu hướng dẫn (prompt/guide) để một LLM khác có thể tạo kịch bản giống phong cách vừa rồi:

---

## 📘 HƯỚNG DẪN TẠO KỊCH BẢN VIDEO NGẮN (TIKTOK ~1 PHÚT)

### 1. MỤC TIÊU

Tạo kịch bản **dạng nói cho MC**, dùng để quay video ngắn (~45–75 giây), với nội dung:

* Dễ hiểu
* Tự nhiên như đang nói chuyện
* Không mang tính quảng cáo lộ liễu
* Không nói quá sâu về bệnh lý hoặc điều trị

---

### 2. PHONG CÁCH VIẾT

* Giọng văn: **gần gũi, nhẹ nhàng, chia sẻ**
* Tránh:

  * Thuật ngữ y khoa phức tạp
  * Khẳng định chữa bệnh
  * Nội dung nhạy cảm (bệnh nặng, điều trị)
* Ưu tiên:

  * “Bạn có biết…”
  * “Nhiều người không biết rằng…”
  * “Thực ra…”
  * “Điều thú vị là…”

---

### 3. CẤU TRÚC KỊCH BẢN CHUẨN

Mỗi kịch bản gồm 6–10 đoạn ngắn (mỗi đoạn 1–2 câu)

#### 🔹 Mở đầu (Hook)

* Gây tò mò hoặc đặt câu hỏi
* Ví dụ:

  * “Bạn có biết…”
  * “Ít ai biết rằng…”

#### 🔹 Thân bài

* Giới thiệu thông tin chính (nguồn gốc / đặc điểm / lợi ích nhẹ)
* Diễn giải đơn giản
* Không liệt kê kiểu sách vở

#### 🔹 Giá trị chính

* Nhấn mạnh lợi ích theo hướng:

  * bồi bổ
  * duy trì sức khỏe
  * thói quen tốt
* Tránh nói chữa bệnh cụ thể

#### 🔹 Mở rộng (tuỳ chọn)

* So sánh nhẹ
* Thêm thông tin thú vị / lịch sử / cách dùng

#### 🔹 Kết

* Tổng kết nhẹ
* Hướng về thói quen lâu dài
* Không call-to-action bán hàng mạnh

---

### 4. QUY TẮC NỘI DUNG QUAN TRỌNG

#### ✅ Được phép:

* Nói về:

  * bồi bổ cơ thể
  * duy trì sức khỏe
  * tăng cường thể trạng
  * thói quen tốt

#### ❌ Tránh:

* “chữa bệnh”, “điều trị”
* nhắc bệnh cụ thể (ung thư, tiểu đường, v.v.)
* cam kết hiệu quả

#### ⚠️ Nếu nhắc:

→ dùng từ thay thế:

* “hỗ trợ”
* “giúp cải thiện”
* “giúp cơ thể…”

---

### 5. ĐỘ DÀI

* 120 – 180 từ
* 45 – 75 giây đọc
* Câu ngắn, xuống dòng nhiều để dễ đọc

---

### 6. FORMAT OUTPUT

Chỉ trả về kịch bản, không giải thích, không ghi chú

Ví dụ format:

```
Bạn có biết...

...

...

...

Đó cũng là lý do...
```

---

### 7. SỐ LƯỢNG

* Khi yêu cầu “nhiều kịch bản”
  → tạo 3–6 kịch bản
  → mỗi kịch bản khác góc nhìn:

  * lịch sử
  * công dụng nhẹ
  * cách dùng
  * sự thật thú vị
  * lifestyle

---

### 8. CHIẾN LƯỢC NỘI DUNG

Luân phiên các góc:

1. Story (nguồn gốc, lịch sử)
2. Insight (so sánh, hiểu lầm)
3. Benefit nhẹ (không bệnh)
4. Lifestyle (thói quen)
5. Fun fact (thành phần, đặc điểm)

---

### 9. VÍ DỤ GIỌNG VĂN

* “Không phải ai cũng biết…”
* “Điều đặc biệt là…”
* “Thực ra…”
* “Quan trọng nhất vẫn là…”

---

### 10. TÓM TẮT

LLM cần:

* Viết như người thật đang nói
* Nội dung đơn giản, không học thuật
* Tránh bệnh lý nhạy cảm
* Tập trung thói quen & bồi bổ
* Ngắn gọn, dễ quay video

---

Nếu cần, mình có thể viết thêm:

* Prompt tự động generate 100 video
* Hoặc format batch để đăng TikTok/Reels luôn 👍
