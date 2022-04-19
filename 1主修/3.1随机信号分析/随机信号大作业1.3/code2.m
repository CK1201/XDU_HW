clc,clear
close all
%% 复合信号
N=2^13;%采样点数
Fs=10000;%采样率
F=100;%信号频率
dt=1/Fs;

t=1/Fs:1/Fs:N/Fs;
L=length(t);
s=5*cos(2*pi*F*t);
figure()
plot(t,s,'linewidth',2)
ylabel('幅度(V)');
xlabel('时间(s)');
set(gca,'FontWeight','bold','FontSize',10)
axis([0 0.5 -6 6])

n=1*randn(size(t));
figure()
plot(t,n,'linewidth',2)
ylabel('幅度(V)');
xlabel('时间(s)');
set(gca,'FontWeight','bold','FontSize',10)
axis([0 0.5 -inf inf])

x=s+n;
figure()
plot(t,x,'linewidth',2)
ylabel('幅度(V)');
xlabel('时间(s)');
set(gca,'FontWeight','bold','FontSize',10)
axis([0 0.5 -inf inf])
%% 
%幅频特性
FFTx=fft(x,N);              %离散傅里叶变换
A=abs(FFTx)/L;              %转化为幅度
A(2:end)=A(2:end)*2;        %单侧频谱非直流分量要乘2
A=A(1:L/2+1);
FFTx=FFTx(1:L/2+1);
fx=(0:(L/2))*Fs/N;          %不同点对应的幅值,最多一半，因为奈奎斯特采样定理
figure()
plot(fx(1:Fs/8),A(1:Fs/8),'linewidth',2)
ylabel('幅度(V)');
xlabel('频率(Hz)');
axis([-inf inf 0 5])
set(gca,'FontWeight','bold','FontSize',10)

y1=ifft(FFTx,N);
figure;
plot(t ,y1*2-x);

%幅度分布
figure()
hist(x,100)
xlabel("幅度(V)")
ylabel("个数")
set(gca,'FontWeight','bold','FontSize',10)

%自相关函数
% % [Rx,lags]=xcorr(x,'biased');
% % [Rx,lags]=xcorr(x,'coeff');
% [Rx,lags]=xcorr(x);
% % Rx=Rx/N/F/2;
% figure()
% plot(lags,Rx);
% %功率谱密度
% Pw=fft(Rx);
% % Pw=fftshift(Pw);
% f=(0:round(length(Pw)/2-1))*Fs/length(Pw);
% figure()
% plot(f,10*log10(abs(Pw(1:length(f)))));
% % plot(lags(1:1000)*0.25,Pw());
[Pxx,f]=pwelch(x,[],[],length(x),Fs);
figure()
plot(f,Pxx,'linewidth',2)
axis([0 200 -inf inf])
Gx=Pxx;
fGx=f;

% Gx=abs(fft(Rx,size(Rx,2))/length(Rx));
% Gx=Gx(1:length(Rx)/2+1);
% Gx=[Gx(end:-1:1),Gx];
% fGx=(0:(length(Rx)/2))*Fs/length(Rx);
% fGx=[-fGx(end:-1:1),fGx];
% bound=[(length(Gx)-1)/2-2000,(length(Gx)-1)/2+2000];
% figure()
% plot(fGx(bound(1):bound(2)),Gx(bound(1):bound(2)),'linewidth',2)
% axis([-150 150 0 4])
% xlabel("频率(Hz)")
% ylabel("PSD(W/Hz)")
% set(gca,'FontWeight','bold','FontSize',10)
%% 通过RC积分电路
R=1;
C=1;
a=1/(R*C);
%幅度分布
H1_abs=a./sqrt(a^2+fx.^2);
FFTy1=FFTx.*H1_abs;
y1=ifft(FFTy1,N);
y1=real(y1)*2;
figure;
plot(t ,y1);
figure()
hist(y1,100)

%功率谱密度
H1_2=1./(1+(fGx/a).^2);
Gy1=Gx.*H1_2;
figure()
subplot(2,1,2)
plot(fGx,Gy1,'linewidth',2)
xlabel('频率(Hz)');
ylabel("PSD(W/Hz)")
title('通过RC积分电路后的功率谱密度');
set(gca,'FontWeight','bold','FontSize',10)
axis([0 200 -inf inf])

%% 通过理想低通滤波器
Fc=50;  %截止频率
K0=1;
H2=fx;
H2(H2<=Fc)=1;
H2(H2>Fc)=0;
H2=H2*K0;
%幅频特性
H2_abs=H2;
FFTy2=FFTx.*H2_abs;
y2=ifft(FFTy2,N);
y2=real(y2)*2;
figure;
plot(t ,y2);
figure()
hist(y2,100)
% figure()
% subplot(2,1,1)
% plot(fx(1:Fs/8),A2(1:Fs/8),'linewidth',2)
% ylabel('幅度(V)');
% xlabel('频率(Hz)');
% title('通过理想低通滤波器后的幅频特性');
% set(gca,'FontWeight','bold','FontSize',10)
% 
%功率谱密度
H2=fGx;
H2(abs(H2)<=Fc)=1;
H2(abs(H2)>Fc)=0;
H2=H2*K0;
H2_2=H2.^2;
Gy2=Gx.*H2_2;
% subplot(2,1,2)
figure()
plot(fGx,Gy2,'linewidth',2)
xlabel('频率(Hz)');
ylabel("PSD(W/Hz)")
% title('通过理想低通滤波器后的功率谱密度');
set(gca,'FontWeight','bold','FontSize',10)
axis([0 200 -inf inf])