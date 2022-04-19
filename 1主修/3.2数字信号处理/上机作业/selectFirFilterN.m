function [M,beta] = selectFirFilterN(fp,fs,detap,detas)
% 自动选择kaiser窗对应的M和beta值
global Fs
wp = 2*pi*(fp/Fs);
ws = 2*pi*(fs/Fs);

A = -20*log10(min(detap,detas));
M = ceil((A-7.95)/(2.285*abs(wp-ws)));
M = mod(M,2)+M;
% 确定beta的值
if A<21
    beta = 0;
elseif A>=21 && A<=50
    beta = 0.5842*(A-21)^0.4+0.07886*(A-21);
else
    beta = 0.1102*(A-8.7);
end