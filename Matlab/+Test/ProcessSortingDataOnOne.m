close all;
DataSize = 50;
load(sprintf('Test/SortingCollectedDatawDeterm%d.mat', DataSize));

success = true(size(CollectedData, 2), 1);

totalFailures = zeros(size(Failures, 3), size(Failures, 2));
averageTimes = zeros(size(CollectedData, 3), size(CollectedData, 2));
meaningfulCollectedData = CollectedData;
meaningfulCollectedData(Failures) = 0;

for nalgo = 1:size(Failures, 3)
    totalFailures(nalgo, :) = sum(Failures(:, :, nalgo), 1);
    averageTimes(nalgo, :) = sum(meaningfulCollectedData(:, :, nalgo), 1);
end

shouldBeIgnored = sum(max(max(CollectedData, [], 1), [], 3) == 0);
legendStr = cell(size(CollectedData, 3), 1);
hold on;
for nalgo = 1:size(Failures, 3)
    plot((1+shouldBeIgnored:size(Failures, 2))', totalFailures(nalgo, (1+shouldBeIgnored):end) / size(Failures, 1) * 100);
end
hold off;

for nalgo = 1:size(available_random_strategies, 1)
    legendStr{nalgo} = sprintf('Random Algorithm %d', available_random_strategies(nalgo));
end
for nalgo = 1:size(available_deterministic_strategies, 1)
    legendStr{size(available_random_strategies, 1) + nalgo} = sprintf('Deterministic Algorithm %d', available_deterministic_strategies(nalgo));
end

title('Algorithm failures as a function of $n$');
xlabel('n');
ylabel('Failure rate, %');
legend(legendStr, 'Location', 'NorthWest');

cleanfigure('targetResolution', 200);
matlab2tikz('filename', sprintf('+Test/Images/FailureRatesOnOne%d.tex', DataSize));

figure;
hold on;
for nalgo = 1:size(Failures, 3)
    plot((1+shouldBeIgnored:size(Failures, 2))', ...
        averageTimes(nalgo, (1+shouldBeIgnored):end) ./ (size(CollectedData, 1) - totalFailures(nalgo, (1+shouldBeIgnored):end)));
end
hold off;

title('Average time to completion');
xlabel('n');
ylabel('Time');
legend(legendStr, 'Location', 'NorthWest');

cleanfigure('targetResolution', 200);
matlab2tikz('filename', sprintf('+Test/Images/CompletionTimesOnOne%d.tex', DataSize));

