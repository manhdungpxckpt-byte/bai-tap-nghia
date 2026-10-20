# Bài 4: Bài tập luyện tập 📝

> Làm lần lượt từ Bài 1 → Bài 7 (khó dần). Với mỗi bài, chạy `thong_so_xe` để nạp lại thông số gốc khi cần reset.

---

## Bài 1 — Đọc kết quả cơ bản ⭐
Chạy `mo_phong_truyen_luc`. Ghi lại:
1. Vận tốc xe sau 60 s
2. Thờigian xe đạt 60 km/h (double-click Scope, dùng con trỏ đo, hoặc `find(v>=60,1)*0.1`)
3. Vòng tua động cơ lúc vận tốc cực đại

## Bài 2 — Ảnh hưởng của chân ga ⭐
Chạy mô phỏng với `u_ga = 0.3 / 0.5 / 1.0`, vẽ chồng 3 đường:

```matlab
thong_so_xe;
u_ga = 0.3; sim(mdl); v1 = v_kmh.signals.values;
u_ga = 0.5; sim(mdl); v2 = v_kmh.signals.values;
u_ga = 1.0; sim(mdl); v3 = v_kmh.signals.values;
t = v_kmh.time;
plot(t, v1, t, v2, t, v3, 'LineWidth', 1.5); grid on;
legend('ga 30%','ga 50%','ga 100%'); xlabel('s'); ylabel('km/h');
```

**Câu hỏi:** vận tốc tối đa có tỉ lệ thuận với ga không? Vì sao? *(Gợi ý: nhớ cản gió ~ v²)*

## Bài 3 — Thử từng tay số ⭐⭐
Hộp số 5 cấp thực tế: `ig1=3.5, ig2=2.1, ig3=1.4, ig4=1.0, ig5=0.8`.

Với mỗi tay số, gán `ig = ...`, chạy `sim`, ghi v_max vào bảng:

| Tay số | ig | v_max (km/h) | Cảm giác tăng tốc đầu |
|---|---|---|---|
| 1 | 3.5 | | mạnh nhất? |
| ... | | | |
| 5 | 0.8 | | yếu nhất? |

**Giải thích** tại sao số 1 tăng tốc mạnh nhưng "hết đà" sớm, số 5 ngược lại. *(Gợi ý: dùng PT 2 và PT 5 ở Bài 3.)*

## Bài 4 — Lên dốc ⭐⭐
Thêm lực cản dốc `F_dốc = m·g·sin(α)` với dốc α = 5°:
- Mở khối `Fcan_Fcn`, sửa biểu thức thành:
  ```
  m_xe*g*f0+0.5*rho*Cd*Af*u^2+m_xe*g*sin(5*pi/180)
  ```
- Chạy lại, so sánh v_max với đường bằng phẳng. Xe có lên nổi dốc 15° ở tay số hiện tại không?

## Bài 5 — Tính quãng đường đi được ⭐⭐
Thêm 1 khối **Integrator** nữa (ngõ vào nối từ ngõ ra vận tốc `v` tính bằng m/s, tức **trước** khối `kmh`) → ngõ ra là quãng đường `s(t)`. Vẽ đường cong s(t) và cho biết sau 60 s xe đi được bao nhiêu mét.

```matlab
add_block('simulink/Continuous/Integrator','he_thong_truyen_luc/Integrator_s', ...
    'Position',[560 170 590 200]);
add_line('he_thong_truyen_luc','Integrator/1','Integrator_s/1','autorouting','on');
```

## Bài 6 — Nhả ga giữa chừng ⭐⭐⭐
Thay khối `Ga` (Constant) bằng khối **Step**: t=0 ga 70%, t=30 s nhả về 0:
- `add_block('simulink/Sources/Step', ...)` với `Time = 30`, `Before = 0.7`, `After = 0`
- Quan sát xe giảm tốc từ từ do cản. Ước lượng **quãng đường xe trôi** sau khi nhả ga.

## Bài 7 — Thử mô hình "xịn" của MathWorks ⭐⭐⭐ (mở rộng)
Nếu có thêm toolbox **Simscape Driveline**:
1. Mở ví dụ *Complete Vehicle Model* của MathWorks (Tires and Vehicles → Complete Vehicle Model)
2. So sánh cách mô hình hóa: đó là **kết nối vật lý** (trục quay, lực thật), mô hình của chúngta là **tín hiệu toán học** — cùng một bản chất vật lý, khác cách biểu diễn.
3. Xem video *Modeling a Vehicle Powertrain* để thấy động cơ + hộp số + lốp + thân xe được ghép sẵn thế nào.

---

🏁 **Khi nộp bài, nhớ đưa:** file `thong_so_xe.m`, `tao_mo_hinh_truyen_luc.m`, `mo_phong_truyen_luc.m`, file `.slx` được tạo ra, và hình chụp 3 đồ thị kết quả.
