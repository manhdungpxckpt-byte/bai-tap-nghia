# 🚗 Giáo trình MATLAB/Simulink — Mô phỏng hệ thống truyền lực đến bánh xe chủ động

> Giáo trình tiếng Việt dành cho ngườ**i mới bắt đầu**, mục tiêu: **xây dựng và chạy được mô hình Simulink mô phỏng hệ thống truyền lực** (động cơ → hộp số → truyền lực chính → bánh xe chủ động → xe chuyển động).

---

## 🎯 Sau khi học xong bạn sẽ

- Hiểu được kiến thức MATLAB cơ bản đủ để đọc và viết script
- Thành thạo thao tác Simulink cơ bản (khối, nối dây, chạy mô phỏng, xem Scope)
- Hiểu vật lý của hệ thống truyền lực: mômen truyền từ động cơ đến bánh xe chủ động thế nào
- **Chạy được mô phỏng hoàn chỉnh** và vẽ đồ thị vận tốc xe, vòng tua động cơ, mômen

## 📋 Yêu cầu

- MATLAB + Simulink (khuyến nghị R2020a trở lên; càng mới càng tốt, hiện nay là R2026a/R2026b)
- **Không cần toolbox phụ** — mô hình chỉ dùng các khối Simulink cơ bản
- Nếu chưa có bản quyền Simulink: khóa **Simulink Onramp miễn phí** của MathWorks cho phép học và dùng Simulink Online trong thờigian học → truy cập `matlabacademy.mathworks.com`

## 📂 Cấu trúc thư mục

```text
matlab/
├── README.md  ← bạn đang đọc file này
├── 01-matlab-co-ban.md            Bài 1: MATLAB căn bản đủ dùng
├── 02-simulink-co-ban.md          Bài 2: Làm quen Simulink
├── 03-he-thong-truyen-luc.md      Bài 3: Lý thuyết + hướng dẫn mô hình truyền lực
├── 04-bai-tap-luyen-tap.md        Bài 4: Bài tập thực hành từ dễ đến khó
└── code/
    ├── code_truyen_luc_banh_xe.m  ⭐ FILE ALL-IN-ONE (chỉ cần file này!)
    ├── thong_so_xe.m              [bản tách riêng] Thông số xe & truyền lực
    ├── tao_mo_hinh_truyen_luc.m   [bản tách riêng] Script dựng sơ đồ
    └── mo_phong_truyen_luc.m      [bản tách riêng] Chạy + vẽ kết quả
```

## 🚀 Cách chạy nhanh (3 bước)

1. Mở MATLAB, `cd` đến thư mục `matlab/code/`
2. Gõ trong Command Window:
   ```matlab
   code_truyen_luc_banh_xe
   ```
3. Xong! Một file duy nhất sẽ tự: nạp thông số → tạo mô hình Simulink `he_thong_truyen_luc.slx` → chạy 60 giây mô phỏng → vẽ 3 đồ thị kết quả.

> 💡 Không cần tự dựng sơ đồ bằng tay — code dùng `add_block` / `add_line` để **tạo từng khối và nối dây tự động**. Bạn mở file `.slx` lên là thấy toàn bộ sơ đồ. (Bản tách 3 file riêng cũng có sẵn nếu bạn muốn học theo cấu trúc module.)

## 📖 Lộ trình học đề xuất

| Bước | Nội dung | Thờigian |
|------|----------|-----------|
| 1 | Đọc `01-matlab-co-ban.md`, gõ thử các ví dụ | ~1 giờ |
| 2 | Đọc `02-simulink-co-ban.md` | ~30 phút |
| 3 | Đọc `03-he-thong-truyen-luc.md`, chạy mô phỏng | ~1 giờ |
| 4 | Làm bài tập ở `04-bai-tap-luyen-tap.md` | tùy ý |
| 5 (thưởng) | Khóa miễn phí **Simulink Onramp** để lấy chứng chỉ | ~3 giờ |

## 🔗 Tài liệu tham khảo chuẩn từ MathWorks

- MATLAB Onramp & Simulink Onramp (miễn phí, có chứng chỉ): https://matlabacademy.mathworks.com
- Video *Modeling a Vehicle Powertrain* (mô hình powertrain bằng Simscape Driveline): https://www.mathworks.com/videos/modeling-a-vehicle-powertrain-68822.html
- Ví dụ *Complete Vehicle Model* (Simscape Driveline — hướng nâng cao): https://www.mathworks.com/help/sdl/ug/about-the-complete-vehicle-model.html
- Ví dụ động lực học dọc xe (phương trình chuẩn): https://www.mathworks.com/help/ident/ug/modeling-a-vehicle-dynamics-system.html

---

✨ *Giáo trình thuộc repo bai-tap-nghia — tạo ngày 20/10/2026*
