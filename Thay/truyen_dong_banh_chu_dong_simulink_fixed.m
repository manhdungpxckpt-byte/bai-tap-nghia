%% =====================================================================
%  THIET KE - TINH TOAN TRUYEN DONG DEN CAC BANH XE CHU DONG (4x2, RWD)
%  Chuoi truyen luc: Dong co -> Ly hop -> Hop so -> Truc cac dang (dan hoi)
%  -> Truyen luc chinh + Vi sai -> Ban truc (dan hoi) -> Banh chu dong
%  -> Lop (mu-truot) -> Xe.
%  PHAN A (giai tich): ti so truyen chinh i0, ti so so 1 (leo doc / bam),
%     cap so nhan, truc cac dang (ben xoan, toc do toi han), ban truc,
%     vi sai (mu khac nhau), tan so rieng dao dong xoan.
%  PHAN B (Simulink, 11 bac tu do): tip-in, khoi hanh, mu khac nhau
%     (vi sai thuong / han che truot), vao cua.
%  Mac dinh: xe tai nhe 4x2 (so lieu tham khao theo Isuzu QKR 230) -
%  THAY THE bang so lieu xe cua ban (muc [KIEM TRA]).
%  Chay : >> truyen_dong_banh_chu_dong_simulink     (MATLAB R2019b+, Simulink)
%  Nhan : moi duong tin hieu trong so do va moi duong tren do thi co ten.
% =====================================================================
clear; clc; bdclose all;  g = 9.81;

%% 1. THAM SO
% --- Xe ---
P.M = 4990;  P.af = 1.79;  P.L = 2.75;  P.h = 1.0;   % [kg],[m]: khoi luong toan tai, CG-cau truoc, co so, cao CG [KIEM TRA]
P.rb = 0.36;  P.Tr = 1.7;                             % [m] ban kinh lan, vet banh                       [KIEM TRA]
P.Cr = 0.009;  P.CdA = 2.7;  P.rho = 1.2;             % can lan, Cd*A, khong khi                         [KIEM TRA]
P.Jw = 2.4;                                           % [kg m^2] quan tinh banh + lop moi ben            [KIEM TRA]
% --- Yeu cau thiet ke ---
P.vmax = 100/3.6;  P.n_v = 3200;                      % toc do toi da; vong tua dong co tai vmax         [KIEM TRA]
P.grade = 0.30;  P.mu_adh = 0.8;  P.eta_tr = 0.90;    % do doc toi da, he so bam, hieu suat truyen luc   [KIEM TRA]
% --- Dong co (4JH1E4NC: 80 kW @ 3200 rpm; duong cong xap xi) ---
n_bp    = [700 1000 1400 1800 2200 2600 3000 3200 3500 3800];
Tmax_bp = [170  195  235  250  250  248  243  239  215    0];   %                                  [KIEM TRA]
Tf0 = 18;  Tf1 = 0.006;  n_idle = 780;  Te_pk = max(Tmax_bp);
P.Je = 0.30;  P.Jgo = 0.05;  P.Jsd = 0.10;            % quan tinh dong co, hop so ra, banh rang ban truc [KIEM TRA]
% --- Truyen luc (chon theo catalogue) ---
P.i_gear = [5.380 3.022 1.724 1.000 0.790];  P.i0 = 4.875;            %                                 [KIEM TRA]
P.eta_g = 0.96;  P.eta_0 = 0.95;
% --- Truc cac dang / ban truc ---
P.Dp = 63.5e-3;  P.dp = 59.5e-3;  P.Lp = 1.2;         % [m] ong truc cac dang                            [KIEM TRA]
P.Lh = 0.55;                                          % [m] chieu dai ban truc                           [KIEM TRA]
tau_allow_p = 150e6;  tau_allow_h = 400e6;            % [Pa] ung suat xoan cho phep                      [KIEM TRA]
Es = 2.1e11;  Gs = 80e9;  rho_s = 7850;
% --- Ly hop, vi sai, lop ---
P.Tcap = 1.5*Te_pk;  P.eps = 8;                       % mo men ly hop toi da [Nm]; do mem tanh [rad/s]
P.kb = 50;  P.Tbmax_lsd = 250;                        % vi sai: he so (Nm/(rad/s)) va gioi han Tb [Nm]
P.vmin = 0.5;                                         % [m/s] van toc toi thieu khi tinh truot

%% 2. TINH TOAN THIET KE (giai tich)
G = P.M*g;  Gphi = G*P.af/P.L;  Te_max = Te_pk;  ng = numel(P.i_gear);
alpha = atan(P.grade);  psi_r = P.Cr*cos(alpha) + sin(alpha);
i0_d    = (P.n_v*pi/30*P.rb)/(P.vmax*P.i_gear(end));                 % i0 theo vmax
ih1_min = psi_r*G*P.rb/(Te_max*P.i0*P.eta_tr);                        % leo doc toi da
ih1_max = P.mu_adh*Gphi*P.rb/(Te_max*P.i0*P.eta_tr);                  % gioi han bam
ih_geo  = P.i_gear(1)*(P.i_gear(end)/P.i_gear(1)).^((0:ng-1)/(ng-1)); % cap so nhan
% Truc cac dang
Jp = pi*(P.Dp^4-P.dp^4)/32;  kp = Gs*Jp/P.Lp;  cp = 20;
Tp_des  = Te_max*P.i_gear(1)*P.eta_g;
tau_p   = 16*Tp_des*P.Dp/(pi*(P.Dp^4-P.dp^4));
ncr     = @(D,d,Lp) 7.5*pi*sqrt(Es/rho_s)*sqrt(D.^2+d.^2)./Lp.^2;   % [vg/ph]
n_shaft = max(n_bp(n_bp<=3500))/P.i_gear(end);                        % toc do truc cac dang lon nhat
% Ban truc
T_hs   = Te_max*P.i_gear(1)*P.i0*P.eta_tr/2;
dh_req = (16*T_hs/(pi*tau_allow_h))^(1/3);
P.dh   = ceil(dh_req*1e3)/1e3;                                        % chon tron len 1 mm
Jh = pi*P.dh^4/32;  kh = Gs*Jh/P.Lh;  ch = 30;
% Vi sai - luc keo toi da khi mu khac nhau
Nw = 0.5*Gphi;  mu_low = 0:0.02:P.mu_adh;
F_open = 2*mu_low*Nw;
F_lsd  = mu_low*Nw + min(P.mu_adh*Nw, mu_low*Nw + 2*P.Tbmax_lsd/P.rb);
F_eng1 = Te_max*P.i_gear(1)*P.i0*P.eta_tr/P.rb;
% Tan so rieng dao dong xoan (ly hop khoa): 3 khoi luong, quy ve truc mang vi sai
f1 = zeros(1,ng);
for k = 1:ng
    Ja = P.Je*(P.i_gear(k)*P.i0)^2 + P.Jgo*P.i0^2;  Jc = 2*P.Jsd;  Jb = 2*P.Jw + P.M*P.rb^2;
    k1 = kp*P.i0^2;  k2 = 2*kh;
    Kmat = [k1 -k1 0; -k1 k1+k2 -k2; 0 -k2 k2];
    ev = sort(real(eig(diag([Ja Jc Jb])\Kmat)));
    f1(k) = sqrt(max(ev(2),0))/(2*pi);
