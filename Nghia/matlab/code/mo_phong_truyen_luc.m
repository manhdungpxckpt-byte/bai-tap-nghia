%% mo_phong_truyen_luc.m
% Chay mo phong he thong truyen luc (Simulink) va ve ket qua.
% Day la FILE CHINH - chi can go:  mo_phong_truyen_luc

clear; clc; close all;

%% 1. Nap thong so xe
thong_so_xe;

%% 2. Kiem tra / tao mo hinh Simulink
mdl = 'he_thong_truyen_luc';
if exist([mdl '.slx'], 'file')
    load_system(mdl);                 % model co san -> mo len
else
    tao_mo_hinh_truyen_luc;           % chua co -> dung tu dong
end

%% 3. Chay mo phong
set_param(mdl, 'StopTime', num2str(T_stop));
sim(mdl);

%% 4. Lay ket qua tu workspace
t   = v_kmh.time;                  % truc thoi gian [s]
v   = v_kmh.signals.values;        % van toc xe [km/h]
rpm = w_rpm.signals.values;        % vong tua dong co [vong/phut]
Te  = Te_kq.signals.values;        % momen dong co [Nm]

%% 5. Ve do thi ket qua
figure('Name', 'Ket qua mo phong he thong truyen luc', 'Color', 'w');

subplot(3,1,1);
plot(t, v, 'b-', 'LineWidth', 1.5); grid on;
ylabel('v (km/h)'); title('Van toc cua xe');

subplot(3,1,2);
plot(t, rpm, 'r-', 'LineWidth', 1.5); grid on;
ylabel('n (vong/phut)'); title('Vong tua dong co');

subplot(3,1,3);
plot(t, Te, 'k-', 'LineWidth', 1.5); grid on;
ylabel('T_e (Nm)'); xlabel('Thoi gian (s)'); title('Momen dong co');

%% 6. In ket luan nhanh
fprintf('>>> Van toc xe sau %.0f giay: %.1f km/h\n', T_stop, v(end));
fprintf('>>> Vong tua dong co luc do: %.0f vong/phut\n', rpm(end));
