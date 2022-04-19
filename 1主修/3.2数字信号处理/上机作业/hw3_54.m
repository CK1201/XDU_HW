clc,clear
close all
%% 零极点
figure()
B1=[1];
A1=[1,-1.6,0.9425];
subplot(2,2,1)
zplane(B1,A1);
subtitle('函数1')

B2=[1,-0.3];
A2=[1,-1.6,0.9425];
subplot(2,2,2)
zplane(B2,A2);
subtitle('函数2')

B3=[1,-0.8];
A3=[1,-0.5,-0.3];
subplot(2,2,3)
zplane(B3,A3);
subtitle('函数3')

B4=[1,-1.6,0.8];
A4=[1,-1.6,0.9425];
subplot(2,2,4)
zplane(B4,A4);
subtitle('函数4')

%% 单位脉冲响应
figure()
hn1=dimpulse(B1,A1);
subplot(2,2,1)
stem(hn1);
subtitle('函数1')

hn2=dimpulse(B2,A2);
subplot(2,2,2)
stem(hn2);
subtitle('函数2')

hn3=dimpulse(B3,A3);
subplot(2,2,3)
stem(hn3);
subtitle('函数3')

hn4=dimpulse(B4,A4);
subplot(2,2,4)
stem(hn4);
subtitle('函数4')