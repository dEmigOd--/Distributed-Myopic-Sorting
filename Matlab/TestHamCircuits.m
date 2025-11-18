maxN = 1000;
maxK = 50;
f = 40;

x = (1:maxK)';
eData = ExpectedTime(maxN, x, f);

data = zeros(maxK, 1);
for k = 1:maxK
    [data(k), ~] = RunTube(maxN, k, f, 400);
    if(mod(k, 5) ==0)
        fprintf('%d\n', k);
    end
end

plot(x, data, x, eData, x, maxN * (maxN - x) ./ (x + 1) .* (harmonic(f + x - 1) - harmonic(f - 1)), x, maxN * (maxN - x) ./ (x + 1));
plot(x, data, x, maxN * (maxN - x) ./ (x + 1) .* (harmonic(f + x - 1) - harmonic(f - 1)));

% k = 50;
% [~, exitTimes] = RunTube(maxN, k, f, 5000);
% plot((1:k)', exitTimes(1) ./ [exitTimes(1); diff(exitTimes)]);

function [avgTime, exitTimes] = RunTube(n, k, f, samples)
    totalTime = 0;
    exitTimes = zeros(k, 1);
    
    for i=1:samples
        tube = -1 * ones(n, 1);
        indeces = randperm(n, k + f );
        tube(indeces(1:k)) = 1;
        tube(indeces(k+1:end)) = 0;

        localTime = 0;
        exitIndex = 1;
        while(any(tube == 1))
            shiftable = true;
            movables = sort(find(tube == 0));
            if(tube(1) == 1)
                tube(1) = 0;
                exitTimes(exitIndex) = exitTimes(exitIndex) + localTime;
                exitIndex = exitIndex + 1;
                shiftable = false;
            end
            
            prevState = tube;
            if((movables(end) == n) || ~shiftable)
                from = mod(movables, n) + 1;
                tube(from) = 0;
                tube(movables) = prevState(from);
                localTime = localTime + 1;
            else % speed up the shit
                shiftby = n - max(movables);
                for j = size(movables, 1):-1:1
                    from = movables(j) + (1:shiftby)';
                    tube(movables(j) + shiftby) = 0;
                    tube(from - 1) = prevState(from);
                    prevState = tube;
                end
                localTime = localTime + shiftby;
            end
            
        end
        
        totalTime = totalTime + localTime;
    end
    
    avgTime = totalTime / samples;
    exitTimes = exitTimes / samples;
end

function expTime = ExpectedTime(n, k, f)
    expTime = n .* (n + 1) .* ((harmonic(f + k - 1) - harmonic (f - 1)) ./ (k + 1) + ...
       (harmonic(f + k - 1) - harmonic (f)) ./ (n - k + 1));
end