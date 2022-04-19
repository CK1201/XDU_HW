clc,clear
global q
global B
global E
global m
m=1;        %带电粒子质量
q=1;        %带电粒子带电量
x0=0;       %带电粒子x轴初始位置
y0=0;       %带电粒子y轴初始位置
z0=0;       %带电粒子z轴初始位置
vx0=0;      %带电粒子x轴初始速度
vy0=1;      %带电粒子y轴初始速度
vz0=1;      %带电粒子z轴初始速度
%% 参数设置
B=0;        %磁场强度
E=1;        %电场强度
%% 解微分方程组
[T,W]=ode45('fun',[0 50],[x0 vx0 y0 vy0 z0 vz0]);
%% 作图
plot3(W(:,1),W(:,3),W(:,5));    
xlabel('x')
ylabel('y')
zlabel('z')