clc,clear
close all
x=[0,-0.5,0,0.5,1];
h=[1,1,1,0,0];
y=conv(x,h);
figure()
stem(-4:4,y)