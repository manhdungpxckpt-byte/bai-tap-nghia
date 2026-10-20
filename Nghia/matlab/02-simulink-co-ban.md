# Bài 2: Làm quen Simulink 🔵

> Mục tiêu: biết Simulink là gì, thao tác cơ bản với khối và dây nối, chạy mô phỏng và xem kết quả. Nắm được các khối sẽ dùng trong mô hình truyền lực.

## 1. Simulink là gì?

- Simulink là công cụ **mô hình hóa bằng sơ đồ khối** đi kèm MATLAB
- Thay vì viết vòng lặp tính từng bước thờigian, bạn **vẽ sơ đồ**: mỗi khối là một phép toán/thiết bị, đường dây là tín hiệu chảy qua
- Cực mạnh cho **hệ động lực** (thay đổi theo thờigian): xe cộ, động cơ, robot, mạch điện...

> Mở Simulink: gõ `simulink` trong Command Window → chọn **Blank Model**.

## 2. Thao tác cơ bản

| Thao tác | Cách làm |
|---|---|
| Thêm khối | Mở **Library Browser** (icon 4 ô vuông) → kéo thả khối vào sơ đồ |
| Nối dây | Kéo từ cổng ra (phải) của khối A tới cổng vào (trái) của khối B |
| Rẽ nhánh 1 tín hiệu | Giữ **Ctrl** rồi kéo từ đường dây có sẵn |
| Đặt tham số khối | **Double-click** vào khối |
| Đổi tên khối | Click vào tên bên dưới khối |
| Chạy mô phỏng | Nút ▶ **Run** (đặt Stop Time ở thanh công cụ) |
| Xem kết quả | Double-click khối **Scope** |

## 3. Các khối dùng trong mô hình truyền lực

| Khối (thư viện) | Vai trò trong mô hình |
|---|---|
| **Constant** (Sources) | Độ mở bướm ga (ngườilái đạp ga) |
| **Fcn** (User-Defined Functions) | Tính mômen động cơ, tính lực cản |
| **Gain** (Math Operations) | Tỷ số truyền, chia bán kính bánh xe, đổi đơn vị |
| **Sum** (Math Operations) | Tổng hợp: lực kéo **trừ** lực cản |
| **Integrator** (Continuous) | Tích phân gia tốc → vận tốc (trái tim của mô hình!) |
| **Mux** (Signal Routing) | Gộp 2 tín hiệu vào 1 dây |
| **Goto / From** (Signal Routing) | "Cầu nối không dây" cho sơ đồ gọn |
| **Scope** (Sinks) | Màn hình hiển thị tín hiệu theo thờigian |
| **To Workspace** (Sinks) | Gửi dữ liệu về MATLAB để vẽ đẹp hơn |

## 4. Solver — bộ máy tính của Simulink

Simulink giải vi phân bằng cách bước nhỏ theo thờigian (solver). Mặc định hay dùng nhất:

- `ode45` — cân bằng tốc độ/độ chính xác, phù hợp đa số bài (mô hình của chúng ta dùng cái này)
- Stop Time: tổng thờigian mô phỏng (ta dùng 60 giây)
- Max step `0.1` — bước tối đa 0.1 s cho đồ thị mượt

## 5. Điều khiển Simulink BẰNG CODE (quan trọng!)

Bài tập thường yêu cầu "viết code chạy sơ đồ Simulink". Các lệnh chính:

```matlab
new_system('ten_model');      % tạo model mới
open_system('ten_model');     % mở cửa sổ model

% thêm 1 khối từ thư viện vào model:
add_block('simulink/Math Operations/Gain', 'ten_model/KhoiGain');

% nối dây từ cổng 1 của A tới cổng 1 của B:
add_line('ten_model', 'KhoiA/1', 'KhoiB/1', 'autorouting','on');

% đặt tham số:
set_param('ten_model', 'StopTime', '60');

% chạy mô phỏng:
sim('ten_model');

save_system('ten_model');     % lưu thành file .slx
```

👉 Script `tao_mo_hinh_truyen_luc.m` trong thư mục `code/` dùng chính xác các lệnh này để **dựng toàn bộ sơ đồ tự động** — rất tiện nộp bài vì ai cũng tái tạo được sơ đồ chỉ bằng 1 lần chạy.

## 6. Kiểm tra nhanh sau bài này

Tự thử trong 5 phút: tạo model trắng, kéo 1 **Sine Wave** (Sources) nối vào 1 **Scope** (Sinks), bấm Run, mở Scope → thấy sóng sin là thành công ✅

---

⬅️ [01-matlab-co-ban.md](01-matlab-co-ban.md) | ➡️ **Sang trọng tâm:** [03-he-thong-truyen-luc.md](03-he-thong-truyen-luc.md)
