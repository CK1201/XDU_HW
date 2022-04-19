function dw=fun(t,w)
global q
global B
global E
global m
dw=zeros(6,1);
dw(1)=w(2);
dw(2)=q*B/m*w(4);
dw(3)=w(4);
dw(4)=q*E/m-q*B/m*w(2);
dw(5)=w(6);
dw(6)=0;