clc,clear
data=xlsread('data.xlsx');
x=data(:,1);
y=data(:,2);
label={'����','����','����','���','��¡��','�¼���','����','������'};
plot(x,y,'o')
for i=1:length(x)
   text(x(i),y(i),label{i})
end
A=[x,y];
xlswrite('data.xlsx',A)