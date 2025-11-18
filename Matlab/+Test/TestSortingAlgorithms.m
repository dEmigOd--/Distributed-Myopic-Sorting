enable_color_tracking = true;
fakeparam = 0;
visual_on = false;
pause_for = 0.01;
frequency_of_update = 10;
fail_at_iteration = 20000;
coverage_algo_version = 81;
suppress_output = true;

runs = 1000;
uptok = 40;
startk = 1;

n = 10; % sizes of the table
m = 6;

available_random_strategies = [1; 2; 1];
available_deterministic_strategies = [7; 8];
CollectedData = zeros(runs, uptok, size(available_random_strategies, 1) + size(available_deterministic_strategies, 1) );
Failures = false(runs, uptok, size(available_random_strategies, 1) + size(available_deterministic_strategies, 1));
    
params = Parameters.SimulationParameters(n, m, visual_on, pause_for, coverage_algo_version);
params.suppress_output = suppress_output;
params.frequency_of_update = frequency_of_update;
params.random_sorting_fail_at_iteration = fail_at_iteration;

annilingParams = Parameters.AnnilingParameters;
annilingParams.sort_exit_east_probability = 0.8;
annilingParams.sort_exit_west_probability = 0.1;
% annilingParams.sort_cont_east_probability = 0.2;
% annilingParams.sort_cont_west_probability = 0.6;
annilingParams.sort_change_frequency = 100;
params.anniling_params = annilingParams;

orig_state = Parameters.SimulationParameters.vehicle_continue * ones(n, m);
special_indeces = randsample(n * m, n);
orig_state(special_indeces(:)) = Parameters.SimulationParameters.vehicle_exit;

sort_cont_east_west_probabilitites = [0.2, 0.2, 0.7; 0.6, 0.6, 0.1];

for k = startk:uptok%:-1:1
    fprintf('\n\nStart iteration, k = %d\n', k);
    
    state = orig_state;
    special_indeces = randsample(n * m - n, k);
    unoccupied_indices = find(state ~= Parameters.SimulationParameters.vehicle_exit);
    state(unoccupied_indices(special_indeces(:))) = Parameters.SimulationParameters.no_vehicle;        

    for i = 1:runs
        fprintf('\n\nStart run %d\n', i);
    
        for j = 1:size(available_random_strategies, 1)
            params.anniling_params.sort_cont_east_probability = sort_cont_east_west_probabilitites(1, j);
            params.anniling_params.sort_cont_west_probability = sort_cont_east_west_probabilitites(2, j);
            params.random_strategy_version = available_random_strategies(j);
            [success, iteration] = Random.RunRandomSorting(state, params);
            fprintf('Sorting ended; algo = %d, iteration = %d, success = %d\n', j, iteration, success);
            Failures(i, k, j) = ~success;
            CollectedData(i, k, j) = iteration;
        end
        for j = 1:size(available_deterministic_strategies, 1)
            params.anniling_params.sort_cont_east_probability = sort_cont_east_west_probabilitites(1, j);
            params.anniling_params.sort_cont_west_probability = sort_cont_east_west_probabilitites(2, j);
            params.random_strategy_version = available_random_strategies(j);
            [success, iteration] = Random.RunRandomSorting(state, params);
            fprintf('Sorting ended; algo = %d, iteration = %d, success = %d\n', j, iteration, success);
            Failures(i, k, j) = ~success;
            CollectedData(i, k, j) = iteration;
        end
    end
end

save(sprintf('C:/Users/dmitry.ra/Desktop/Studies/Articles/PhD/NPuzzleModel/Matlab/+Test/SortingCollectedDataSame%d.mat', runs), ...
    'CollectedData', 'Failures', 'available_random_strategies');
