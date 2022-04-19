function [C,B,A] = tf2par(b,a)
%直接型到并联型转换
M = length(b);
N = length(a);
[r1,p1,C] = residuez(b,a);

p = cplxpair(p1,1e-9);
I = cplxcomp(p1,p);
r = r1(I);

K = floor(N/2);
B = zeros(K,2);
A = zeros(K,3);

if K*2 == N
    for i = 1:2:N-2
        pi = p(i:i+1,:);
        ri = r(i:i+1,:);
        [Bi,Ai] = residuez(ri,pi,[]);
        B(fix((i+1)/2),:) = real(Bi);
        A(fix((i+1)/2),:) = real(Ai);
    end
    [Bi,Ai] = residuez()
    B(K,:) = [real(Bi) 0];
    A(K,:) = [real(Ai) 0];
else
    for i = 1:2:N-1
        pi = p(i:i+1,:);
        ri = r(i:i+1,:);
        [Bi,Ai] = residuez(ri,pi,[]);
        B(fix((i+1)/2),:) = real(Bi);
        A(fix((i+1)/2),:) = real(Ai);
    end
end

end

