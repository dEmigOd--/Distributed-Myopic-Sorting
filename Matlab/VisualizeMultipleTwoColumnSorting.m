n = 27;
m = 2;
% y_no_vehicle = 2; % set empty cell
% x_no_vehicle = 7;
% n = 2 + randi(15); % sizes of the table
% m = 3 + randi(12);
% y_no_vehicle = randi(n); % set empty cell
% x_no_vehicle = randi(m);
p = 20; % num of exiting vehicles
k = 1; % num of empty cells

%if (p > n || (p + k) > 2 * n)
%    error('Parameters are wrong');
%end

coverage_algo_version = 81; % apply coverage algo
sorting_algo_version = 4; % apply sorting algo
pause_for = 0.001;

params = Parameters.SimulationParameters(n, m, true, pause_for, coverage_algo_version, sorting_algo_version);
params.sorting__two_columns_algo_version = 2;

state = params.vehicle_continue * ones(params.n, params.m);
% state([1:(n/2)-1,n+1:1.5*n]) = params.vehicle_exit;
% state(10) = params.no_vehicle;
state(randsample(numel(state), p)) = params.vehicle_exit;
available_indexes = find(state ~= params.vehicle_exit);
state(available_indexes(randsample(numel(available_indexes), k))) = params.no_vehicle;

saved_state = state;
RunSortingAlgorithm(state, params);
