# Bài 1: MATLAB căn bản (vừa đủ dùng) 🟢

> Mục tiêu: đọc hiểu và viết được script MATLAB đơn giản. MATLAB = **MAT**rix **LAB**oratory — phòng thí nghiệm ma trận, nên mọi thứ xoay quanh con số, vector và ma trận.

## 1. Màn hình làm việc

| Khu vực | Dùng để |
|---|---|
| **Command Window** | Gõ lệnh chạy ngay lập tức |
| **Editor** | Viết script (file `.m`) để lưu & chạy nhiều lần |
| **Workspace** | Xem các biến đang tồn tại |
| **Current Folder** | Thư mục đang làm việc (MATLAB tìm file `.m` ở đây) |

## 2. Biến và phép gán

```matlab
a = 5        % gán a = 5, MATLAB in kết quả ra màn hình
b = 3;       % dấu ; ở cuối -> KHÔNG in kết quả (nhớ dùng!)
c = a + b;   % c = 8
```

- Tên biến **phân biệt hoa/thường**: `Tmax` khác `tmax`
- `%` đứng trước = chú thích (MATLAB bỏ qua)
- `clear` xóa sạch biến, `clc` xóa màn hình lệnh — hầu hết script nên mở đầu bằng `clear; clc;`

## 3. Vector và ma trận — sức mạnh của MATLAB

```matlab
v  = [1 2 3 4];          % vector hàng
A  = [1 2; 3 4];         % ma trận 2x2 (dấu ; xuống dòng)
t  = 0:0.1:10;           % 0 -> 10 bước nhảy 0.1 (rất hay dùng cho trục thờigian)
x  = linspace(0, 1, 100);% 100 điểm đều nhau từ 0 đến 1
```

**Phép toán theo phần tử** (thêm dấu chấm `.` trước phép tính):

```matlab
y = t.^2;        % bình phương TỪNG phần tử của t
z = 0.5*1.225*t.^2;   % giống công thức lực cản gió đó!
```

## 4. Vẽ đồ thị

```matlab
t = 0:0.1:10;
v = 100*(1 - exp(-t/10));   % ví dụ đường tăng tốc kiểu mũ

plot(t, v, 'b-', 'LineWidth', 1.5);   % b- = đường xanh dương liền
grid on;
xlabel('Thoi gian (s)'); ylabel('Van toc (km/h)');
title('Duong tang toc');

% Chia cửa sổ thành nhiều ô vẽ:
subplot(2,1,1); plot(t, v); title('Van toc');
subplot(2,1,2); plot(t, v/3.6); title('m/s');
```

## 5. Script và Function

**Script** = file `.m` chứa chuỗi lệnh, chạy là thực hiện tuần tự (file chéo trong thư mục `code/` toàn là script).

**Function** = có đầu vào/đầu ra, lưu tên file trùng tên hàm:

```matlab
% File: luc_keo.m
function F = luc_keo(T_banh_xe, r)
    F = T_banh_xe / r;   % luc keo = momen tai banh / ban kinh
end
```

Gọi thử trong Command Window: `luc_keo(900, 0.3)` → `ans = 3000` (N)

## 6. Lệnh cứu mạng cần nhớ

| Lệnh | Tác dụng |
|---|---|
| `help plot` | Xem trợ giúp ngắn về lệnh `plot` |
| `doc plot` | Mở tài liệu đầy đủ của lệnh |
| `whos` | Liệt kê biến trong workspace |
| `format long` | Hiển thị nhiều chữ số thập phân hơn |
| `disp(x)` / `fprintf('v = %.1f\n', v)` | In giá trị ra màn hình |

## 7. Thông số kiểu "file nạp dữ liệu"

Một mẫu rất phổ biến khi mô phỏng (bài 3 sẽ dùng): viết 1 script chỉ chứa thông số để nạp vào workspace trước khi chạy Simulink:

```matlab
% thong_so.m
m_xe = 1200;      % kg
r    = 0.30;      % m ban kinh banh xe
```

Sau đó trong Simulink, ô tham số của khối Gain chỉ cần gõ `m_xe` — Simulink tự lấy từ workspace. ✨ Đây chính là cách file `thong_so_xe.m` hoạt động.

---

➡️ **Xong bài này, chuyển sang** [02-simulink-co-ban.md](02-simulink-co-ban.md)
