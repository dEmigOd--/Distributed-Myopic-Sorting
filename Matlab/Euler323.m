sum = 0;
count = 0;

for i=1:1000000
    iter = DoIt(32);
    count = count + 1;
    sum =sum + iter;
    fprintf("%.10f\n", sum / count);
end

function [iterations] = DoIt(bits)
    iterations = 0;
    acc = de2bi(0, bits);
    while(sum(acc) ~= bits)
        acc = acc | de2bi(randi(2 ^ bits) - 1, bits);
        iterations = iterations + 1;
    end
end


% for j=1:80
%     fprintf("%.10f\n", CalcSum(j, 2));
% end
% 
% function [sum] = CalcSum(n, m)
%     sum = 0;
%     for i=1:n
%         sum = sum + 1 - (1 - (1/2)^i)^m;
%     end
% end
