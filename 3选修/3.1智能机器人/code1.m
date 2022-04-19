clc,clear
close all
%% 
flag=1;
MapSize=24;
BlockNum=10;
weight=0.001;
if flag==1
    %自定义地图
    NodeStart=[1,1];
    NodeEnd=[23,23];
    map =[
        
    0.7	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
    0	0	0	0	0	0	1	1	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0
    0	0	0	0	0	0	0	1	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0
    0	0	0	1	0	0	0	1	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0
    0	0	0	0	0	0	1	1	0	1	1	0	0	0	0	0	0	0	0	0	0	0	0	0
    0	0	0	0	0	0	1	0	0	1	1	1	1	1	1	1	1	1	1	0	1	1	1	0
    0	0	0	0	0	0	1	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0
    0	0	0	0	0	0	1	0	0	0	1	1	1	0	0	0	1	1	1	1	1	0	0	0
    1	1	1	1	1	0	1	1	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0
    0	0	0	0	0	0	0	1	0	0	1	0	0	0	1	1	1	1	0	1	1	1	1	1
    0	0	0	0	0	0	0	1	1	0	1	1	1	1	1	0	0	0	0	0	0	0	0	0
    0	0	0	0	0	0	1	1	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0
    0	0	0	0	0	0	0	1	1	1	0	0	0	0	1	0	0	0	0	0	0	0	0	0
    0	0	0	0	1	1	1	1	0	1	0	0	0	1	1	0	0	0	0	0	0	0	0	0
    0	0	0	1	1	0	0	1	0	0	0	0	0	0	1	0	0	0	1	1	1	1	1	1
    0	0	1	1	0	0	0	1	0	0	0	0	0	0	1	0	0	0	1	0	0	0	0	0
    0	1	1	0	0	0	0	1	0	0	0	0	0	0	1	0	1	0	0	0	0	0	0	0
    0	1	0	0	0	0	0	1	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0
    0	0	0	0	0	0	0	1	0	0	0	0	1	1	1	0	0	1	0	0	0	0	0	0
    0	0	0	0	0	0	0	1	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0
    0	0	0	0	0	0	0	1	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0
    0	0	0	0	0	0	0	1	0	0	0	0	1	0	0	0	0	1	0	0	0	0	0	0
    0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0.7	0
    0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0
    ];
else
    %随机地图
    map=zeros(MapSize,MapSize);
    MapSize=MapSize-1;
    NodeStart=[1,1];
    NodeEnd=[MapSize,MapSize];
%     NodeStart=[ceil(rand*MapSize),ceil(rand*MapSize)];
%     NodeEnd=[ceil(rand*MapSize),ceil(rand*MapSize)];
    while(NodeStart(1)==NodeEnd(1) && NodeStart(2)==NodeEnd(2))
        NodeStart=[ceil(rand*MapSize),ceil(rand*MapSize)];
        NodeEnd=[ceil(rand*MapSize),ceil(rand*MapSize)];
    end
    Block=ceil(rand(2,BlockNum)*MapSize);
    for i=1:BlockNum
        map(Block(1,i),Block(2,i))=1;
    end
    map(NodeStart(1),NodeStart(2))=0;
    map(NodeEnd(1),NodeEnd(2))=0;
end
figure()
pcolor(map)
axis ij
%% 
[route,dis,RouteMap,RunTime]=AStar(map,NodeStart,NodeEnd,weight);
figure()
pcolor(RouteMap)
axis ij
%% 权重对总路程和运行时间的影响
AllWeight=0.001:0.01:30;
RunTime=zeros(1,length(AllWeight));
Dis=RunTime;
for i=1:length(AllWeight)
    disp(num2str(AllWeight(i)))
    [route,Dis(i),RouteMap,RunTime(i)]=AStar(map,NodeStart,NodeEnd,AllWeight(i));
end
figure()
plot(AllWeight,RunTime,'linewidth',2)
xlabel('权重');
ylabel('时间(s)');
set(gca,'FontWeight','bold','FontSize',10)
figure()
plot(AllWeight,Dis,'linewidth',2)
xlabel('权重');
ylabel('最短路程');
set(gca,'FontWeight','bold','FontSize',10)

