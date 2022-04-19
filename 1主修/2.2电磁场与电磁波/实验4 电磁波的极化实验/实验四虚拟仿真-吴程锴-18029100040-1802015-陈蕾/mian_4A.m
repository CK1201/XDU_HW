clc,clear
close all
N=40;
phi1=pi/4;
phi2=0;
lambda=1;
k=2*pi/lambda;
Em = 0.1*N+5;
w = 10;
z=0:0.01:3;
type='椭圆极化';
zz=5;


t=0;
Ex=Em*cos(w*t+phi1-k*z);
Ey=Em*cos(w*t+phi2-k*z);
subplot(3,2,1)
plot3(Ex,Ey,z);
hold on
plot3(0,0,0,'ro')
plot3(0,0,0,'bo','MarkerSize',2)
xlabel('x')
ylabel('y')
zlabel('z')
title(['t=',num2str(t),'时刻',type])

subplot(3,2,2)
plot3(Ex,Ey,z);
hold on
plot3([0,0],[0,0],[0,zz])
xlabel('x')
ylabel('y')
zlabel('z')
title(['t=',num2str(t),'时刻',type])

t=1;
Ex=Em*cos(w*t+phi1-k*z);
Ey=Em*cos(w*t+phi2-k*z);
subplot(3,2,3)
plot3(Ex,Ey,z);
hold on
plot3(0,0,0,'ro')
plot3(0,0,0,'bo','MarkerSize',2)
xlabel('x')
ylabel('y')
zlabel('z')
title(['t=',num2str(t),'时刻',type])

subplot(3,2,4)
plot3(Ex,Ey,z);
hold on
plot3([0,0],[0,0],[0,zz])
xlabel('x')
ylabel('y')
zlabel('z')
title(['t=',num2str(t),'时刻',type])

t=2;
Ex=Em*cos(w*t+phi1-k*z);
Ey=Em*cos(w*t+phi2-k*z);
subplot(3,2,5)
plot3(Ex,Ey,z);
hold on
plot3(0,0,0,'ro')
plot3(0,0,0,'bo','MarkerSize',2)
xlabel('x')
ylabel('y')
zlabel('z')
title(['t=',num2str(t),'时刻',type])

subplot(3,2,6)
plot3(Ex,Ey,z);
hold on
plot3([0,0],[0,0],[0,zz])
xlabel('x')
ylabel('y')
zlabel('z')
title(['t=',num2str(t),'时刻',type])