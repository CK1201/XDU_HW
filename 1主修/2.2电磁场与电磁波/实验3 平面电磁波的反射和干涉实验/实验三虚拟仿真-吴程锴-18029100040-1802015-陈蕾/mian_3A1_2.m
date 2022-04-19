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
f=w/2/pi;
lambda=3*10^8/f;
Ei0=1;

zz=5;
yy=0.008;

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
text(-2.8,1/eta1*Ei0*exp(-k1*-2.8*i),'\leftarrow 入射波')
text(-1.8,-1/eta1*Er0*exp(k1*-1.8*i),'\leftarrow 反射波')
text(-3.8,-1/eta1*Er0*exp(k1*-3.8*i)+1/eta1*Ei0*exp(-k1*-3.8*i),'\leftarrow 合成波')
title('平面磁场向理想导体垂直入射的仿真结果')
text(-3,yy*4/5,'介质1')
text(-4.3,-yy*4/5,['\epsilon_1=',num2str(epsilon1),'     \mu_1=',num2str(mu1),'     \sigma_1=',num2str(sigma1)])
text(2,yy*4/5,'理想导体')
text(0.7,-yy*4/5,['\epsilon_2=',num2str(epsilon2),'     \mu_2=',num2str(mu2),'     \sigma_2=',num2str(sigma2)])
plot(z,Hi,z,Hr,z,Hi+Hr)
axis([-zz zz -yy yy])
xlabel('z')
ylabel('y')
fill([zz zz 0 0]',[-yy yy yy -yy]','g')
fill([-zz -zz 0 0]',[-yy yy yy -yy]','r')
alpha(0.2)
line([0 0],[-1 1],'Color','black','LineStyle','--');
line([-zz zz],[0 0],'Color','black','LineStyle','--');
% set(gca,'YGrid','on');