function I = cplxcomp(p1,p2)
I = [];
for j = 1:length(p2)
    for i = 1:length(p1)
        if(abs(p1(i)-p2(j))<0.0001)
            I = [I,i];
        end
    end
end
I = I';
end

