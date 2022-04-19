clc,clear
close all
n=0:100;
v=normrnd(0,1,1,length(n));
x=10*sin(0.02*pi*n)+v;
figure()
stem(n,x)