clc,clear;
global graph
global n
graph=xlsread('graph.xlsx');%read graph
n=size(graph,1);
%随机生成处解
sol_new=[1:n 1];
for i=1:10
    m=ceil(rand()*(n-1)+1);
    n=ceil(rand()*(n-1)+1);
    temp=sol_new(m);
    sol_new(m)=sol_new(n);
    sol_new(n)=temp;
end
sol_best=sol_new;
sol_current=sol_new;
Etemp=fun(sol_new);
Ebest=Etemp;
Ecurrent=Etemp;
%init
t0=97;tf=3;L=10000;t=t0;at=0.99;
%main code
tic
i=1;
while t>=tf
    for k=1:L
        if(rand()<0.5)
            %two exchange
            c1=ceil(rand()*(n-1)+1);
            c2=ceil(rand()*(n-1)+1);
            while(c1==c2)
                c1=ceil(rand()*(n-1)+1);
                c2=ceil(rand()*(n-1)+1);
            end
            temp=sol_new(c1);
            sol_new(c1)=sol_new(c2);
            sol_new(c2)=temp;
        else
            %three exchange
            %make c1!=c2!=c3
            c1=ceil(rand()*(n-1)+1);
            c2=ceil(rand()*(n-1)+1);
            c3=ceil(rand()*(n-1)+1);
            while(c1==c2)||(c2==c3)||(c1==c3)||(abs(c1-c2)==1)
                c1=ceil(rand()*(n-1)+1);
                c2=ceil(rand()*(n-1)+1);
                c3=ceil(rand()*(n-1)+1);
            end
            %make c1<c2<C3
            temp1=c1;
            temp2=c2;
            temp3=c3;
            if (c1<c2)&&(c2<c3)
            elseif (c1<c3)&&(c3<c2)
                c2=temp3;c3=temp2;
            elseif (c2<c1)&&(c1<c3)
                c1=temp2;c2=temp1;
            elseif (c2<c3)&&(c3<c1)
                c1=temp2;c2=temp3;c3=temp1;
            elseif (c3<c1)&&(c1<c2)
                c1=temp3;c2=temp1;c3=temp2;
            elseif (c3<c2)&&(c2<c1)
                c1=temp3;c2=temp2;c3=temp1;
            end
            templist=sol_new((c1+1):(c2-1));
            sol_new((c1+1):(c1+c3-c2+1))=sol_new(c2:c3);
            sol_new((c1+c3-c2+2):c3)=templist;
        end
        Etemp=fun(sol_new);
        %记录历代能量
        Ehis(i)=Ecurrent;
        i=i+1;
        if(Etemp<Ecurrent)
            Ecurrent=Etemp;
            sol_current=sol_new;
            if(Etemp<Ebest)
                Ebest=Etemp;
                sol_best=sol_new;
            end
        else
            if rand<exp(-(Etemp-Ecurrent)./t)
                Ecurrent=Etemp;
                sol_current=sol_new;
            else
                sol_new=sol_current;
            end
        end
    end
    t=t.*at;
end
toc
%存结果
xlswrite('result_sol.xlsx',sol_best);
xlswrite('result_E.xlsx',Ebest);
plot(1:i-1,Ehis);
xlabel('代数')
ylabel('能量')
disp(sol_best)
disp(Ebest)