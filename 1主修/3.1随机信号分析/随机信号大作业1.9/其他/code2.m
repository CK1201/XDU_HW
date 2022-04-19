clc,clear
close all
%% 复合信号
N=2^16;%采样点数
Fs=10000;%采样率
F=100;%信号频率
dt=1/Fs;

t=1/Fs:1/Fs:N/Fs;
L=length(t);
s=5*cos(2*pi*F*t);
figure()
plot(t,s);
ylabel('幅度(V)');
xlabel('时间(s)');
set(gca,'FontWeight','bold','FontSize',10)
axis([-inf inf -6 6])

n=1*randn(size(t));
figure()
plot(t,n);
ylabel('幅度(V)');
xlabel('时间(s)');
set(gca,'FontWeight','bold','FontSize',10)

x=s+n;
figure()
plot(t,x);
ylabel('幅度(V)');
xlabel('时间(s)');
set(gca,'FontWeight','bold','FontSize',10)
%% 
%幅频特性
Fx=fft(x,N);            %离散傅里叶变换
A=abs(Fx)/L;            %转化为幅度
A(2:end)=A(2:end)*2;    %单侧频谱非直流分量要乘2
A=A(1:L/2+1);
fx=(0:(L/2))*Fs/N;          %不同点对应的幅值,最多到一半（奈奎斯特采样定理）

figure()
subplot(2,1,1)
plot(fx(1:Fs/8),A(1:Fs/8));
ylabel('幅度(V)');
xlabel('频率(Hz)');
title('复合信号幅频特性');
axis([-inf inf 0 5])
set(gca,'FontWeight','bold','FontSize',10)
%功率谱密度


Gx=abs(Fx).^2/N;    %功率谱密度
f2=Fs*(0:Fs-1)/N;   %不同点对应的频率值
subplot(2,1,2)
plot(f2(1:Fs/8),Gx(1:Fs/8));
ylabel('功率');
xlabel('频率(Hz)');
title('复合信号功率谱密度');
set(gca,'FontWeight','bold','FontSize',10)

[pxx,f] = pwelch(x,500,300,N,Fs);
figure()
plot(f(1:Fs/8),pxx(1:Fs/8))
% figure()
% [Rx,tao]=xcorr(x,'coeff');
% plot(tao*dt,Rx)
% Gxx=fft(Rx);
% Gxx=abs(Gxx/length(Rx));
% fGx=(1:length(Rx))*Fs/length(Rx);
% plot(fGx,Gxx)



%% 通过RC积分电路
R=1;
C=1;
a=1/(R*C);
%幅频特性
H1_abs=a./sqrt(1+f2.^2);
A1=A(1:Fs).*H1_abs;
figure()
subplot(2,1,1)
plot(f2(1:Fs/8),A1(1:Fs/8));
ylabel('幅度(V)');
xlabel('频率(Hz)');
title('通过RC积分电路后的幅频特性');
set(gca,'FontWeight','bold','FontSize',10)

%功率谱密度
H1_2=1./(1+(f2/a).^2);
Gy1=Gx(1:Fs).*H1_2;
% figure()
subplot(2,1,2)
plot(f2(1:Fs/8),Gy1(1:Fs/8));
ylabel('功率');
xlabel('频率(Hz)');
title('通过RC积分电路后的功率谱密度');
set(gca,'FontWeight','bold','FontSize',10)


%% 通过理想低通滤波器
Fc=50;  %截止频率
K0=5;
H2=f2;
H2(H2<=Fc)=1;
H2(H2>Fc)=0;
H2=H2*K0;
%%幅频特性
H2_abs=H2;
A2=A(1:Fs).*H2_abs;
figure()
subplot(2,1,1)
plot(f2(1:Fs/8),A2(1:Fs/8));
ylabel('幅度(V)');
xlabel('频率(Hz)');
title('通过理想低通滤波器后的幅频特性');
set(gca,'FontWeight','bold','FontSize',10)

%功率谱密度
H2_2=H2.^2;
Gy2=Gx(1:Fs).*H2_2;
subplot(2,1,2)
plot(f2(1:Fs/8),Gy2(1:Fs/8));
ylabel('功率');
xlabel('频率(Hz)');
title('通过理想低通滤波器后的功率谱密度');
set(gca,'FontWeight','bold','FontSize',10)