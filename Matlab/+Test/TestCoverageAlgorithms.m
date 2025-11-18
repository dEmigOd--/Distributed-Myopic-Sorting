testDetAlgos = [ 5; 6; 7; 8; 81; 101; 102 ];
testProbAlgos = [ 201 ];

test1BitAlgos = [101; 102];
needToBeStoppedOnCoverage = [101, 201];

runs = 10;

CollectedData = cell(runs, size(testDetAlgos, 1) + size(testProbAlgos, 1));

enable_color_tracking = true;
fakeparam = 0;
pause_for = 0.01;
visual_on = false;
suppress_output = true;

for i = 1:runs
    fprintf('\n\nStart run %d\n', i);
    while(true)
        n = randi(12); % sizes of the table
        m = randi(12);
        if(n + m > 2)
            break;
        end
    end
    y_no_vehicle = randi(n); % set empty cell
    x_no_vehicle = randi(m);

    state = Parameters.SimulationParameters.vehicle_continue * ones(n, m);
    state(y_no_vehicle, x_no_vehicle) = Parameters.SimulationParameters.no_vehicle;

    for nalgo = 1:size(testDetAlgos, 1)
        version_to_run = testDetAlgos(nalgo); % apply algo
        if((n == 1 || m == 1) && ismember(version_to_run, test1BitAlgos))
            continue;
        end
        params = Parameters.SimulationParameters(n, m, visual_on, pause_for, version_to_run, ...
            fakeparam, (255 - [51;255;51]) / 255, (255 - [255;153;153]) / 255, enable_color_tracking);
        
        params.suppress_output = suppress_output;
        params.stop_on_coverage_complete = ismember(version_to_run, needToBeStoppedOnCoverage) || (n == 1);

        [success, iterations] = Test.TestDetermenisticCoverageAlgorithm(state, params);
        CollectedData{i, nalgo} = { params.n, params.m, success, iterations };
    end
    
    for nalgo = 1:size(testProbAlgos, 1)
        version_to_run = testProbAlgos(nalgo); % apply algo
        params = Parameters.SimulationParameters(n, m, visual_on, pause_for, version_to_run, ...
            fakeparam, (255 - [51;255;51]) / 255, (255 - [255;153;153]) / 255, enable_color_tracking);

        params.suppress_output = suppress_output;
        params.stop_on_coverage_complete = ismember(version_to_run, needToBeStoppedOnCoverage);

        [success, iterations] = Test.TestAnnilingCoverageAlgorithm(state, params);
        CollectedData{i, size(testDetAlgos, 1) + nalgo} = { params.n, params.m, success, iterations };
    end
    
end

save(sprintf('C:/Users/dmitry.ra/Desktop/Studies/Articles/PhD/NPuzzleModel/Matlab/+Test/ConvergenceCollectedData%d.mat', runs), ...
    'CollectedData', 'testDetAlgos', 'testProbAlgos');

