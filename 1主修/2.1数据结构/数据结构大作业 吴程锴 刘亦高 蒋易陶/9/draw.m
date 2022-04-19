clc,clear
data=xlsread('data.xlsx');
x=data(:,1);
y=data(:,2);
label={'南宁','河内','曼谷','金边','吉隆坡','新加坡','文莱','马尼拉'};
plot(x,y,'o')
for i=1:length(x)
   text(x(i),y(i),label{i})
end
A=[x,y];
xlswrite('data.xlsx',A)