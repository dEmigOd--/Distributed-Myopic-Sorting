k = 3;
f = 1;
maxN = 3000;
samples = 1000;

data = zeros(maxN, 1);

x = (100:100:maxN)';
for n = 100:100:maxN
    data(n) = RandomAverage(n, k, samples);
    if(mod(n, 100) == 0)
        fprintf('n = %d\n', n);
    end
end

plot(x, data(x), x, harmonic(k) * x .* (x - k) / (k + 1));
title(sprintf('Expected completion time vs. n (k = %d)', k));
xlabel('Length of tube (n)');
ylabel('Expected completion time');
legend({'measured', 'expected'}, 'Location', 'northwest');

function avgTime = CalcAverage(n, k, ~)
    totalSum = 0;
    for a1 = 0:(n-1)
        for a2 = (a1+1):(n-1)
            for a3 = (a2+1):(n-1)
                totalSum = totalSum + (a3 - a2) / 3 + (a2 - a1) / 2 + a1;
            end
        end
    end
    
    avgTime = factorial(k) * totalSum / ((n - 1) * (n - 2)) + k;
end

function avgTime = RandomAverage(n, k, samples)
    weights = 1 ./ (1:k);
    
    totalTime = 0;
    for i = 1:samples
        coefficients = sort(randsample(n, k));
        elements = [coefficients(1); diff(coefficients)];
        totalTime =  totalTime + weights * elements * n + k;
    end
    
    avgTime = totalTime / samples;
end
