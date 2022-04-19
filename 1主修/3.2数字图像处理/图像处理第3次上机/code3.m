clc,clear
close all
I=imread('图片1.jpg');     %读图
rotI=rgb2gray(I);               %rgb转灰度图
BW=edge(rotI,'prewitt');
[H,T,R]=hough(BW);
subplot(1,2,1);
imshow(H,[],'XData',T,'YData',R,'InitialMagnification','fit');
title('霍夫变换图');
xlabel('\theta'),ylabel('\rho');
axis on , axis normal, hold on;
P=houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
x=T(P(:,2));y=R(P(:,1));
plot(x,y,'s','color','white');
lines=houghlines(BW,T,R,P,'FillGap',5,'MinLength',7);
subplot(1,2,2);,imshow(rotI);
title('霍夫变换图像检测');
axis on;
hold on;
max_len=0;
for k=1:length(lines)
    xy=[lines(k).point1;lines(k).point2];
    plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
    plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
    plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
    len=norm(lines(k).point1-lines(k).point2);
    if(len>max_len)
        max_len=len;
        xy_long=xy;
    end
end
plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','cyan');