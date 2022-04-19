clc,clear
close all
%介质1参数
epsilon1=8.854187817*10^-12;
mu1=4*pi*10^-7;
sigma1=0;
%理想介质参数
epsilon2=8.854187817*10^-12*5;
mu2=4*pi*10^-7*2;
sigma2=0;

% f=6*10^8;
w=10^9;
Ei0=1;

f=w/2/pi;
lambda=3*10^8/f;

zz=5;
yy=0.005;

k1=w*sqrt(epsilon1*mu1);
eta1=sqrt(mu1/epsilon1);

k2=w*sqrt(epsilon2*mu2);
eta2=sqrt(mu2/epsilon2);

z=-zz:0.0001:0;
z1=0:0.0001:zz;
%入射波
Ei=Ei0*exp(-k1*z*i);
Hi=1/eta1*Ei0*exp(-k1*z*i);
%反射波
Er0=Ei0*(eta2-eta1)/(eta2+eta1);
Er=Er0*exp(k1*z*i);
Hr=-1/eta1*Er0*exp(k1*z*i);
%透射波
Et0=Ei0+Er0;
Et=Et0*exp(-k2*z1*i);
Ht=-1/eta2*Et0*exp(-k2*z1*i);
%作图
hold on
% text(-2.8,Ei0*exp(-k1*-2.8*i),'\leftarrow 入射波')
% text(-1.8,Er0*exp(k1*-1.8*i),'\leftarrow 反射波')
text(-2.8,1/eta1*Ei0*exp(-k1*-2.8*i),'\leftarrow 入射波')
text(-1.8,-1/eta1*Er0*exp(k1*-1.8*i),'\leftarrow 反射波')
text(-3.8,-1/eta1*Er0*exp(k1*-3.8*i)+1/eta1*Ei0*exp(-k1*-3.8*i),'\leftarrow 合成波')
text(1.8,-1/eta2*Et0*exp(-k2*1.8*i),'\leftarrow 透射波')
title('平面磁场向理想介质垂直入射的仿真结果')
text(-3,yy*4/5,'介质1')
text(-4.3,-yy*4/5,['\epsilon_1=',num2str(epsilon1),'     \mu_1=',num2str(mu1),'     \sigma_1=',num2str(sigma1)])
text(2,yy*4/5,'理想介质')
text(0.7,-yy*4/5,['\epsilon_2=',num2str(epsilon2),'     \mu_2=',num2str(mu2),'     \sigma_2=',num2str(sigma2)])
plot(z,Hi,z,Hr,z1,Ht,z,Hi+Hr)
axis([-zz zz -yy yy])
xlabel('z')
ylabel('y')
fill([zz zz 0 0]',[-yy yy yy -yy]','g')
fill([-zz -zz 0 0]',[-yy yy yy -yy]','r')
alpha(0.2)
line([0 0],[-1 1],'Color','black','LineStyle','--');
line([-zz zz],[0 0],'Color','black','LineStyle','--');