end
fprintf('=== KET QUA THIET KE (giai tich) ===\n');
fprintf('Ti so truyen chinh: i0 thiet ke theo vmax = %.3f | catalogue = %.3f\n', i0_d, P.i0);
fprintf('Ti so so 1: ih1_min (leo doc %.0f %%) = %.3f | ih1_max (bam, phi = %.2f) = %.3f | chon = %.3f\n', ...
    100*P.grade, ih1_min, P.mu_adh, ih1_max, P.i_gear(1));
if P.i_gear(1) < ih1_min, fprintf('  -> CANH BAO: ih1 chon nho hon ih1_min (khong leo duoc doc yeu cau)\n');
elseif P.i_gear(1) > ih1_max, fprintf('  -> CANH BAO: ih1 chon lon hon ih1_max (banh bi truot)\n');
else, fprintf('  -> ih1 chon nam trong khoang cho phep\n'); end
fprintf('Cap so nhan  : %s\nCatalogue    : %s\n', mat2str(ih_geo,4), mat2str(P.i_gear,4));
fprintf('Truc cac dang: T thiet ke = %.0f Nm | ung suat xoan = %.0f MPa (cho phep %.0f) | toc do toi han = %.0f vg/ph, lam viec max = %.0f vg/ph (he so %.2f)\n', ...
    Tp_des, tau_p/1e6, tau_allow_p/1e6, ncr(P.Dp,P.dp,P.Lp), n_shaft, ncr(P.Dp,P.dp,P.Lp)/n_shaft);
fprintf('Ban truc     : T thiet ke moi ben = %.0f Nm | duong kinh yeu cau %.1f mm -> chon %.0f mm | k = %.1f kNm/rad\n', ...
    T_hs, 1e3*dh_req, 1e3*P.dh, kh/1e3);
fprintf('Truc cac dang: k = %.1f kNm/rad\n', kp/1e3);
fprintf('Vi sai       : mu thap 0.2: thuong %.1f kN | han che truot %.1f kN | gioi han dong co so 1 = %.1f kN\n', ...
    interp1(mu_low,F_open,0.2)/1e3, interp1(mu_low,F_lsd,0.2)/1e3, F_eng1/1e3);
fprintf('Tan so rieng dao dong xoan (ly hop khoa), so 1..%d: %s Hz\n', ng, mat2str(f1,3));

%% 3. XAY DUNG SO DO SIMULINK (11 bac tu do)
mdl = 'truyen_dong_banh_chu_dong';
new_system(mdl); open_system(mdl);
FCN='simulink/User-Defined Functions/Fcn'; INT='simulink/Continuous/Integrator';
SUM='simulink/Math Operations/Sum';        GAIN='simulink/Math Operations/Gain';
MUX='simulink/Signal Routing/Mux';         SAT='simulink/Discontinuities/Saturation';
FW='simulink/Sources/From Workspace';      LK1='simulink/Lookup Tables/1-D Lookup Table';
TF='simulink/Continuous/Transfer Fcn';     BUS='simulink/Signal Routing/Bus Creator';
S = @(varargin) sprintf(varargin{:});

