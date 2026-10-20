# Bài 3: Mô phỏng hệ thống truyền lực đến bánh xe chủ động 🚗⚙️

> **Bài trọng tâm.** Hiểu vật lý của hệ thống truyền lực, cách ánh xạ từng bộ phận thành khối Simulink, và chạy được mô phỏng hoàn chỉnh.

## 1. Hệ thống truyền lực là gì?

Trên xe động cơ đốt trong cầu trước chủ động (FWD), công suất chảy theo đường:

```text
ĐỘNG CƠ → LY HỢP → HỘP SỐ (ig) → TRUYỀN LỰC CHÍNH + VI SAI (i0)
        → BÁN TRỤC TRÁI/PHẢI → BÁNH XE CHỦ ĐỘNG (cầu trước) → LỰC KÉO đẩy xe
```

Vai trò từng cấp:
- **Hộp số (`ig`)**: nhân mômen, giảm vòng tua. Số càng thấp `ig` càng lớn (số 1 khỏe, số 5 nhanh)
- **Truyền lực chính (`i0`)**: cặp bánh răng cố định trước vi sai, nhân mômen lần cuối
- **Vi sai**: chia mômen cho 2 bánh chủ động trái/phải (mô hình đơn giản: chia đều 50/50)
- **Bánh xe**: quy đổi **mômen → lực kéo** nhờ bán kính lăn `r`

## 2. Các phương trình vật lý của mô hình

### (1) Mômen động cơ — giảm dần khi vòng tua tăng
$$T_e = u_{ga} \cdot T_{max} \cdot \left(1 - \frac{\omega_e}{\omega_{max}}\right)$$

`u_ga` là độ mở bướm ga (0→1). Gần tới vòng tua giớihạn thì mômen → 0.

### (2) Khuếch đại qua hệ truyền → lực kéo tại bánh chủ động
$$T_{bánh} = T_e \cdot i_g \cdot i_0 \cdot \eta_t \qquad F_{kéo} = \frac{T_{bánh}}{r}$$

`ηt` ~ 0.9 là hiệu suất cơ khí (ma sát bánh răng, ly hợp...).

### (3) Lực cản xe phải thắng
$$F_{cản} = \underbrace{m g f_0}_{cản\ lăn} + \underbrace{\tfrac{1}{2}\rho C_d A_f v^2}_{cản\ gió}$$

### (4) Định luật II Newton → chuyển động of xe
$$m_{eff}\,\frac{dv}{dt} = F_{kéo} - F_{cản}, \qquad m_{eff} = m + J_e\left(\frac{i_g i_0}{r}\right)^2$$

`m_eff` gồm thêm quán tính quay của động cơ quy về khối lượng tương đương.

### (5) Liên hệ động học (bánh lăn không trượt)
$$\omega_e = \frac{i_g \cdot i_0}{r}\, v$$

→ khép kín mô hình: **vận tốc xe quyết định vòng tua động cơ → vòng tua quyết định mômen → mômen quyết định gia tốc → gia tốc tích phân ra vận tốc.**

## 3. Ánh xạ vật lý → khối Simulink

| Bộ phận / phương trình | Khối Simulink trong sơ đồ |
|---|---|
| Ngườilái đạp ga `u_ga` | **Constant** `Ga` |
| PT (1): mômen động cơ | **Fcn** `Te_Fcn`: `u(1)*Tmax*(1-u(2)/wmax)` |
| Khuếch đại `ig·i0·ηt` | **Gain** `Gain_ig` |
| Chia bán kính bánh xe → F_kéo | **Gain** `Gain_1r`: `1/r` |
| PT (3): lực cản | **Fcn** `Fcan_Fcn`: `m_xe*g*f0+0.5*rho*Cd*Af*u^2` |
| F_kéo − F_cản | **Sum** (dấu `+-`) |
| Chia `m_eff` → gia tốc | **Gain** `Gain_1m` |
| ∫ gia tốc → vận tốc | **Integrator** `Integrator` |
| Đổi m/s → km/h | **Gain** `kmh`: `3.6` |
| PT (5): v → vòng tua động cơ | **Gain** `Gain_we` (+ `Gain_rpm` đổi sang vòng/phút) |
| Hiển thị & ghi dữ liệu | **Scope** ×2, **To Workspace** ×3 |
| Đưa ωe phản hồi về khối động cơ | **Goto/From** tag `we` |

Sơ đồ tín hiệu khái quát:

```text
Ga ──► Mux ──► Te_Fcn ──► ×ig·i0·η ──► ×1/r ──►(+)Σ──► ×1/m_eff ──► ∫ ──► v ──► ×3.6 ──► Scope/WS
            ▲                                         (−)▲               │  │
            │ From we                                     │              │  └─► ×ig·i0/r ──► Goto we
            │                                          Fcan│(v)          │       └─► ×60/2π ──► Scope/WS rpm
            └──────────────────────────────────────────────┴─────────────┴v
           Te_Fcn ──► To Workspace (Te_kq)
```

## 4. Giả thiết đơn giản hóa (báo cáo nên ghi rõ)

1. Ly hợp **ngật hoàn toàn** (không trượt ly hợp lúc khởi hành)
2. Bánh xe **lăn không trượt** (chưa mô hình hóa lực bám/slip)
3. Đang gài **1 tay số cố định** (chưa có lịch chuyển số)
4. Đường **bằng phẳng**, không phanh
5. Đặc tính động cơ tuyến tính hóa — đủ dùng cho bài tập mô phỏng cơ bản

## 5. Chạy mô phỏng

```matlab
cd <thu muc bai-tap-nghia>/matlab/code
mo_phong_truyen_luc
```

Kỳ vọng: 3 đồ thị —
1. **Vận tốc xe**: tăng nhanh lúc đầu, chững dần vì cản gió ~ v² và mômen giảm theo vòng tua → đạt vận tốc cực đại **≈ 85 km/h** sau ~60 s, mất khoảng **15 s để lên 60 km/h** (thông số mặc định, ga 70%)
2. **Vòng tua động cơ**: tăng cùng dạng vận tốc (tỉ lệ thuận theo PT 5)
3. **Mômen động cơ**: cao lúc khởi hành, giảm dần khi xe tăng tốc

## 6. Hướng nâng cấp nếu đề bài yêu cầu sâu hơn

| Nâng cấp | Cách làm |
|---|---|
| Nhiều cấp số + chuyển số | Thêm khối **Switch**/logic theo v, `ig` đổi theo tay số |
| Trượt bánh (slip) | 2 khối Integrator riêng: động lực học bánh xe `Jw·dω/dt = T_b − Fx·r` và xe `m·dv/dt = Fx − Fcản`, liên hệ qua slip `s = (rω − v)/v` |
| Độ dốc đường | Cộng `m·g·sin(α)` vào lực cản (bài tập 4) |
| Phanh | Thêm ngõ vào lực phanh vào khối Sum |
| Mô hình vật lý chuẩn công nghiệp | **Simscape Driveline** — ví dụ *Complete Vehicle Model* và video *Modeling a Vehicle Powertrain* của MathWorks (động cơ, hộp số, lốp, thân xe cắm sẵn) |

---

⬅️ [02-simulink-co-ban.md](02-simulink-co-ban.md) | ➡️ Làm bài tập: [04-bai-tap-luyen-tap.md](04-bai-tap-luyen-tap.md)
