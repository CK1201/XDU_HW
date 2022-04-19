function hd = FIRItypeIdealpulse(fp,fs,N,type)
%==================================================
% 理想FIR I型低通滤波器,wc是截止角频率，阶数M
%==================================================
global Fs
wp = 2*pi*(fp/Fs);
ws = 2*pi*(fs/Fs);
wc = (wp+ws)/2;
N = mod(N+1,2)+N;
M = N-1;
k = 0:M;
if strcmp(type,'high')
    hd = -(wc/pi)*sinc(wc*(k-0.5*M)/pi);
    hd(0.5*M+1) = hd(0.5*M+1)+1;
%     hd = sinc(k-0.5*M)-(wc/pi)*sinc(wc*(k-0.5*M)/pi);
elseif strcmp(type,'low')
    hd = (wc/pi)*sinc(wc*(k-0.5*M)/pi);
else
    disp('error');
    hd = [];
end
end