% --- Dau vao ---
ab(mdl,'Pedal_in',FW,0,0,'VariableName','ped_ts','Interpolate','on');
ab(mdl,'Clutch_in',FW,0,1,'VariableName','cl_ts','Interpolate','on');
ab(mdl,'Curv_in',FW,0,2,'VariableName','curv_ts','Interpolate','on');
ab(mdl,'MuL_in',FW,0,3,'VariableName','muL_ts','Interpolate','on');
ab(mdl,'MuR_in',FW,0,4,'VariableName','muR_ts','Interpolate','on');
% --- Dong co + ly hop ---
ab(mdl,'ne_rpm',GAIN,2,0,'Gain','30/pi');
ab(mdl,'Tmax_lk',LK1,3,0,'BreakpointsForDimension1','n_bp','Table','Tmax_bp');
ab(mdl,'Mux_Te',MUX,4,0,'Inputs','3');
ab(mdl,'Te_base',FCN,5,0,'Expr',S('u(1)*(u(2)+%g+%g*u(3))-(%g+%g*u(3))',Tf0,Tf1,Tf0,Tf1));
ab(mdl,'Te_gov',FCN,3,1,'Expr',S('(u(1)<%g)*2*(%g-u(1))',n_idle,n_idle));
ab(mdl,'Te_gov_sat',SAT,4,1,'UpperLimit',S('%g',Te_pk),'LowerLimit','0');
ab(mdl,'Te_eng',SUM,6,0,'Inputs','++');
ab(mdl,'Sum_we',SUM,7,0,'Inputs','+-');
ab(mdl,'Gain_Je',GAIN,8,0,'Gain',S('1/%g',P.Je));
ab(mdl,'Int_we',INT,9,0,'InitialCondition','80');
ab(mdl,'ig_w',GAIN,2,2,'Gain','1');
ab(mdl,'dw_cl',SUM,3,2,'Inputs','+-');
ab(mdl,'Mux_cl',MUX,4,2,'Inputs','2');
ab(mdl,'Tcl',FCN,5,2,'Expr',S('u(1)*%g*tanh(u(2)/%g)',P.Tcap,P.eps));
% --- Hop so ---
ab(mdl,'ig_eta',GAIN,6,2,'Gain','1');
ab(mdl,'Sum_wgo',SUM,7,2,'Inputs','+-');
ab(mdl,'Gain_Jgo',GAIN,8,2,'Gain',S('1/%g',P.Jgo));
ab(mdl,'Int_wgo',INT,9,2,'InitialCondition','0');
% --- Truc cac dang ---
ab(mdl,'Sum_wd',SUM,2,4,'Inputs','++');
ab(mdl,'w_pin',GAIN,3,4,'Gain',S('%g/2',P.i0));
ab(mdl,'dphi_p',SUM,4,4,'Inputs','+-');
ab(mdl,'Int_phip',INT,5,4,'InitialCondition','0');
ab(mdl,'k_p',GAIN,6,4,'Gain',S('%g',kp));
ab(mdl,'c_p',GAIN,6,5,'Gain',S('%g',cp));
ab(mdl,'Tp_sum',SUM,7,4,'Inputs','++');
ab(mdl,'Tc',GAIN,8,4,'Gain',S('%g',P.i0*P.eta_0));
ab(mdl,'Tc_half',GAIN,9,4,'Gain','0.5');
% --- Vi sai ---
ab(mdl,'dw_diff',SUM,2,6,'Inputs','+-');
ab(mdl,'kb',GAIN,3,6,'Gain',S('%g',P.kb));
ab(mdl,'Tb_sat',SAT,4,6,'UpperLimit','1e-9','LowerLimit','-1e-9');
ab(mdl,'T_dL',SUM,5,6,'Inputs','+-');
ab(mdl,'T_dR',SUM,5,7,'Inputs','++');
% --- Ban truc, banh, lop (trai / phai) ---
sides = {'L','R'};  rowS = [9 17];  Tin = {'T_dL','T_dR'};  muIn = {'MuL_in','MuR_in'};
vsign = {'-','+'};
for q = 1:2
    s = sides{q};  r = rowS(q);
    ab(mdl,['dphi_' s],SUM,2,r,'Inputs','+-');
    ab(mdl,['Int_phi' s],INT,3,r,'InitialCondition','0');
    ab(mdl,['k_h' s],GAIN,4,r,'Gain',S('%g',kh));
    ab(mdl,['c_h' s],GAIN,4,r+1,'Gain',S('%g',ch));
    ab(mdl,['Th_' s],SUM,5,r,'Inputs','++');
    ab(mdl,['Sum_wd' s],SUM,6,r,'Inputs','+-');
    ab(mdl,['Gain_Jsd' s],GAIN,7,r,'Gain',S('1/%g',P.Jsd));
    ab(mdl,['Int_wd' s],INT,8,r,'InitialCondition','0');
    ab(mdl,['Mux_v' s],MUX,2,r+3,'Inputs','2');
    ab(mdl,['v' s],FCN,3,r+3,'Expr',S('u(1)*(1%s0.5*%g*u(2))',vsign{q},P.Tr));
    ab(mdl,['Mux_k' s],MUX,4,r+3,'Inputs','2');
    ab(mdl,['kap' s],FCN,5,r+3,'Expr',S('(u(1)*%g-u(2))/((u(2)>%g)*u(2)+(u(2)<=%g)*%g)',P.rb,P.vmin,P.vmin,P.vmin));
    ab(mdl,['Mux_F' s],MUX,6,r+3,'Inputs','3');
    ab(mdl,['Fx' s],FCN,7,r+3,'Expr','(u(2)*u(3))*sin(1.6*atan(10*u(1)))');
    ab(mdl,['Fxr' s],GAIN,8,r+3,'Gain',S('%g',P.rb));
    ab(mdl,['Mux_m' s],MUX,6,r+4,'Inputs','2');
    ab(mdl,['Mroll_' s],FCN,7,r+4,'Expr',S('%g*u(1)*%g*tanh(u(2))',P.Cr,P.rb));
    ab(mdl,['Sum_ww' s],SUM,9,r+3,'Inputs','+--');
    ab(mdl,['Gain_Jw' s],GAIN,10,r+3,'Gain',S('1/%g',P.Jw));
    ab(mdl,['Int_ww' s],INT,11,r+3,'InitialCondition','0');
end
% --- Xe ---
ab(mdl,'Fres',FCN,2,26,'Expr',S('%g*%g*%g*(1-%g/%g)*(u(1)>0.05)+0.5*%g*%g*u(1)*u(1)', ...
    P.Cr,P.M,g,P.af,P.L,P.rho,P.CdA));
ab(mdl,'Sum_F',SUM,3,26,'Inputs','++-');
ab(mdl,'Gain_M',GAIN,4,26,'Gain',S('1/%g',P.M));
ab(mdl,'Int_v',INT,5,26,'InitialCondition','0');
ab(mdl,'a_lpf',TF,6,26,'Numerator','[1]','Denominator','[0.05 1]');
ab(mdl,'N_calc',FCN,7,26,'Expr',S('0.5*(%g*%g*%g/%g+%g*%g/%g*u(1))',P.M,g,P.af,P.L,P.M,P.h,P.L));
ab(mdl,'N_w',SAT,8,26,'UpperLimit','1e6','LowerLimit','0');
% --- Ghi du lieu va Scope ---
ab(mdl,'Mux_log',MUX,12,12,'Inputs','21');
ab(mdl,'Logs','simulink/Sinks/To Workspace',13,12,'VariableName','logs', ...
   'SaveFormat','Structure With Time','Decimation','2');
ab(mdl,'Bus_s1',BUS,12,2,'Inputs','2');
ab(mdl,'Bus_s2',BUS,12,4,'Inputs','3');
ab(mdl,'Bus_s3',BUS,12,6,'Inputs','2');
ab(mdl,'Scope','simulink/Sinks/Scope',13,4,'NumInputPorts','3');

