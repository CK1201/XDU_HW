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
FFTx=fft(x,N);              %离散傅里叶变换
A=abs(FFTx)/L;              %转化为幅度
A(2:end)=A(2:end)*2;        %单侧频谱非直流分量要乘2
A=A(1:L/2+1);
fx=(0:(L/2))*Fs/N;          %不同点对应的幅值,最多一半，因为奈奎斯特采样定理

figure()
plot(fx(1:Fs/8),A(1:Fs/8),'linewidth',2)
ylabel('幅度(V)');
xlabel('频率(Hz)');
title('复合信号幅频特性');
axis([-inf inf 0 5])
set(gca,'FontWeight','bold','FontSize',10)

%自相关函数
[Rx,lags]=xcorr(x,'biased');

figure()
plot(lags,Rx,'linewidth',2)
ylabel('相关程度');
xlabel('时间偏移(s)');
set(gca,'FontWeight','bold','FontSize',10)
%功率谱密度
FFTx=fftshift(FFTx);            %频谱矫正
PowerSpectrum=abs(FFTx./L).^2;  %双边功率谱
Gx=fft(Rx,size(Rx,2));          %对自相关函数快速傅里叶变换
Gx=abs(fftshift(Gx));           %频谱矫正，让正半轴部分和负半轴部分的图像分别关于各自的中心对称，得到双边谱

figure()
fGx=((1:length(Gx))*L/length(Gx)-L/2)/6.5;
bound=[(length(Gx)-1)/2-2000,(length(Gx)-1)/2+2000];
plot(fGx(bound(1):bound(2)),Gx(bound(1):bound(2))./length(PowerSpectrum),'linewidth',2)
xlabel("频率(Hz)")
ylabel("功率谱(W/Hz)")
set(gca,'FontWeight','bold','FontSize',10)
title("功率谱密度")
axis([-1000 1000 -inf 6])

% Gx=abs(FFTx).^2/N;    %功率谱密度
% fGx=Fs*(0:Fs-1)/N;   %不同点对应的频率值
% subplot(2,1,2)
% plot(fGx(1:Fs/8),Gx(1:Fs/8));
% ylabel('功率');
% xlabel('频率(Hz)');
% title('复合信号功率谱密度');
% set(gca,'FontWeight','bold','FontSize',10)

% figure()
% [Rx,tao]=xcorr(x,'coeff');
% % plot(tao*dt,Rx)
% Gxx=fft(Rx);
% Gxx=abs(Gxx/length(Rx));
% fGx=(1:length(Rx))*Fs/length(Rx);
% plot(fGx,Gxx)
%% 通过RC积分电路
R=1;
C=0.1;
a=1/(R*C);
%幅频特性
H1_abs=a./sqrt(1+fx.^2);
A1=A.*H1_abs;
figure()
subplot(2,1,1)
plot(fx(1:Fs/8),A1(1:Fs/8));
ylabel('幅度(V)');
xlabel('频率(Hz)');
title('通过RC积分电路后的幅频特性');
set(gca,'FontWeight','bold','FontSize',10)

%功率谱密度
H1_2=1./(1+(fGx/a).^2);
Gy1=Gx.*H1_2;
% figure()
subplot(2,1,2)
plot(fGx(bound(1):bound(2)),Gy1(bound(1):bound(2)));
ylabel('功率');
xlabel('频率(Hz)');
title('通过RC积分电路后的功率谱密度');
set(gca,'FontWeight','bold','FontSize',10)
axis([-1000 1000 -inf inf])

%% 通过理想低通滤波器
Fc=800;  %截止频率
K0=1;
H2=fx;
H2(H2<=Fc)=1;
H2(H2>Fc)=0;
H2=H2*K0;
%%幅频特性
H2_abs=H2;
A2=A.*H2_abs;
figure()
subplot(2,1,1)
plot(fx(1:Fs/8),A2(1:Fs/8));
ylabel('幅度(V)');
xlabel('频率(Hz)');
title('通过理想低通滤波器后的幅频特性');
set(gca,'FontWeight','bold','FontSize',10)

%功率谱密度
H2=fGx;
H2(abs(H2)<=Fc)=1;
H2(abs(H2)>Fc)=0;
H2=H2*K0;
H2_2=H2.^2;
Gy2=Gx.*H2_2;
subplot(2,1,2)
plot(fGx(bound(1):bound(2)),Gy2(bound(1):bound(2)));
ylabel('功率');
xlabel('频率(Hz)');
title('通过理想低通滤波器后的功率谱密度');
set(gca,'FontWeight','bold','FontSize',10)
axis([-1000 1000 -inf inf])