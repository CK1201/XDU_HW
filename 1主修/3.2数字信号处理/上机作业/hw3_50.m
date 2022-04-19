clc,clear
close all
%% 零极点
B=[0,0,0.8];
A=[1,-0.5,-0.3];
zplane(B,A);
%% 单位阶跃响应
figure()
% hn=dimpulse(B,A);
hn=dstep(B,A);
stem(hn);
% title('单位冲激响应')