clc,clear
close all
%% 
N=6;
n = 0:N-1;
x = [1 2 3 3 2 1];
k = 0:200;
w = pi/200*k;
X = x*(exp(-1i*pi/200)).^(n'*k);
magX = abs(X);
angX = angle(X);
figure(1)
subplot(2,2,1)
plot(w/pi,magX);
grid on;
subtitle('DTFT幅频特性曲线');
subplot(2,2,2)
plot(w/pi,angX);
grid on;
subtitle('DTFT相频特性曲线');
Xdft = fft(x,201);
magXd = abs(Xdft);
angXd = angle(Xdft);
subplot(2,2,3)
stem(w(1:100)/pi*2,magXd(1:100));
grid on;
subtitle('DFT幅频特性曲线');
subplot(2,2,4)
stem(w(1:100)/pi*2,angXd(1:100));
grid on;
subtitle('DFT相频特性曲线');