L = @(a,b) add_line(mdl,a,b,'autorouting','on');
% Dong co + ly hop
L('Int_we/1','ne_rpm/1'); L('ne_rpm/1','Tmax_lk/1');
L('Pedal_in/1','Mux_Te/1'); L('Tmax_lk/1','Mux_Te/2'); L('ne_rpm/1','Mux_Te/3');
L('Mux_Te/1','Te_base/1'); L('ne_rpm/1','Te_gov/1'); L('Te_gov/1','Te_gov_sat/1');
L('Te_base/1','Te_eng/1'); L('Te_gov_sat/1','Te_eng/2');
L('Int_wgo/1','ig_w/1'); L('Int_we/1','dw_cl/1'); L('ig_w/1','dw_cl/2');
L('Clutch_in/1','Mux_cl/1'); L('dw_cl/1','Mux_cl/2'); L('Mux_cl/1','Tcl/1');
L('Te_eng/1','Sum_we/1'); L('Tcl/1','Sum_we/2'); L('Sum_we/1','Gain_Je/1'); L('Gain_Je/1','Int_we/1');
% Hop so
L('Tcl/1','ig_eta/1'); L('ig_eta/1','Sum_wgo/1'); L('Tp_sum/1','Sum_wgo/2');
L('Sum_wgo/1','Gain_Jgo/1'); L('Gain_Jgo/1','Int_wgo/1');
% Truc cac dang
L('Int_wdL/1','Sum_wd/1'); L('Int_wdR/1','Sum_wd/2'); L('Sum_wd/1','w_pin/1');
L('Int_wgo/1','dphi_p/1'); L('w_pin/1','dphi_p/2'); L('dphi_p/1','Int_phip/1');
L('Int_phip/1','k_p/1'); L('dphi_p/1','c_p/1'); L('k_p/1','Tp_sum/1'); L('c_p/1','Tp_sum/2');
L('Tp_sum/1','Tc/1'); L('Tc/1','Tc_half/1');
% Vi sai
L('Int_wdL/1','dw_diff/1'); L('Int_wdR/1','dw_diff/2'); L('dw_diff/1','kb/1'); L('kb/1','Tb_sat/1');
L('Tc_half/1','T_dL/1'); L('Tb_sat/1','T_dL/2'); L('Tc_half/1','T_dR/1'); L('Tb_sat/1','T_dR/2');
% Ban truc, banh, lop
for q = 1:2
    s = sides{q};
    L(['Int_wd' s '/1'],['dphi_' s '/1']); L(['Int_ww' s '/1'],['dphi_' s '/2']);
    L(['dphi_' s '/1'],['Int_phi' s '/1']); L(['Int_phi' s '/1'],['k_h' s '/1']);
    L(['dphi_' s '/1'],['c_h' s '/1']);
    L(['k_h' s '/1'],['Th_' s '/1']); L(['c_h' s '/1'],['Th_' s '/2']);
    L([Tin{q} '/1'],['Sum_wd' s '/1']); L(['Th_' s '/1'],['Sum_wd' s '/2']);
    L(['Sum_wd' s '/1'],['Gain_Jsd' s '/1']); L(['Gain_Jsd' s '/1'],['Int_wd' s '/1']);
    L('Int_v/1',['Mux_v' s '/1']); L('Curv_in/1',['Mux_v' s '/2']); L(['Mux_v' s '/1'],['v' s '/1']);
    L(['Int_ww' s '/1'],['Mux_k' s '/1']); L(['v' s '/1'],['Mux_k' s '/2']); L(['Mux_k' s '/1'],['kap' s '/1']);
    L(['kap' s '/1'],['Mux_F' s '/1']); L('N_w/1',['Mux_F' s '/2']); L([muIn{q} '/1'],['Mux_F' s '/3']);
    L(['Mux_F' s '/1'],['Fx' s '/1']);
    L('N_w/1',['Mux_m' s '/1']); L(['Int_ww' s '/1'],['Mux_m' s '/2']); L(['Mux_m' s '/1'],['Mroll_' s '/1']);
    L(['Fx' s '/1'],['Fxr' s '/1']);
    L(['Th_' s '/1'],['Sum_ww' s '/1']); L(['Fxr' s '/1'],['Sum_ww' s '/2']); L(['Mroll_' s '/1'],['Sum_ww' s '/3']);
    L(['Sum_ww' s '/1'],['Gain_Jw' s '/1']); L(['Gain_Jw' s '/1'],['Int_ww' s '/1']);
end
% Xe
L('Int_v/1','Fres/1'); L('FxL/1','Sum_F/1'); L('FxR/1','Sum_F/2'); L('Fres/1','Sum_F/3');
L('Sum_F/1','Gain_M/1'); L('Gain_M/1','Int_v/1'); L('Gain_M/1','a_lpf/1');
L('a_lpf/1','N_calc/1'); L('N_calc/1','N_w/1');
% Scope
L('Int_wwL/1','Bus_s1/1'); L('Int_wwR/1','Bus_s1/2');
L('Tp_sum/1','Bus_s2/1'); L('Th_L/1','Bus_s2/2'); L('Th_R/1','Bus_s2/3');
L('FxL/1','Bus_s3/1'); L('FxR/1','Bus_s3/2');
L('Bus_s1/1','Scope/1'); L('Bus_s2/1','Scope/2'); L('Bus_s3/1','Scope/3');
% Kenh ghi 'logs' (21 cot)
srcs = {'Int_v','Int_we','Int_wgo','Int_wwL','Int_wwR','Te_eng','Tcl','Tp_sum','Th_L','Th_R', ...
        'kapL','kapR','FxL','FxR','Gain_M','Int_wdL','Int_wdR','Tb_sat','vL','vR','N_w'};
