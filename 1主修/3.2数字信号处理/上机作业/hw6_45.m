clc,clear
close all
%%
fs = 8000; %Hz 采样频率
Ts = 1/fs;
N  = 16384; %序列长度
t = (0:N-1)*Ts;
x = 2*0.5*sin(2*pi*50*t);

%% 设计一个带通滤波器,要求把50Hz和400Hz的频率分量滤掉,其他分量保留
wp = [1900 2500 ] / (fs/2);
ws = [1700 2700 ] / (fs/2);
alpha_p = 1;
alpha_s = 40;
[ N3 wn ] = ellipord(wp,ws,alpha_p,alpha_s);
[ b a ] = ellip(N3,alpha_p,alpha_s,wn,'bandpass'); 
filter_bp_s = filter(b,a,x);
X_bp_s = fftshift(abs(fft(filter_bp_s)))/N;
X_bp_s_angle = fftshift(angle(fft(filter_bp_s)));
freqz(b,a);