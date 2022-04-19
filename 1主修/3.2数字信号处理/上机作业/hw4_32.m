clc,clear
close all
%% 
N = 4;
x1 = [2 1 1 2];
x2 = [1 -1 -1 1];
xn1 = 0:N-1;
xn2 = 0:N-1;
%% 
subplot(3,1,1);
stem(xn1,x1);
subtitle('x_1(n)')
xlim([-1,4]);
ylim([-2,2]);
%% 
subplot(3,1,2);
stem(xn2,x2);
subtitle('x_2(n)')
xlim([-1,4]);
ylim([-2,2]);
%% 
x11 = fft(x1,N);
x22 = fft(x2,N);
yf = x11 .* x22;
y = ifft(yf,N);
subplot(3,1,3);
figure()
n = 0:length(y) - 1;
stem(n,y);
xlim([-1,4]);
ylim([-2,2]);
grid on
subtitle('x_1(n)卷积x_2(n)')