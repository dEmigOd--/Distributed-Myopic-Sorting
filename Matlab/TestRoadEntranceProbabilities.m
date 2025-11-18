n = 16;
k = 10; % check out 1 more than sources
deltaK = 4;
niter = 10000;

totalPercentage = zeros(niter, 1);
totalFailures = 0;
for iter=1:niter
    carsn = binornd(1, 1 / (k + deltaK), n * k, 1);
    if sum(carsn) > n
        disp(sum(carsn));
    end
    totalFailures = totalFailures + (sum(carsn) > n);
    totalPercentage(iter, 1) = totalFailures / iter;
end

plot((101:niter)', totalPercentage(101:10000));