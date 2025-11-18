close all;

n = randi(8); % sizes of the table
m = randi(6);
y_no_vehicle = randi(n); % set empty cell
x_no_vehicle = randi(m);

coverage_algo_version = 102; % apply algo
sorting_algo_version = 3; % apply sorting algo
enable_color_tracking = false;
pause_for = 0.01;
params = Parameters.SimulationParameters(n, m, true, pause_for, coverage_algo_version, ...
	sorting_algo_version, (255 - [51;255;51]) / 255, (255 - [255;153;153]) / 255, enable_color_tracking);

annilingParams = Parameters.AnnilingParameters;
annilingParams.covg_north_probability = 0.25;
annilingParams.covg_east_probability = 0.25;
annilingParams.covg_south_probability = 0.25;
annilingParams.covg_west_probability = 0.25;
params.anniling_params = annilingParams;

params.collision_solver = 'ALOHA';
params.stop_on_coverage_complete = false;
params.sorting__two_columns_algo_version = 3;

uiData = UIData();
uiData.Algorithm = 1;
uiData.SortingAlgorithmVersion = params.sorting_algo_version;
CentralizedUI(uiData, params);