for k = 1:numel(srcs), L([srcs{k} '/1'], sprintf('Mux_log/%d',k)); end
L('Mux_log/1','Logs/1');
logNames = {'v_xe [m/s]','omega_dong_co [rad/s]','omega_hop_so_ra [rad/s]','omega_banh_trai [rad/s]', ...
    'omega_banh_phai [rad/s]','Te_dong_co [Nm]','Tcl_ly_hop [Nm]','Tp_truc_cac_dang [Nm]', ...
    'Th_ban_truc_trai [Nm]','Th_ban_truc_phai [Nm]','truot_banh_trai [-]','truot_banh_phai [-]', ...
    'Fx_banh_trai [N]','Fx_banh_phai [N]','a_xe [m/s^2]','omega_banh_rang_trai [rad/s]', ...
    'omega_banh_rang_phai [rad/s]','Tb_vi_sai [Nm]','v_mat_dat_trai [m/s]','v_mat_dat_phai [m/s]', ...
    'N_moi_banh [N]'};
% --- Dat ten cac duong tin hieu ---
sigNames = {'Int_v','v_xe'; 'Int_we','omega_dong_co'; 'Int_wgo','omega_hop_so_ra'; ...
    'Int_wwL','omega_banh_trai'; 'Int_wwR','omega_banh_phai'; 'Te_eng','Te_dong_co'; ...
    'Tcl','Tcl_ly_hop'; 'Tp_sum','Tp_truc_cac_dang'; 'Th_L','Th_ban_truc_trai'; ...
    'Th_R','Th_ban_truc_phai'; 'kapL','truot_banh_trai'; 'kapR','truot_banh_phai'; ...
    'FxL','Fx_banh_trai'; 'FxR','Fx_banh_phai'; 'Gain_M','a_xe'; ...
    'Int_wdL','omega_banh_rang_trai'; 'Int_wdR','omega_banh_rang_phai'; 'Tb_sat','Tb_vi_sai'; ...
    'vL','v_mat_dat_trai'; 'vR','v_mat_dat_phai'; 'N_w','N_moi_banh'; 'Tc','Tc_can_vi_sai'; ...
    'Int_phip','xoan_truc_cac_dang'};
for k = 1:size(sigNames,1), nameSig(mdl,sigNames{k,1},sigNames{k,2}); end
try
    sc = get_param([mdl '/Scope'],'ScopeConfiguration');
    scT = {'Van toc goc banh chu dong','Mo men truc cac dang va ban truc','Luc keo tiep tuyen moi banh'};
    scY = {'omega [rad/s]','T [Nm]','Fx [N]'};
    for k = 1:3
        sc.ActiveDisplay = k;  sc.Title = scT{k};  sc.YLabel = scY{k};
        sc.ShowLegend = true;  sc.ShowGrid = true;
    end
    sc.ActiveDisplay = 1;
catch ME
    warning('Khong cai duoc nhan cho Scope (%s). Bat Legend thu cong trong Scope.', ME.message);
end
set_param(mdl,'Solver','ode4','FixedStep','5e-5');   % buoc nho de on dinh khi ly hop khoa so 1
save_system(mdl);

%% 4. CAC KICH BAN MO PHONG
ramp = @(t,t0,t1) min(max((t-t0)/(t1-t0),0),1);
SCN(1) = struct('name','Tip-in (kiem chung tan so rieng)','ig',3,'v0',8,'locked',true,'T',4, ...
    'ped',@(t) 0.5+0.3*(t>0.5),'cl',@(t) ones(size(t)),'curv',0,'muL',0.8,'muR',0.8,'Tbmax',0);
SCN(2) = struct('name','Khoi hanh, mu cao (0.8)','ig',1,'v0',0,'locked',false,'T',3.5, ...
    'ped',@(t) 0.4+0.6*ramp(t,0,2),'cl',@(t) ramp(t,0.3,1.3),'curv',0,'muL',0.8,'muR',0.8,'Tbmax',0);
SCN(3) = struct('name','Mu khac nhau (0.2/0.8), vi sai thuong','ig',1,'v0',0,'locked',false,'T',3.5, ...
    'ped',@(t) 0.4+0.6*ramp(t,0,2),'cl',@(t) ramp(t,0.3,1.3),'curv',0,'muL',0.2,'muR',0.8,'Tbmax',0);
SCN(4) = struct('name','Mu khac nhau (0.2/0.8), vi sai han che truot','ig',1,'v0',0,'locked',false,'T',3.5, ...
    'ped',@(t) 0.4+0.6*ramp(t,0,2),'cl',@(t) ramp(t,0.3,1.3),'curv',0,'muL',0.2,'muR',0.8,'Tbmax',P.Tbmax_lsd);
SCN(5) = struct('name','Vao cua R = 15 m','ig',2,'v0',0,'locked',false,'T',6, ...
    'ped',@(t) 0.3+0.5*ramp(t,0,2),'cl',@(t) ramp(t,0.3,1.3),'curv',1/15,'muL',0.8,'muR',0.8,'Tbmax',0);
for k = 1:numel(SCN)
    s = SCN(k);  tt = (0:0.01:s.T)';
    ped_ts  = timeseries(s.ped(tt),tt);          %#ok<NASGU>
    cl_ts   = timeseries(s.cl(tt),tt);           %#ok<NASGU>
    curv_ts = timeseries(s.curv*ones(size(tt)),tt);  %#ok<NASGU>
    muL_ts  = timeseries(s.muL*ones(size(tt)),tt);   %#ok<NASGU>
    muR_ts  = timeseries(s.muR*ones(size(tt)),tt);   %#ok<NASGU>
    apply_scn(mdl,P,s);
    set_param(mdl,'StopTime',num2str(s.T));
    so = sim(mdl,'ReturnWorkspaceOutputs','on');
    lg = so.get('logs');
    R(k).t = lg.time;  R(k).Y = lg.signals.values;  R(k).name = s.name;      %#ok<SAGROW>
end

%% 5. CHI SO VA KIEM CHUNG
fprintf('\n=== KET QUA MO PHONG ===\n');
Tp_des_k = @(ig) Te_max*ig*P.eta_g;
for k = 2:4
    Y = R(k).Y;  t = R(k).t;
    fprintf('%-52s: Tp max = %.0f Nm (he so tai trong dong %.2f) | Th max = %.0f / %.0f Nm | v(%.1f s) = %.1f km/h\n', ...
        R(k).name, max(Y(:,8)), max(Y(:,8))/Tp_des_k(P.i_gear(1)), max(Y(:,9)), max(Y(:,10)), t(end), 3.6*Y(end,1));
