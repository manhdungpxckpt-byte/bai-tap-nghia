%% thong_so_xe.m
% Thong so cua xe va he thong truyen luc (FWD - cau truoc chu dong)
% Chay file nay TRUOC khi mo phong de nap thong so vao Workspace.

clear; clc;

%% --- Dong co ---
Tmax  = 150;     % Momen cuc dai cua dong co [Nm]
wmax  = 733;     % Vong toc dong co gioi han [rad/s] (~7000 vong/phut)
u_ga  = 0.7;     % Do mo buom ga cua nguoi lai (0 -> 1)

%% --- He thong truyen luc ---
ig    = 2.0;     % Ty so truyen cua hop so (tay so dang gai)
i0    = 3.9;     % Ty so truyen cua truyen luc chinh (truoc vi sai)
eta_t = 0.92;    % Hieu suat co khi cua toan he truyen
Je    = 0.15;    % Momen quan tinh dong co + chi tiet quay [kg.m^2]

%% --- Banh xe va than xe ---
r     = 0.30;    % Ban kinh lan cua banh xe [m]
m_xe  = 1200;    % Khoi luong toan bo xe [kg]
g     = 9.81;    % Gia toc trong truong [m/s^2]
f0    = 0.013;   % He so can lan (lop - mat duong)
rho   = 1.225;   % Khoi luong rieng khong khi [kg/m^3]
Cd    = 0.32;    % He so can suat
Af    = 2.0;     % Dien tich can chinh dien [m^2]

%% --- Dieu kien mo phong ---
T_stop = 60;     % Thoi gian mo phong [s]
v0     = 0;      % Van toc ban dau cua xe [m/s]

%% --- Thong so quy doi (tu tinh - khong sua o day) ---
% Khoi luong hieu dung: gom ca quan tinh quay cua dong co quy ve xe
m_eff = m_xe + Je*(ig*i0/r)^2;   % [kg]

fprintf('>>> Da nap thong so xong. Khoi luong hieu dung m_eff = %.1f kg\n', m_eff);
