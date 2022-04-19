clc,clear
close all
%% 
image1=zeros(500,500);
image1(100:400,200:300)=1;
figure()
subplot(1,3,1)
imshow(image1);
%% 2D-DFT
% image2=zeros(size(image1,1),size(image1,2));
% N=size(image1,1)*size(image1,2);
% for u=1:size(image1,1)
%     for v=1:size(image1,2)
%         for m=1:size(image1,1)
%             for n=1:size(image1,2)
%                 image2(u,v)=image2(u,v)+image1(m,n)*exp(-1i*2*pi/N*(m*u+n*v));
%             end
%         end
%     end
%     disp(u)
% end
% image2=image2/N;
image2=fft2(image1);
subplot(1,3,2)
imshow(abs(image2));
%% 中心化
image3=image1;
for m=1:size(image3,1)
    for n=1:size(image3,2)
        image3(m,n)=image3(m,n)*(-1)^(m+n);
    end
end
image3=fft2(image3);
subplot(1,3,3)
imshow(abs(image3));
%% 旋转45°
degree=-45;
rotate45=[cosd(degree),-sind(degree);sind(degree),cosd(degree)];
% image4=image1*rotate;
image4=zeros(size(image1,1),size(image1,2));
c=[size(image1,1)/2,size(image1,2)/2];
for m=1:size(image1,1)
    for n=1:size(image1,2)
          p=[m;n];
          pp = round(rotate45*(p-c)+c);
          if (pp(1) >= 1 && pp(1) <= size(image1,1) && pp(2) >= 1 && pp(2) <= size(image1,2))
              image4(pp(1),pp(2)) = image1(m, n); 
          end
    end
end
%填充
for m=2:size(image1,1)-1
    for n=2:size(image1,2)-1
        if sum(sum(image4(m-1:m+1,n-1:n+1)))>=4
            image4(m,n)=1;
        end
    end
end
figure()
subplot(1,3,1)
imshow(image1)
subplot(1,3,2)
imshow(image4)
%% 
image5=fft2(image4);
subplot(1,3,3)
imshow(abs(image5));
