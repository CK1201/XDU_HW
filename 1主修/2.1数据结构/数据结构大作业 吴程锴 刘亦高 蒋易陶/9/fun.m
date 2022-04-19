function E=fun(circle)
global graph
global n
n=8;
length=0;
for i=1:n
    length=length+graph(circle(i),circle(i+1));
end
E=length;