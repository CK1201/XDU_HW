clc,clear
close all;
%% 巴特沃斯
Wp = 0.1;
Ws = 0.5;
AlphaP=0.5;
AlphaS = 45;
[N,Wc]=buttord(Wp,Ws,AlphaP,AlphaS);
[Bz,Az]=butter(N,Wc);
W = 0:0.01:pi;
[H,W] = freqz(Bz,Az,W);
H = 20*log10(abs(H));
plot(W/pi,H,'linewidth',2);
hold on
%% 切比雪夫I型
[N,Wpo] = cheb1ord(Wp,Ws, AlphaP,AlphaS);
[Bz,Az] = cheby1(N, AlphaP, Wpo);
[H,W] = freqz(Bz ,Az,W);
H=20*log10(abs(H));
plot(W/pi,H,'linewidth',2);
grid on
xlabel('频率*\pi(rad/s)');ylabel( '幅度(dB)');
legend('巴特沃斯','切比雪夫I型')