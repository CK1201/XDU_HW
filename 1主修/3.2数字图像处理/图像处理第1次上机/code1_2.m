clc,clear
close all
%% lena
lena=imread('lena.png');
lena=double(rgb2gray(lena))/255;
%% 直方图均衡
lena_balancing=histeq(lena);
figure()
subplot(1,2,1)
imshow(lena);
subplot(1,2,2)
imshow(lena_balancing);
%% 加噪声
lena_noise=lena+0.1*randn(size(lena,1),size(lena,2));
figure()
subplot(1,3,1)
imshow(lena);
subplot(1,3,2)
imshow(lena_noise)
%% 4-邻域平均法
lena_filter=lena_noise;
for m=2:size(lena_filter,1)-1
    for n=2:size(lena_filter,2)-1
        lena_filter(m,n)=(lena_noise(m-1,n)+lena_noise(m+1,n)+lena_noise(m,n-1)+lena_noise(m,n+1))/4;
    end
end
subplot(1,3,3)
imshow(lena_filter)
%% 锐化
a=2;
W=[0,-a,0;-a,1+4*a,-a;0,-a,0];
lena_sharpen=lena;
for m=2:size(lena_sharpen,1)-1
    for n=2:size(lena_sharpen,2)-1
        lena_sharpen(m,n)=sum(sum(lena(m-1:m+1,n-1:n+1).*W));
    end
end
figure()
subplot(1,2,1)
imshow(lena);
subplot(1,2,2)
imshow(lena_sharpen);