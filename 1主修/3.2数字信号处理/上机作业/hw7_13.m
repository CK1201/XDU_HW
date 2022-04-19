clc,clear
close all
%% 低通  
Fs=50000;
fp=10000;
fs=25000;
wp=2*fp/Fs*pi;
ws=2*fs/Fs*pi;
B=ws-wp;
N=ceil(11*pi/B);
wc=(wp+ws)/2/pi;
h=fir1(N-1,wc,blackman(N));
figure()
stem(h);
figure();
freqz(h,1);