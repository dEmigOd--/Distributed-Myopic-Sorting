close all;
load('Test/ConvergenceCollectedData100.mat');

success = true(size(CollectedData, 2), 1);

flatFirstColumn = [CollectedData{:, 1}];
maxn = max([flatFirstColumn{1:4:size(flatFirstColumn, 2)}]);
maxm = max([flatFirstColumn{2:4:size(flatFirstColumn, 2)}]);

times = zeros(maxn * maxm, size(CollectedData, 2));
counts = zeros(maxn * maxm, size(CollectedData, 2));

for row=1:size(CollectedData, 1)
    for nalgo = 1:size(CollectedData, 2)
        value = CollectedData{row, nalgo};
        
        if(~isempty(value))
            success(nalgo) = success(nalgo) && value{3};

            times(value{1} * value{2}, nalgo) = times(value{1} * value{2}, nalgo) + value{4};
            counts(value{1} * value{2}, nalgo) = counts(value{1} * value{2}, nalgo) + 1;
        end
    end
end

if(~any(success))
    fprintf('All algorithms processed the input successfully\n');
else
    for nalgo = 1:size(CollectedData, 2)
        if ~success(nalgo)
            fprintf('Algorithm No=%d failed at least once\n', nalgo);
        end
    end
end

X = (1:maxn*maxm);
Y = times ./ counts;

algoVersions = [testDetAlgos; testProbAlgos];
usable = counts(:, 1) > 0;

legendStr = cell(size(CollectedData, 2), 1);
hold on;
for nalgo = 1:size(CollectedData, 2)
    plot(X(usable), Y(usable, nalgo));
    legendStr{nalgo} = sprintf('Algorithm %d', algoVersions(nalgo));
end
hold off

title('Average covering times vs. area');
xlabel('n \times m');
ylabel('average covering time');
legend(legendStr, 'Location', 'NorthWest');

figure;
hold on;
for nalgo = 1:(size(CollectedData, 2) - size(testProbAlgos, 1))
    plot(X(usable), Y(usable, nalgo));
end
hold off

title('Average covering times vs. area (Deterministic algorithms only)');
xlabel('n \times m');
ylabel('average covering time');
legend(legendStr(1:(size(CollectedData, 2) - size(testProbAlgos, 1))), 'Location', 'NorthWest');

figure;
plot(X(usable), Y(usable, end) ./ max(Y(usable, 1:end - 1), [], 2));
title('Ratio between best probabilistic to worst deterministic algorithm vs. area');
xlabel('n \times m');
ylabel('probilistic/deterministic ratio');
