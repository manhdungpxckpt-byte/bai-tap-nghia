%% tao_mo_hinh_truyen_luc.m
% Tu dong dung so do Simulink: he thong truyen luc -> banh xe chu dong
%   Dong co -> Hop so -> Truyen luc chinh -> Banh xe chu dong -> Than xe
%
% Cach dung: chay thong_so_xe truoc (hoac script se tu goi).

if ~exist('Tmax', 'var')
    thong_so_xe;   % nap thong so neu workspace chua co
end

mdl = 'he_thong_truyen_luc';

% --- Neu model cu dang ton tai thi dong/xoa de dung lai tu dau ---
if bdIsLoaded(mdl)
    close_system(mdl, 0);
end
if exist([mdl '.slx'], 'file')
    delete([mdl '.slx']);
end

new_system(mdl);       % tao model moi
open_system(mdl);      % mo cua so model len

%% =============== CAC KHOI (BLOCKS) ===============

% --- Chan ga (throttle) cua nguoi lai ---
add_block('simulink/Sources/Constant', [mdl '/Ga'], ...
    'Value', 'u_ga', 'Position', [60 110 95 140]);

% --- Mux: gom 2 tin hieu (ga + toc do dong co) vao khoi momen ---
add_block('simulink/Signal Routing/Mux', [mdl '/Mux'], ...
    'Inputs', '2', 'Position', [125 105 135 145]);

% --- Phan hoi toc do dong co ve khoi momen (cau noi khong day) ---
add_block('simulink/Signal Routing/From', [mdl '/From_we'], ...
    'GotoTag', 'we', 'Position', [55 165 95 195]);

% --- Momen dong co: Te = u_ga * Tmax * (1 - we/wmax) ---
add_block('simulink/User-Defined Functions/Fcn', [mdl '/Te_Fcn'], ...
    'Expr', 'u(1)*Tmax*(1-u(2)/wmax)', 'Position', [170 108 275 142]);

% --- Khuech dai qua hop so + truyen luc chinh: ig * i0 * hieu suat ---
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
    'InitialCondition', 'v0', 'Position', [565 110 595 140]);

% --- Doi m/s -> km/h ---
add_block('simulink/Math Operations/Gain', [mdl '/kmh'], ...
    'Gain', '3.6', 'Position', [635 108 670 132]);

% --- Man hinh xem van toc + ghi ve workspace ---
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

% --- Gui we ve khoi momen (cau noi khong day) ---
add_block('simulink/Signal Routing/Goto', [mdl '/Goto_we'], ...
    'GotoTag', 'we', 'TagVisibility', 'local', 'Position', [730 205 770 235]);

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

%% =============== NOI DAY (LINES) ===============
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
add_line(mdl, 'Gain_we/1',    'Goto_we/1',  opt{:}); % gui we di xa
add_line(mdl, 'Gain_we/1',    'Gain_rpm/1', opt{:}); % -> doi rpm
add_line(mdl, 'Gain_rpm/1',   'ScopeRPM/1', opt{:});
add_line(mdl, 'Gain_rpm/1',   'WS_rpm/1',   opt{:});
add_line(mdl, 'Te_Fcn/1',     'WS_Te/1',    opt{:}); % ghi momen

%% =============== CAU HINH GIAI (SOLVER) ===============
set_param(mdl, 'Solver', 'ode45', ...   % giai tich phan so ode45
    'StopTime', 'T_stop', ...           % dung sau T_stop giay
    'MaxStep', '0.1');                  % buoc toi da 0.1 s cho muot

save_system(mdl);   % luu thanh he_thong_truyen_luc.slx
fprintf('>>> Da tao xong mo hinh "%s.slx". Chay tiep: mo_phong_truyen_luc\n', mdl);
