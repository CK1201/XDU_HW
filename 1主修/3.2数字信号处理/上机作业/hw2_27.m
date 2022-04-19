clc,clear
close all
%% 单位脉冲
h=[];
h(1)=0.866;
h(2)=0.8*h(1);
for i=3:50
    h(i)=0.8*h(i-1)-0.64*h(i-2);
end
figure()
stem(0:49,h)
%% 单位阶跃
y=[];
y(1)=0.866;
y(2)=0.8*y(1)+0.866;
for i=3:101
    y(i)=0.8*y(i-1)-0.64*y(i-2)+0.866;
end
figure()
stem(0:100,y)
%% 
h1=h(1:15);
y1=cumsum(h1);
figure()
stem(0:14,y1)