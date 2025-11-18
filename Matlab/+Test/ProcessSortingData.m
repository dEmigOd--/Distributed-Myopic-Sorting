close all;
DataSize = 1000;
load(sprintf('Test/SortingCollectedDataSame%d.mat', DataSize));

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
    legendStr{nalgo} = sprintf('Algorithm %d', available_random_strategies(nalgo));
end
hold off;

title('Algorithm failures as a function of $k$');
xlabel('k');
ylabel('Failures ratio (%)');
legend(legendStr, 'Location', 'NorthEast');

cleanfigure('targetResolution', 200);
matlab2tikz('filename', sprintf('+Test/Images/FailureRatesSame%d.tex', DataSize));

figure;
hold on;
for nalgo = 1:size(Failures, 3)
    plot((1+shouldBeIgnored:size(Failures, 2))', ...
        averageTimes(nalgo, (1+shouldBeIgnored):end) ./ (size(CollectedData, 1) - totalFailures(nalgo, (1+shouldBeIgnored):end)));
end
hold off;

title(sprintf('Average time to completion (on %d runs)', size(CollectedData, 1)));
xlabel('k');
ylabel('Time');
legend(legendStr, 'Location', 'NorthEast');

cleanfigure('targetResolution', 200);
matlab2tikz('filename', sprintf('+Test/Images/CompletionTimesSame%d.tex', DataSize));
