enable_color_tracking = true;
fakeparam = 0;
visual_on = false;
pause_for = 0.01;
frequency_of_update = 10;
fail_at_iteration = 50000;
coverage_algo_version = 81;
suppress_output = true;

runs = 50;
ntrials = 20;
k = 1;

startn = 3; % sizes of the table
endn = 32;
ns = endn - startn;

m = 6;

available_random_strategies = [1];
available_deterministic_strategies = [3];
CollectedData = zeros(runs * ntrials, ns, size(available_random_strategies, 1) + size(available_deterministic_strategies, 1) );
Failures = false(runs * ntrials, ns, size(available_random_strategies, 1) + size(available_deterministic_strategies, 1));
    

for n = startn:endn
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

    sort_cont_east_west_probabilitites = [0.7; 0.1];

        fprintf('\n\nStart iteration, n = %d\n', n);


    for trial = 1:ntrials
        	fprintf('\n\nStart trial %d\n', i);
        state = orig_state;
        special_indeces = randsample(n * m - n, k);
        unoccupied_indices = find(state ~= Parameters.SimulationParameters.vehicle_exit);
        state(unoccupied_indices(special_indeces(:))) = Parameters.SimulationParameters.no_vehicle;        

        fprintf('Random algo: \n');
        for i = 1:runs
            fprintf('\n\nStart run %d\n', i);

            for j = 1:size(available_random_strategies, 1)
                params.anniling_params.sort_cont_east_probability = sort_cont_east_west_probabilitites(1, j);
                params.anniling_params.sort_cont_west_probability = sort_cont_east_west_probabilitites(2, j);
                params.random_strategy_version = available_random_strategies(j);
                [success, iteration] = Random.RunRandomSorting(state, params);
                fprintf('Sorting ended; algo = %d, iteration = %d, success = %d\n', j, iteration, success);
                Failures((trial - 1) * runs + i, n - startn + 1, j) = ~success;
                CollectedData((trial - 1) * runs + i, n - startn + 1, j) = iteration;
            end
        end
        fprintf('Deterministic algo: \n');
        for j = 1:size(available_deterministic_strategies, 1)
            params.anniling_params.sort_cont_east_probability = sort_cont_east_west_probabilitites(1, j);
            params.anniling_params.sort_cont_west_probability = sort_cont_east_west_probabilitites(2, j);
            params.sorting_algo_version = available_deterministic_strategies(j);
            [success, iteration] = RunSortingAlgorithm(state, params);
            fprintf('Sorting ended; algo = %d, iteration = %d, success = %d\n', j, iteration, success);
            Failures((trial - 1) * runs + 1:trial * runs, n - startn + 1, size(available_random_strategies, 1) + j) = ~success;
            CollectedData((trial - 1) * runs + 1:trial * runs, n - startn + 1, size(available_random_strategies, 1) + j) = iteration;
        end
    end
end

save(sprintf('C:/Users/dmitry.ra/Desktop/Studies/Articles/PhD/NPuzzleModel/Matlab/+Test/SortingCollectedDatawDeterm%d.mat', runs), ...
    'CollectedData', 'Failures', 'available_random_strategies', 'available_deterministic_strategies');
