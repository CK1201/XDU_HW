function PD=marcumsq(a,b)
max_test_value = 10000;
if(a < b)
    AlphaN0 = 1;
    dn = a / b;
else
    AlphaN0 = 0;
    dn = b / a;
end
% disp(dn)
% AlphaN_1 = 0;
BetaN0 = 0.5;
% batan_1 = 0;
D1=dn;
n=0;
ratio = 2/a/b;
% rl=0;
AlphaN=0;
BetaN=0;
while(BetaN<max_test_value)
    n=n+1;
    AlphaN = dn + ratio * n * AlphaN0 + AlphaN;
    BetaN = 1 + ratio * n * BetaN0 + BetaN;
%     AlphaN_1 = AlphaN0;
    AlphaN0 = AlphaN;
%     batan_1 = BetaN0;
    BetaN0 = BetaN;
    dn = dn * D1;
end
PD=(AlphaN0 / 2 / BetaN0) * exp(-(a - b)^2 / 2);
if(a>=b)
    PD=1-PD;
end