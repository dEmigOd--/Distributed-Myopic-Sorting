%  n = 2; % sizes of the table
%  m = 6;
%  y_no_vehicle = 1; % set empty cell
%  x_no_vehicle = 1;

n = randi(12); % sizes of the table
m = randi(12);
y_no_vehicle = randi(n); % set empty cell
x_no_vehicle = randi(m);

version_to_run = 101; % apply algo
enable_color_tracking = true;
fakeparam = 0;
pause_for = 0.01;
params = Parameters.SimulationParameters(n, m, true, pause_for, version_to_run, ...
	fakeparam, (255 - [51;255;51]) / 255, (255 - [255;153;153]) / 255, enable_color_tracking);

annilingParams = Parameters.AnnilingParameters;
annilingParams.covg_north_probability = 0.25;
annilingParams.covg_east_probability = 0.25;
annilingParams.covg_south_probability = 0.25;
annilingParams.covg_west_probability = 0.25;
params.anniling_params = annilingParams;

params.collision_solver = 'ALOHA';
params.stop_on_coverage_complete = false;

state = params.vehicle_continue * ones(params.n, params.m);
state(y_no_vehicle, x_no_vehicle) = params.no_vehicle;
%special_indeces = randsample(params.n * params.m, 1);
%state(special_indeces(:)) = params.no_vehicle;
[success, iteration] = RunCoverageAlgorithm(state, params);
