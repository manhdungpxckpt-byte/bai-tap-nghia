%% code_truyen_luc_banh_xe.m
% =====================================================================
%  MO PHONG HE THONG TRUYEN LUC DEN CAC BANH XE CHU DONG (cau truoc FWD)
%  Bang MATLAB + SIMULINK
%
%  So do truyen dong:  Dong co -> Hop so (ig) -> Truyen luc chinh (i0)
%                      -> Vi sai -> BANH XE CHU DONG -> Luc keo day xe
%
%  FILE ALL-IN-ONE: chi can DUY NHAT file nay, khong can file phu.
%  CACH DUNG: copy file vao thu muc lam viec cua MATLAB, go lenh:
%             >> code_truyen_luc_banh_xe
% =====================================================================

clear; clc; close all;

%% ================= BUOC 1: THONG SO XE & TRUYEN LUC ==================
% --- Dong co ---
Tmax  = 150;     % Momen cuc dai cua dong co [Nm]
wmax  = 733;     % Vong toc dong co gioi han [rad/s] (~7000 vong/phut)
u_ga  = 0.7;     % Do mo buom ga cua nguoi lai (0 -> 1)

% --- He thong truyen luc ---
ig    = 2.0;     % Ty so truyen hop so (tay so dang gai)
i0    = 3.9;     % Ty so truyen truyen luc chinh (truoc vi sai)
eta_t = 0.92;    % Hieu suat co khi toan he truyen
Je    = 0.15;    % Momen quan tinh dong co + chi tiet quay [kg.m^2]

% --- Banh xe va than xe ---
r     = 0.30;    % Ban kinh lan banh xe [m]
m_xe  = 1200;    % Khoi luong xe [kg]
g     = 9.81;    % Gia toc trong truong [m/s^2]
f0    = 0.013;   % He so can lan (lop - mat duong)
rho   = 1.225;   % Khoi luong rieng khong khi [kg/m^3]
Cd    = 0.32;    % He so can suat
Af    = 2.0;     % Dien tich can chinh dien [m^2]

% --- Dieu kien mo phong ---
T_stop = 60;     % Thoi gian mo phong [s]
v0     = 0;      % Van toc ban dau [m/s]

% --- Thong so quy doi (gom quan tinh quay cua dong co) ---
m_eff = m_xe + Je*(ig*i0/r)^2;   % [kg]
fprintf('>>> Khoi luong hieu dung m_eff = %.1f kg\n', m_eff);

%% ============ BUOC 2: TU DONG DUNG SO DO SIMULINK =====================
mdl = 'he_thong_truyen_luc';

% Neu model cu dang ton tai thi dong/xoa de dung lai tu dau
if bdIsLoaded(mdl)
    close_system(mdl, 0);
end
if exist([mdl '.slx'], 'file')
    delete([mdl '.slx']);
end

new_system(mdl);       % tao model moi
open_system(mdl);      % mo cua so model

% -------------------- CAC KHOI (BLOCKS) --------------------------------
% --- Chan ga (throttle) cua nguoi lai ---
add_block('simulink/Sources/Constant', [mdl '/Ga'], ...
    'Value', 'u_ga', 'Position', [60 110 95 140]);

% --- Mux: gom 2 tin hieu (ga + toc do dong co) vao khoi momen ---
add_block('simulink/Signal Routing/Mux', [mdl '/Mux'], ...
    'Inputs', '2', 'Position', [125 105 135 145]);

% --- Phan hoi toc do dong co (cau noi khong day) ---
add_block('simulink/Signal Routing/From', [mdl '/From_we'], ...
    'GotoTag', 'we', 'Position', [55 165 95 195]);

% --- Momen dong co: Te = u_ga * Tmax * (1 - we/wmax) ---
add_block('simulink/User-Defined Functions/Fcn', [mdl '/Te_Fcn'], ...
    'Expr', 'u(1)*Tmax*(1-u(2)/wmax)', 'Position', [170 108 275 142]);

% --- Khuech dai qua hop so + truyen luc chinh: ig*i0*hieu suat ---
add_block('simulink/Math Operations/Gain', [mdl '/Gain_ig'], ...
    'Gain', 'ig*i0*eta_t', 'Position', [315 110 355 140]);

% --- Chia ban kinh banh xe -> luc keo tai mat duong ---
add_block('simulink/Math Operations/Gain', [mdl '/Gain_1r'], ...
    'Gain', '1/r', 'Position', [385 110 420 140]);

% --- Tong hop luc: F_keo - F_can ---
add_block('simulink/Math Operations/Sum', [mdl '/Sum'], ...
    'Inputs', '+-', 'Position', [450 105 470 145]);

% --- Gia toc: a = F / m_eff ---
add_block('simulink/Math Operations/Gain', [mdl '/Gain_1m'], ...
    'Gain', '1/m_eff', 'Position', [500 110 535 140]);

% --- Tich phan gia toc -> van toc v [m/s] ---
add_block('simulink/Continuous/Integrator', [mdl '/Integrator'], ...
    'InitialCondition', num2str(v0), 'Position', [565 110 595 140]);

% --- Doi m/s -> km/h ---
add_block('simulink/Math Operations/Gain', [mdl '/kmh'], ...
    'Gain', '3.6', 'Position', [635 108 670 132]);

% --- Man hinh xem van toc + ghi du lieu ve workspace ---
add_block('simulink/Sinks/Scope', [mdl '/ScopeV'], ...
    'Position', [715 105 745 135]);
add_block('simulink/Sinks/To Workspace', [mdl '/WS_v'], ...
    'VariableName', 'v_kmh', 'SaveFormat', 'Structure With Time', ...
    'Position', [710 155 790 185]);

