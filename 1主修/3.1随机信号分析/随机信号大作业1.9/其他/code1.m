clc,clear
close all
rng('default')%随机种子
t=0:0.001:10;
phi=rand(1,3)*2*pi;
x(1,:)=5*cos(t+phi(1));
x(2,:)=5*cos(t+phi(2));
x(3,:)=5*cos(t+phi(3));
figure()
hold on
plot(t,x(1,:),'linewidth',2)
plot(t,x(2,:),'linewidth',2)
plot(t,x(3,:),'linewidth',2)
xlabel('时间')
ylabel('幅度')
grid on
set(gca,'FontWeight','bold','FontSize',10)