end
w = R(3).t>1.5;  a_open = mean(R(3).Y(w,15));  a_lsd = mean(R(4).Y(R(4).t>1.5,15));
fprintf('Mu khac nhau: gia toc TB (t > 1.5 s): vi sai thuong %.2f m/s^2 | han che truot %.2f m/s^2 (tang %.0f %%)\n', ...
    a_open, a_lsd, 100*(a_lsd/a_open-1));
% Kiem chung tan so rieng (tip-in)
t1 = R(1).t;  Tp1 = R(1).Y(:,8);  idx = t1 > 0.6;  sig = detrend(Tp1(idx));
n = numel(sig);  win = 0.5-0.5*cos(2*pi*(0:n-1)'/(n-1));
dt = mean(diff(t1));  Nf = 2^17;  Sp = abs(fft(sig.*win,Nf));  fr = (0:Nf-1)'/(Nf*dt);
band = fr>0.8 & fr<15;  [~,ip] = max(Sp(band));  fb = fr(band);  f_sim = fb(ip);
f_an = f1(SCN(1).ig);
fprintf('Tan so rieng dao dong xoan (so %d): mo phong %.2f Hz | giai tich %.2f Hz | sai lech %.1f %% -> do chinh xac %.1f %%\n', ...
    SCN(1).ig, f_sim, f_an, 100*abs(f_sim-f_an)/f_an, 100*(1-abs(f_sim-f_an)/f_an));
% Kiem chung vi sai khi vao cua
Y5 = R(5).Y;  t5 = R(5).t;  m5 = t5 > 3;
ratio_sim = mean(Y5(m5,5)./Y5(m5,4));
ratio_an  = (1+0.5*P.Tr/15)/(1-0.5*P.Tr/15);
fprintf('Vao cua R = 15 m: omega_phai/omega_trai mo phong %.4f | giai tich (Ackermann) %.4f | do chinh xac %.1f %%\n', ...
    ratio_sim, ratio_an, 100*(1-abs(ratio_sim-ratio_an)/ratio_an));
w_c = mean(0.5*(Y5(m5,16)+Y5(m5,17)));  w_wm = mean(0.5*(Y5(m5,4)+Y5(m5,5)));
fprintf('Vao cua: omega can vi sai = trung binh 2 ban truc (sai lech %.2e rad/s)\n', abs(w_c - w_wm));
fprintf('\nCac kenh trong logs.signals.values:\n');
for k = 1:numel(logNames), fprintf('  cot %2d: %s\n',k,logNames{k}); end

%% 6. DO THI (moi duong deu co ten trong chu giai)
cols = lines(ng);
% 6.1 Dac tinh keo
figure('Name','1 - Dac tinh keo va cac gioi han'); hold on;
nn = linspace(n_idle,3500,200);  Tm = interp1(n_bp,Tmax_bp,nn);
for k = 1:ng
    it = P.i_gear(k)*P.i0;  vk = nn*pi/30*P.rb/it*3.6;  Fk = Tm*it*P.eta_tr/P.rb;
    plot(vk,Fk/1e3,'Color',cols(k,:),'LineWidth',1.5,'DisplayName',sprintf('Luc keo so %d',k));
    text(vk(end),Fk(end)/1e3,sprintf(' so %d',k),'Color',cols(k,:));
end
vv = linspace(0,110,111)/3.6;
Fr0 = P.M*g*P.Cr + 0.5*P.rho*P.CdA*vv.^2;
Frg = P.M*g*psi_r + 0.5*P.rho*P.CdA*vv.^2;
plot(vv*3.6,Fr0/1e3,'k-','LineWidth',1.1,'DisplayName','Luc can, mat phang');
plot(vv*3.6,Frg/1e3,'k--','LineWidth',1.1,'DisplayName',sprintf('Luc can, doc %.0f %%',100*P.grade));
yline(P.mu_adh*Gphi/1e3,':',sprintf('Luc bam phi*G_phi (phi = %.1f)',P.mu_adh),'LineWidth',1.3, ...
    'DisplayName',sprintf('Luc bam phi*G_phi (phi = %.1f)',P.mu_adh));
grid on; xlabel('Toc do [km/h]'); ylabel('Luc [kN]'); title('Dac tinh keo theo so, luc can va gioi han bam');
legend('show','Location','northeast');
% 6.2 Ti so truyen
figure('Name','2 - Chon ti so truyen');
subplot(2,1,1); hold on;
phi_g = 0.2:0.02:1;
plot(phi_g,phi_g*Gphi*P.rb/(Te_max*P.i0*P.eta_tr),'LineWidth',1.5,'DisplayName','ih1 max (gioi han bam)');
yline(ih1_min,'--',sprintf('ih1 min (leo doc %.0f %%)',100*P.grade),'DisplayName',sprintf('ih1 min (leo doc %.0f %%)',100*P.grade));
yline(P.i_gear(1),'-.',sprintf('ih1 chon = %.2f',P.i_gear(1)),'DisplayName',sprintf('ih1 chon = %.2f',P.i_gear(1)));
xline(P.mu_adh,':','phi thiet ke','DisplayName','phi thiet ke');
grid on; xlabel('He so bam phi [-]'); ylabel('ih1 [-]'); title('Khoang cho phep cua ti so truyen so 1'); legend('show','Location','best');
subplot(2,1,2);
plot(1:ng,ih_geo,'-o','LineWidth',1.4,'DisplayName','Cap so nhan (ly thuyet)'); hold on;
plot(1:ng,P.i_gear,'-s','LineWidth',1.4,'DisplayName','Ti so hop so catalogue');
grid on; xlabel('So'); ylabel('Ti so hop so [-]'); title('Ti so tung so'); legend('show','Location','northeast');
% 6.3 Truc cac dang va ban truc
figure('Name','3 - Truc cac dang va ban truc');
subplot(2,1,1); hold on;
Lg = linspace(0.8,1.8,100);
for Dd = [55 63.5 70 76]*1e-3
    plot(Lg,ncr(Dd,Dd-4e-3,Lg),'LineWidth',1.4,'DisplayName',sprintf('n toi han, D = %.1f mm (day 2 mm)',1e3*Dd));
end
yline(1.2*n_shaft,'--','1.2 x toc do lam viec max','DisplayName','1.2 x toc do lam viec max');
xline(P.Lp,':',sprintf('L chon = %.2f m',P.Lp),'DisplayName',sprintf('L chon = %.2f m',P.Lp));
grid on; xlabel('Chieu dai truc L [m]'); ylabel('n toi han [vg/ph]'); title('Toc do toi han cua truc cac dang'); legend('show','Location','best');
subplot(2,1,2);
tau_g = (100:25:600)*1e6;
plot(tau_g/1e6,1e3*(16*T_hs./(pi*tau_g)).^(1/3),'LineWidth',1.5,'DisplayName','d yeu cau theo ung suat cho phep'); hold on;
yline(1e3*P.dh,'--',sprintf('d chon = %.0f mm',1e3*P.dh),'DisplayName',sprintf('d chon = %.0f mm',1e3*P.dh));
xline(tau_allow_h/1e6,':',sprintf('[tau] chon = %.0f MPa',tau_allow_h/1e6),'DisplayName',sprintf('[tau] chon = %.0f MPa',tau_allow_h/1e6));
grid on; xlabel('Ung suat xoan cho phep [MPa]'); ylabel('Duong kinh ban truc [mm]'); title('Duong kinh ban truc'); legend('show','Location','best');
% 6.4 Vi sai khi mu khac nhau
figure('Name','4 - Vi sai: mu khac nhau'); hold on;
plot(mu_low,F_open/1e3,'LineWidth',1.5,'DisplayName','Vi sai thuong: 2*mu_thap*N');
plot(mu_low,F_lsd/1e3,'LineWidth',1.5,'DisplayName',sprintf('Vi sai han che truot (Tb max = %d Nm)',P.Tbmax_lsd));
plot(mu_low,2*P.mu_adh*Nw*ones(size(mu_low))/1e3,'k--','LineWidth',1.1,'DisplayName','Mu cao ca 2 ben: 2*mu_cao*N');
yline(F_eng1/1e3,':','Gioi han dong co (so 1)','LineWidth',1.3,'DisplayName','Gioi han dong co (so 1)');
grid on; xlabel('He so bam ben mu thap [-]'); ylabel('Luc keo toi da [kN]'); title('Luc keo toi da khi mu khac nhau (mu cao = 0.8)');
legend('show','Location','southeast');
% 6.5 Tip-in
figure('Name','5 - Tip-in: dao dong xoan');
Y = R(1).Y;  t = R(1).t;
subplot(4,1,1); plot(t,3.6*Y(:,1),'LineWidth',1.3,'DisplayName','v xe'); grid on;
ylabel('v [km/h]'); title(sprintf('Tip-in tai so %d (ly hop khoa)',SCN(1).ig)); legend('show','Location','best');
subplot(4,1,2); plot(t,Y(:,2),'LineWidth',1.2,'DisplayName','omega dong co'); hold on;
plot(t,Y(:,4),'LineWidth',1.2,'DisplayName','omega banh trai'); plot(t,Y(:,5),'--','LineWidth',1.2,'DisplayName','omega banh phai');
grid on; ylabel('omega [rad/s]'); legend('show','Location','best');
subplot(4,1,3); plot(t,Y(:,8),'LineWidth',1.3,'DisplayName','Tp truc cac dang'); hold on;
plot(t,Y(:,9),'LineWidth',1.2,'DisplayName','Th ban truc trai'); plot(t,Y(:,10),'--','LineWidth',1.2,'DisplayName','Th ban truc phai');
grid on; ylabel('T [Nm]'); legend('show','Location','best');
subplot(4,1,4); plot(fr(fr<15),Sp(fr<15)/max(Sp(band)),'LineWidth',1.3,'DisplayName','Pho cua Tp (chuan hoa)'); hold on;
xline(f_an,'--',sprintf('Giai tich %.2f Hz',f_an),'DisplayName',sprintf('Tan so rieng giai tich %.2f Hz',f_an));
xline(f_sim,':',sprintf('Mo phong %.2f Hz',f_sim),'DisplayName',sprintf('Tan so mo phong %.2f Hz',f_sim));
grid on; xlabel('Tan so [Hz]'); ylabel('|FFT| [-]'); legend('show','Location','best');
% 6.6 Khoi hanh mu cao
figure('Name','6 - Khoi hanh, mu cao');
Y = R(2).Y;  t = R(2).t;
subplot(4,1,1); plot(t,3.6*Y(:,1),'LineWidth',1.3,'DisplayName','v xe'); grid on; ylabel('v [km/h]');
title('Khoi hanh so 1, mu 0.8'); legend('show','Location','best');
subplot(4,1,2); plot(t,Y(:,2),'LineWidth',1.2,'DisplayName','omega dong co'); hold on;
plot(t,P.i_gear(1)*Y(:,3),'--','LineWidth',1.2,'DisplayName','i_h1 * omega hop so ra'); plot(t,Y(:,4),'LineWidth',1.2,'DisplayName','omega banh trai');
grid on; ylabel('omega [rad/s]'); legend('show','Location','best');
subplot(4,1,3); plot(t,Y(:,6),'LineWidth',1.2,'DisplayName','Te dong co'); hold on;
plot(t,Y(:,7),'LineWidth',1.2,'DisplayName','Tcl ly hop'); plot(t,Y(:,8),'LineWidth',1.2,'DisplayName','Tp truc cac dang');
plot(t,Y(:,9),'--','LineWidth',1.2,'DisplayName','Th ban truc trai');
grid on; ylabel('T [Nm]'); legend('show','Location','best');
subplot(4,1,4); plot(t,Y(:,11),'LineWidth',1.2,'DisplayName','truot banh trai'); hold on;
plot(t,Y(:,12),'--','LineWidth',1.2,'DisplayName','truot banh phai'); plot(t,Y(:,15),'LineWidth',1.2,'DisplayName','gia toc a_x [m/s^2]');
grid on; xlabel('Thoi gian [s]'); ylabel('truot [-], a [m/s^2]'); legend('show','Location','best');
% 6.7 Mu khac nhau
figure('Name','7 - Mu khac nhau: vi sai thuong va han che truot');
subplot(3,1,1); hold on;
for k = 3:4, plot(R(k).t,3.6*R(k).Y(:,1),'LineWidth',1.4,'DisplayName',['v xe: ' R(k).name]); end
grid on; ylabel('v [km/h]'); title('Khoi hanh tren mat duong mu 0.2 (trai) / 0.8 (phai)'); legend('show','Location','best');
subplot(3,1,2); hold on;
plot(R(3).t,R(3).Y(:,13)/1e3,'LineWidth',1.3,'DisplayName','Fx trai, vi sai thuong'); plot(R(3).t,R(3).Y(:,14)/1e3,'--','LineWidth',1.3,'DisplayName','Fx phai, vi sai thuong');
plot(R(4).t,R(4).Y(:,13)/1e3,'LineWidth',1.3,'DisplayName','Fx trai, han che truot'); plot(R(4).t,R(4).Y(:,14)/1e3,'--','LineWidth',1.3,'DisplayName','Fx phai, han che truot');
grid on; ylabel('Fx [kN]'); legend('show','Location','best');
subplot(3,1,3); hold on;
plot(R(3).t,R(3).Y(:,4),'LineWidth',1.3,'DisplayName','omega banh trai, vi sai thuong'); plot(R(3).t,R(3).Y(:,5),'--','LineWidth',1.3,'DisplayName','omega banh phai, vi sai thuong');
plot(R(4).t,R(4).Y(:,4),'LineWidth',1.3,'DisplayName','omega banh trai, han che truot'); plot(R(4).t,R(4).Y(:,5),'--','LineWidth',1.3,'DisplayName','omega banh phai, han che truot');
grid on; xlabel('Thoi gian [s]'); ylabel('omega [rad/s]'); legend('show','Location','best');
% 6.8 Vao cua
figure('Name','8 - Vao cua: phan toc o vi sai');
Y = R(5).Y;  t = R(5).t;
subplot(2,1,1);
plot(t,Y(:,4),'LineWidth',1.3,'DisplayName','omega banh trai (trong)'); hold on;
plot(t,Y(:,5),'LineWidth',1.3,'DisplayName','omega banh phai (ngoai)');
plot(t,0.5*(Y(:,16)+Y(:,17)),'k--','LineWidth',1.1,'DisplayName','omega can vi sai = TB 2 ban truc');
grid on; ylabel('omega [rad/s]'); title('Vao cua R = 15 m, so 2'); legend('show','Location','best');
subplot(2,1,2);
plot(t(t>1),Y(t>1,5)./Y(t>1,4),'LineWidth',1.3,'DisplayName','omega_phai / omega_trai (mo phong)'); hold on;
yline(ratio_an,'--',sprintf('Giai tich %.4f',ratio_an),'DisplayName',sprintf('Giai tich (1+T/2R)/(1-T/2R) = %.4f',ratio_an));
grid on; xlabel('Thoi gian [s]'); ylabel('Ti so [-]'); title(sprintf('Do chinh xac %.1f %%',100*(1-abs(ratio_sim-ratio_an)/ratio_an)));
legend('show','Location','best');

%% 7. SO VOI DU LIEU DO THUC NGHIEM (>= 95%)
%  Dat file dang_meas.mat: M.t [s], M.v [m/s], M.Tp [Nm], M.we [rad/s] do khi khoi hanh (so 1, mu cao)
%  voi cung kich thich ga/ly hop (ped_ts, cl_ts cua kich ban 2).
if exist('banhchudong_meas.mat','file')
    M = load('banhchudong_meas.mat');
    fprintf('Fit v: %.1f %% | Fit Tp: %.1f %% | Fit omega dong co: %.1f %%\n', ...
        fit_percent(M.v(:), interp1(R(2).t,R(2).Y(:,1),M.t(:))), ...
        fit_percent(M.Tp(:), interp1(R(2).t,R(2).Y(:,8),M.t(:))), ...
        fit_percent(M.we(:), interp1(R(2).t,R(2).Y(:,2),M.t(:))));
end

%% ---------- ham phu ----------
function ab(mdl,nm,lib,col,row,varargin)
    x = 40+col*170;  y = 40+row*85;
    add_block(lib,[mdl '/' nm],'Position',[x y x+110 y+45],varargin{:});
end
function nameSig(mdl,blk,nm)
    ph = get_param([mdl '/' blk],'PortHandles');
    set_param(get_param(ph.Outport(1),'Line'),'Name',nm);
end
function apply_scn(mdl,P,s)
    ig = P.i_gear(s.ig);
    ww = s.v0/P.rb;  wgo = P.i0*ww;
    if s.locked, we = ig*wgo; else, we = 780*pi/30; end
    ic = @(blk,val) set_param([mdl '/' blk],'InitialCondition',sprintf('%.10g',val));
    ic('Int_v',s.v0);  ic('Int_we',we);  ic('Int_wgo',wgo);
    ic('Int_wwL',ww);  ic('Int_wwR',ww);  ic('Int_wdL',ww);  ic('Int_wdR',ww);
    ic('Int_phip',0);  ic('Int_phiL',0);  ic('Int_phiR',0);
    set_param([mdl '/ig_w'],'Gain',sprintf('%.10g',ig));
    set_param([mdl '/ig_eta'],'Gain',sprintf('%.10g',ig*P.eta_g));
    tbm = max(s.Tbmax,1e-9);
    set_param([mdl '/Tb_sat'],'UpperLimit',sprintf('%.10g',tbm),'LowerLimit',sprintf('%.10g',-tbm));
end
function f = fit_percent(ymeas,ysim)
    f = 100*(1 - norm(ymeas-ysim)/norm(ymeas-mean(ymeas)));  % NRMSE fit
end