% --- Luc can: can lan + can gio (ham cua van toc v) ---
add_block('simulink/User-Defined Functions/Fcn', [mdl '/Fcan_Fcn'], ...
    'Expr', 'm_xe*g*f0+0.5*rho*Cd*Af*u^2', 'Position', [330 205 435 235]);

% --- Vong toc dong co tu van toc xe: we = v * (ig*i0/r) ---
add_block('simulink/Math Operations/Gain', [mdl '/Gain_we'], ...
    'Gain', 'ig*i0/r', 'Position', [620 205 690 235]);

% --- Gui we phan hoi ve khoi momen (cau noi khong day) ---
add_block('simulink/Signal Routing/Goto', [mdl '/Goto_we'], ...
    'GotoTag', 'we', 'TagVisibility', 'local', ...
    'Position', [730 205 770 235]);

% --- Doi rad/s -> vong/phut (rpm) ---
add_block('simulink/Math Operations/Gain', [mdl '/Gain_rpm'], ...
    'Gain', '60/(2*pi)', 'Position', [730 255 790 285]);

% --- Man hinh vong tua + ghi ve workspace ---
add_block('simulink/Sinks/Scope', [mdl '/ScopeRPM'], ...
    'Position', [835 250 865 280]);
add_block('simulink/Sinks/To Workspace', [mdl '/WS_rpm'], ...
    'VariableName', 'w_rpm', 'SaveFormat', 'Structure With Time', ...
    'Position', [830 295 905 325]);

% --- Ghi momen dong co ve workspace ---
add_block('simulink/Sinks/To Workspace', [mdl '/WS_Te'], ...
    'VariableName', 'Te_kq', 'SaveFormat', 'Structure With Time', ...
    'Position', [300 165 375 195]);

% -------------------- NOI DAY (LINES) ----------------------------------
opt = {'autorouting', 'on'};

add_line(mdl, 'Ga/1',         'Mux/1',    opt{:});   % ga -> mux
add_line(mdl, 'From_we/1',    'Mux/2',    opt{:});   % we phan hoi -> mux
add_line(mdl, 'Mux/1',        'Te_Fcn/1', opt{:});   % mux -> momen dong co
add_line(mdl, 'Te_Fcn/1',     'Gain_ig/1', opt{:});  % -> ty so truyen
add_line(mdl, 'Gain_ig/1',    'Gain_1r/1', opt{:});  % -> chia ban kinh
add_line(mdl, 'Gain_1r/1',    'Sum/1',    opt{:});   % F_keo -> tong (+)
add_line(mdl, 'Fcan_Fcn/1',   'Sum/2',    opt{:});   % F_can -> tong (-)
add_line(mdl, 'Sum/1',        'Gain_1m/1', opt{:});  % -> chia m_eff
add_line(mdl, 'Gain_1m/1',    'Integrator/1', opt{:});% -> tich phan
add_line(mdl, 'Integrator/1', 'kmh/1',    opt{:});   % v -> doi km/h
add_line(mdl, 'kmh/1',        'ScopeV/1', opt{:});
add_line(mdl, 'kmh/1',        'WS_v/1',   opt{:});
add_line(mdl, 'Integrator/1', 'Fcan_Fcn/1', opt{:}); % re nhanh v -> luc can
add_line(mdl, 'Integrator/1', 'Gain_we/1',  opt{:}); % re nhanh v -> we
add_line(mdl, 'Gain_we/1',    'Goto_we/1',  opt{:}); % gui we phan hoi
add_line(mdl, 'Gain_we/1',    'Gain_rpm/1', opt{:}); % -> doi rpm
add_line(mdl, 'Gain_rpm/1',   'ScopeRPM/1', opt{:});
add_line(mdl, 'Gain_rpm/1',   'WS_rpm/1',   opt{:});
add_line(mdl, 'Te_Fcn/1',     'WS_Te/1',    opt{:}); % ghi momen

% -------------------- CAU HINH GIAI (SOLVER) ---------------------------
set_param(mdl, 'Solver', 'ode45', ...      % bo giai tich phan so ode45
    'StopTime', num2str(T_stop), ...       % dung sau T_stop giay
    'MaxStep', '0.1');                     % buoc toi da 0.1 s cho muot

save_system(mdl);   % luu thanh he_thong_truyen_luc.slx
fprintf('>>> Da dung xong so do Simulink "%s.slx"\n', mdl);

%% ================= BUOC 3: CHAY MO PHONG ==============================
fprintf('>>> Dang chay mo phong %d giay...\n', T_stop);
sim(mdl);

%% ================= BUOC 4: VE KET QUA =================================
t   = v_kmh.time;                  % truc thoi gian [s]
v   = v_kmh.signals.values;        % van toc xe [km/h]
rpm = w_rpm.signals.values;        % vong tua dong co [vong/phut]
Te  = Te_kq.signals.values;        % momen dong co [Nm]

figure('Name', 'Mo phong he thong truyen luc', 'Color', 'w');

subplot(3,1,1);
plot(t, v, 'b-', 'LineWidth', 1.5); grid on;
ylabel('v (km/h)'); title('Van toc cua xe');

subplot(3,1,2);
plot(t, rpm, 'r-', 'LineWidth', 1.5); grid on;
ylabel('n (vong/phut)'); title('Vong tua dong co');

subplot(3,1,3);
plot(t, Te, 'k-', 'LineWidth', 1.5); grid on;
ylabel('T_e (Nm)'); xlabel('Thoi gian (s)'); title('Momen dong co');

%% ================= KET LUAN NHANH =====================================
fprintf('>>> XONG!\n');
fprintf('    Van toc xe sau %.0f giay : %.1f km/h\n', T_stop, v(end));
fprintf('    Vong tua dong co luc do  : %.0f vong/phut\n', rpm(end));
