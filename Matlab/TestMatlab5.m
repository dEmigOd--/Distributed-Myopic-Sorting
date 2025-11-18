n = 1000000;

s = 0;
for i = 1:sqrt(n)
    for j = 1:i
        s = s + i  * j;
    end
end

fprintf('s = %d\n', s);
