clc,clear
data=xlsread('data.xlsx');
x=data(:,1);
y=data(:,2);
label={'南宁','河内','曼谷','金边','吉隆坡','新加坡','文莱','马尼拉'};
plot(x,y,'o')
hold on;
for i=1:length(x)
   text(x(i),y(i),label{i})
end
sol=xlsread('result_sol.xlsx');
n=size(sol,2)-1;
for i=1:n
    plot([x(sol(i));x(sol(i+1))],[y(sol(i));y(sol(i+1))])
end