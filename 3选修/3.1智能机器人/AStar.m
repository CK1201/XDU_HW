function [route,dis,RouteMap,RunTime]=AStar(map,NodeStart,NodeEnd,weight)
%% 初始化
dis=0;
Parent_m=-ones(size(map,1),size(map,1));
Parent_n=-ones(size(map,1),size(map,1));
Parent_m(NodeStart(1),NodeStart(2))=NodeStart(1);
Parent_n(NodeStart(1),NodeStart(2))=NodeStart(2);
Distance=1./zeros(size(map,1),size(map,1));
Distance(NodeStart(1),NodeStart(2))=0;
Visited=ones(size(map,1),size(map,1));
DisPre=map;
for i=1:size(map,1)
    for j=1:size(map,1)
        if(DisPre(i,j)==1)
            DisPre(i,j)=inf;
        else
            DisPre(i,j)=sqrt(abs(NodeEnd(1)-i)^2+abs(NodeEnd(2)-j)^2);
        end
    end
end
DisAStar=DisPre+Distance;

%% A*
t1=clock;
tic
while(Visited(NodeEnd(1),NodeEnd(2))~=9999)
    temp=Visited.*DisAStar;
    [m,n]=find(temp==min(min(temp)));
    m=m(1);
    n=n(1);
    Visited(m,n)=9999;
    %更新八个方向
    if(m-1~=0 && map(m-1,n)==0)
        if(Distance(m-1,n)>Distance(m,n)+1)
            Distance(m-1,n)=Distance(m,n)+1;
            Parent_m(m-1,n)=m;
            Parent_n(m-1,n)=n;
        end
    end
    if(n-1~=0 && map(m,n-1)==0)
        if(Distance(m,n-1)>Distance(m,n)+1)
            Distance(m,n-1)=Distance(m,n)+1;
            Parent_m(m,n-1)=m;
            Parent_n(m,n-1)=n;
        end
    end
    if(m+1~=size(map,1)+1 && map(m+1,n)==0)
        if(Distance(m+1,n)>Distance(m,n)+1)
            Distance(m+1,n)=Distance(m,n)+1;
            Parent_m(m+1,n)=m;
            Parent_n(m+1,n)=n;
        end
    end
    if(n+1~=size(map,2)+1 && map(m,n+1)==0)
        if(Distance(m,n+1)>Distance(m,n)+1)
            Distance(m,n+1)=Distance(m,n)+1;
            Parent_m(m,n+1)=m;
            Parent_n(m,n+1)=n;
        end
    end
    %斜向
    if(m-1~=0 && n-1~=0 && map(m-1,n-1)==0)
        if(Distance(m-1,n-1)>Distance(m,n)+1)
            Distance(m-1,n-1)=Distance(m,n)+sqrt(2);
            Parent_m(m-1,n-1)=m;
            Parent_n(m-1,n-1)=n;
        end
    end
    if(m+1~=size(map,1)+1 && n-1~=0 && map(m+1,n-1)==0)
        if(Distance(m+1,n-1)>Distance(m,n)+1)
            Distance(m+1,n-1)=Distance(m,n)+sqrt(2);
            Parent_m(m+1,n-1)=m;
            Parent_n(m+1,n-1)=n;
        end
    end
    if(m+1~=size(map,1)+1 && n+1~=size(map,2)+1 && map(m+1,n)==0)
        if(Distance(m+1,n+1)>Distance(m,n)+1)
            Distance(m+1,n+1)=Distance(m,n)+sqrt(2);
            Parent_m(m+1,n+1)=m;
            Parent_n(m+1,n+1)=n;
        end
    end
    if(m-1~=0 && n+1~=size(map,2)+1 && map(m,n+1)==0)
        if(Distance(m-1,n+1)>Distance(m,n)+1)
            Distance(m-1,n+1)=Distance(m,n)+sqrt(2);
            Parent_m(m-1,n+1)=m;
            Parent_n(m-1,n+1)=n;
        end
    end
    DisAStar=weight*DisPre+Distance;
end
t2=clock;
t=toc;
RunTime=etime(t2,t1);
RunTime=t;
m=NodeEnd(1);
n=NodeEnd(2);
i=1;
while(m~=NodeStart(1) || n~=NodeStart(2))
    route(1,i)=m;
    route(2,i)=n;
    i=i+1;
    map(m,n)=0.5;
    tempm=Parent_m(m,n);
    tempn=Parent_n(m,n);
    dis=dis+sqrt((tempm-m)^2+(tempn-n)^2);
    m=tempm;
    n=tempn;
    
end
map(NodeStart(1),NodeStart(2))=0.7;
map(NodeEnd(1),NodeEnd(2))=0.7;
RouteMap=map;