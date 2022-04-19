clc,clear
n=8;
graph=zeros(n);
pos=xlsread('data.xlsx');
for i=1:n
    for j=i+1:n
        graph(i,j)=distance(pos(i,1),pos(i,2),pos(j,1),pos(j,2));
    end
end
graph=graph+graph';
xlswrite('graph.xlsx',graph);