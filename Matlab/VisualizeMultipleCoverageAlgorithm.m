% n = 30; % sizes of the table
% m = 30;
n = 2 + randi(20); % sizes of the table
m = 3 + randi(20);

coverage_algo_version = 1002; % apply algo
no_sorting_version = 0;
pause_for = 0.01;
color_exit = (255 - [255;255;0]) / 255;
color_continue = (255 - [0;223;194]) / 255;
enable_color_tracking = false;

params = Parameters.SimulationParameters(n, m, true, pause_for, coverage_algo_version, no_sorting_version, color_exit, color_continue, ...
	enable_color_tracking);

state = params.vehicle_continue * ones(params.n, params.m);
%special_indeces = [11;12;15;22;44;47;70];
%special_indeces = [1;7;62;66;70];
%special_indeces = [2;4;5;14;16;19;24;29;37;44;47;52;55;59;60;66];
%special_indeces = [29;31;43;65;71;76]; % collision
%special_indeces = [145;216;247;61;142;229;255;240;14;219;181;90;45;93;8];
%special_indeces = [1;2;3;4;5;6;7;8]; % bad case
%special_indeces = randsample(params.n * params.m, 300);
special_indeces = randsample(params.n * params.m, 1 + randi(n + m));
state(special_indeces(:)) = params.no_vehicle;

RunMultipleCoverageAlgorithm(state, params);
