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
axis([0 0.3 -6 6])

n=1*randn(size(t));
figure()
plot(t,n);
ylabel('幅度(V)');
xlabel('时间(s)');
set(gca,'FontWeight','bold','FontSize',10)
axis([0 0.3 -inf inf])

x=s+n;
figure()
plot(t,x);
ylabel('幅度(V)');
xlabel('时间(s)');
set(gca,'FontWeight','bold','FontSize',10)
axis([0 0.3 -inf inf])
%% 复合信号
%包络的概率密度
[histFreq, histXout]=hist(abs(x),100);
binWidth = histXout(2)-histXout(1);
figure()
hold on
bar(histXout, histFreq/binWidth/sum(histFreq))
plot(histXout,histFreq/binWidth/sum(histFreq),'r','linewidth',2);
xlabel('幅度(V)')
ylabel('概率')
set(gca,'FontWeight','bold','FontSize',10)

%幅频特性
FFTx=fft(x,N);              %离散傅里叶变换
A=abs(FFTx)/L;              %转化为幅度
A(2:end)=A(2:end)*2;        %单侧频谱非直流分量要乘2
A=A(1:L/2+1);
FFTx=FFTx(1:L/2+1);
fx=(0:(L/2))*Fs/N;          %不同点对应的幅值,最多一半，因为奈奎斯特采样定理
figure()
plot(fx,A,'linewidth',2)
xlabel('频率(Hz)')
ylabel('幅度(V)')
axis([0 200 0 5])
set(gca,'FontWeight','bold','FontSize',10)

%自相关函数
[Rx,lags]=xcorr(x,'biased');
figure()
plot(lags,Rx);
xlabel('时间间隔(s)');
ylabel('相关函数');
set(gca,'FontWeight','bold','FontSize',10)
%功率谱密度
[Gx,fGx]=pwelch(x,[],[],length(x),Fs);
figure()
plot(fGx,Gx)
xlabel('频率(Hz)')
ylabel('PSD(W/Hz)')
set(gca,'FontWeight','bold','FontSize',10)
axis([0 200 -inf inf])
Gx=abs(fft(Rx,size(Rx,2))/length(Rx));
Gx=Gx(1:length(Rx)/2+1);
Gx=[Gx(end:-1:1),Gx];
fGx=(0:(length(Rx)/2))*Fs/length(Rx);
fGx=[-fGx(end:-1:1),fGx];
figure()
plot(fGx,Gx,'linewidth',2)
axis([-150 150 -inf inf])
xlabel("频率(Hz)")
ylabel("PSD(W/Hz)")
set(gca,'FontWeight','bold','FontSize',10)
%% 通过RC积分电路
R=1;
C=1;
a=1/(R*C);

%包络的概率密度
H1=a./(a+fx*1i);
FFTy1=FFTx.*H1;
y1=ifft(FFTy1,N);
y1=real(y1)*2;
[histFreq, histXout]=hist(abs(y1),100);
binWidth = histXout(2)-histXout(1);
figure()
hold on
bar(histXout, histFreq/binWidth/sum(histFreq))
plot(histXout,histFreq/binWidth/sum(histFreq),'r','linewidth',2);
xlabel('幅度(V)')
ylabel('概率')
set(gca,'FontWeight','bold','FontSize',10)
%幅频特性
H1_abs=a./sqrt(a^2+fx.^2);
A1=A.*H1_abs;
figure()
subplot(2,1,1)
plot(fx,A1,'linewidth',2)
ylabel('幅度(V)');
xlabel('频率(Hz)');
title('通过RC积分电路后的幅频特性');
set(gca,'FontWeight','bold','FontSize',10)
axis([0 200 -inf inf])

%功率谱密度
H1_2=1./(1+(fGx/a).^2);
Gy1=Gx.*H1_2;
% figure()
subplot(2,1,2)
plot(fGx,Gy1,'linewidth',2)
xlabel('频率(Hz)');
ylabel("PSD(W/Hz)")
title('通过RC积分电路后的功率谱密度');
set(gca,'FontWeight','bold','FontSize',10)
axis([-150 150 -inf inf])

%% 通过理想低通滤波器
Fc=150;  %截止频率
K0=1;
H2=fx;
H2(H2<=Fc)=1;
H2(H2>Fc)=0;
H2=H2*K0;
%包络的概率密度
FFTy2=FFTx.*H2;
y2=ifft(FFTy2,N);
y2=real(y2)*2;
[histFreq, histXout]=hist(abs(y2),100);
binWidth = histXout(2)-histXout(1);
figure()
hold on
bar(histXout, histFreq/binWidth/sum(histFreq))
plot(histXout,histFreq/binWidth/sum(histFreq),'r','linewidth',2);
xlabel('幅度(V)')
ylabel('概率')
set(gca,'FontWeight','bold','FontSize',10)
%%幅频特性
H2_abs=H2;
A2=A.*H2_abs;
figure()
subplot(2,1,1)
plot(fx,A2,'linewidth',2)
ylabel('幅度(V)');
xlabel('频率(Hz)');
title('通过理想低通滤波器后的幅频特性');
set(gca,'FontWeight','bold','FontSize',10)
axis([0 200 -inf inf])

%功率谱密度
H2=fGx;
H2(abs(H2)<=Fc)=1;
H2(abs(H2)>Fc)=0;
H2=H2*K0;
H2_2=H2.^2;
Gy2=Gx.*H2_2;
subplot(2,1,2)
% figure()
plot(fGx,Gy2,'linewidth',2)
xlabel('频率(Hz)');
ylabel("PSD(W/Hz)")
title('通过理想低通滤波器后的功率谱密度');
set(gca,'FontWeight','bold','FontSize',10)
axis([-150 150 -inf inf])