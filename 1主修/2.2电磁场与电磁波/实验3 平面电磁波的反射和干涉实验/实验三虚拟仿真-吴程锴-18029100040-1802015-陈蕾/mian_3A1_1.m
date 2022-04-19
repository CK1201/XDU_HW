clc,clear
close all
%介质1参数
epsilon1=8.854187817*10^-12;
mu1=4*pi*10^-7;
sigma1=0;
%介质2参数
epsilon2=8.854187817*10^-12;
mu2=4*pi*10^-7;
sigma2=inf;

% f=6*10^8;
w=10^9;
Ei0=1;

f=w/2/pi;
lambda=3*10^8/f;

zz=5;
xx=1.5;
yy=0.005;

k1=w*sqrt(epsilon1*mu1);
eta1=sqrt(mu1/epsilon1);
z=-zz:0.0001:0;
%入射波
Ei=Ei0*exp(-k1*z*i);
Hi=1/eta1*Ei0*exp(-k1*z*i);
%反射波
Er0=-Ei0;
Er=Er0*exp(k1*z*i);
Hr=-1/eta1*Er0*exp(k1*z*i);
%作图
hold on
text(-2.8,Ei0*exp(-k1*-2.8*i),'\leftarrow 入射波')
text(-1.8,Er0*exp(k1*-1.8*i),'\leftarrow 反射波')
text(-3.8,Er0*exp(k1*-3.8*i)+Ei0*exp(-k1*-3.8*i),'\leftarrow 合成波')
title('平面电场向理想导体垂直入射的仿真结果')
text(-3,xx*4/5,'介质1')
text(-4.3,-xx*4/5,['\epsilon_1=',num2str(epsilon1),'     \mu_1=',num2str(mu1),'     \sigma_1=',num2str(sigma1)])
text(2,xx*4/5,'理想导体')
text(0.7,-xx*4/5,['\epsilon_2=',num2str(epsilon2),'     \mu_2=',num2str(mu2),'     \sigma_2=',num2str(sigma2)])
plot(z,Ei,z,Er,z,Ei+Er)
axis([-zz zz -xx xx])
xlabel('z')
ylabel('x')
fill([zz zz 0 0]',[-xx xx xx -xx]','g')
fill([-zz -zz 0 0]',[-xx xx xx -xx]','r')
alpha(0.2)
line([0 0],[-1 1],'Color','black','LineStyle','--');
line([-zz zz],[0 0],'Color','black','LineStyle','--');
% set(gca,'YGrid','on');