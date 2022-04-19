clc,clear
close all
%% 
N=64;
n=0:1:N-1;
w0=2*pi/15;
w1=2.3*pi/15;
x=cos(w0.*n) + 0.75*cos(w1.*n);
subplot(2,1,1)
X=fft(x,N);
magX=abs(X);
stem(magX(1:N/2));
subtitle('64点DFT')
subplot(2,1,2)
X=fft(x,4*N);
magX=abs(X);
stem(magX(1:4*N/2));
subtitle('256点DFT')