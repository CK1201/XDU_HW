clc,clear
close all
%读取文件
music='music1';
[Sound,Fs] = audioread([music,'.mp3']); %读取音频 Fs采样频率
T=1/Fs; %采样间隔
N=length(Sound);
t=(0:N-1)*T;    %时间 单位秒
% f=(0:N)*Fs/length(Sound);   %频率 单位赫兹
f=(-N/2:N/2-1)*Fs/N;    %频率

SoundL_t=Sound(:,1);   %左声道
SoundR_t=Sound(:,2);   %右声道
SoundL_f=T*fftshift(fft(SoundL_t,N));
SoundR_f=T*fftshift(fft(SoundR_t,N));

figure(1)
subplot(221)
plot(t,SoundL_t);
title('左声道原始音频信号')
xlabel('t/s')
subplot(222)
plot(f,SoundL_f,'r');
title('左声道原始音频信号频谱图')
xlabel('f/Hz')
subplot(223)
plot(t,SoundR_t);
title('右声道原始音频信号')
xlabel('t/s')
subplot(224)
plot(f,SoundR_f,'r');
title('右声道原始音频信号频谱图')
xlabel('f/Hz')

%参数设置
a1=1;
a2=-1;
b1=1;
b2=-1;
%双声道人声相互抵消
NewSoundL_t=a1*SoundL_t+a2*SoundR_t;
NewSoundR_t=b1*SoundL_t+b2*SoundR_t;
NewSound(:,1)=NewSoundL_t;
NewSound(:,2)=NewSoundR_t;
NewSoundL_f=T*fftshift(fft(NewSoundL_t,N));
NewSoundR_f=T*fftshift(fft(NewSoundR_t,N));

figure(2)
subplot(221)
plot(t,NewSoundL_t);
title('相减后左声道音频信号')
xlabel('t/s')
subplot(222)
plot(f,NewSoundL_f,'r');
title('相减后左声道音频信号频谱图')
xlabel('f/Hz')
subplot(223)
plot(t,NewSoundR_t);
title('相减后右声道音频信号')
xlabel('t/s')
subplot(224)
plot(f,NewSoundR_f,'r');
title('相减后右声道音频信号频谱图')
xlabel('f/Hz')

%滤波
BandStop1=fir1(200,2*[150,600]/Fs,'stop');
SoundTemp=filter(BandStop1,1,NewSound);
BandStop2=fir1(200,2*[1600,3600]/Fs,'stop');
SoundFinal=filter(BandStop2,1,SoundTemp);

SoundFinalL_t=SoundFinal(:,1);
SoundFinalR_t=SoundFinal(:,2);
SoundFinalL_f=T*fftshift(fft(SoundFinalL_t,N));
SoundFinalR_f=T*fftshift(fft(SoundFinalR_t,N));

figure(3)
subplot(221)
plot(t,SoundFinalL_t);
title('左声道最终音频信号')
xlabel('t/s')
subplot(222)
plot(f,SoundFinalL_f,'r');
title('左声道最终音频信号频谱图')
xlabel('f/Hz')
subplot(223)
plot(t,SoundFinalR_t);
title('右声道最终音频信号')
xlabel('t/s')
subplot(224)
plot(f,SoundFinalR_f,'r');
title('右声道最终音频信号频谱图')
xlabel('f/Hz')

%播放音乐
player = audioplayer(SoundFinal, Fs);
play(player);