n = 10;
m = 6;
y_no_vehicle = 2; % set empty cell
x_no_vehicle = 5;
% n = 2 + randi(15); % sizes of the table
% m = 3 + randi(12);
% y_no_vehicle = randi(n); % set empty cell
% x_no_vehicle = randi(m);

coverage_algo_version = 81; % apply coverage algo
sorting_algo_version = 4; % apply sorting algo
pause_for = 0.01;

params = Parameters.SimulationParameters(n, m, true, pause_for, coverage_algo_version, sorting_algo_version);

if(true)
	state = params.vehicle_continue * ones(params.n, params.m);
	state(y_no_vehicle, x_no_vehicle) = params.no_vehicle;
    available_indexes = find(state ~= params.no_vehicle);
	% state(available_indexes(randsample(numel(available_indexes), params.n))) = params.vehicle_exit;
	% state([11;46;75;80;89;104;106;118;133;148;168;182;192;193;194]) = params.vehicle_exit; % loops in ver 4 [15,13,15,6]
	state([21;31;32;33;34;41;51;52;53;54]) = params.vehicle_exit;
	% state([4;11;14;23;25;35;43;63;64;77]) = params.vehicle_exit;
	% state([1:9,70]) = params.vehicle_exit;
	% state([1:10:61,160,151,152]) = params.vehicle_exit;
	% state([61,71,73:80]) = params.vehicle_exit;
	% state([3;14;32;53;55;57;60;61;75;78]) = params.vehicle_exit;
	% state([2;11;40;73;74;75;76;77;78;79]) = params.vehicle_exit;
	% state([39;71;72;73;74;75;76;77;78;79]) = params.vehicle_exit;
	% state([4;6;14;19;21;40;48;71]) = params.vehicle_exit;
	% state([7;8;9;19;20;34;58;65]) = params.vehicle_exit;
	% state([37;38;39;40;41;42;43;44;45;49;56;68]) = params.vehicle_exit;
	% state([3;4;6;7;9;17;19;22;23;32;39;42;46;48;52;55;56;57;60;61;62;63;65;66;69;71;76;77;80;83;84;95]) = params.vehicle_exit;
	% state([3;12;21;30;39;41;42;47]) = params.vehicle_exit;
	% state(1:8) = params.vehicle_exit;
	% state([4;5;2;3;1;7]) = params.vehicle_exit; % (m, n) = (6, 2), start at (2, 6)
	% state((1:32)') = params.vehicle_exit; % (m, n) = (6, 2), start at (2, 6)
	% state([3;12;13;38;41;42;47;48]) = params.vehicle_exit;
	% state([45;46;47;48;49;59;51;52;61;62]) = params.vehicle_exit;
	% state([45:74]) = params.vehicle_exit;
	if(sum(sum(state == params.vehicle_exit)) + sum(sum(state == params.no_vehicle)) ~= params.n + 1)
		fprintf('Wrong number of vehicles supplied\n');
		return;
	end
end

saved_state = state;
RunSortingAlgorithm(state, params);

% debug_memory = [ ...
% 	0,0,0,1,1,1,1,3;
% 	0,1,0,2,2,2,2,3;
% 	2,1,0,2,2,2,2,3;
% 	2,1,0,2,2,2,2,3;
% 	2,1,2,2,2,2,2,3;
% 	2,1,2,2,2,2,0,3;
% 	2,1,0,0,2,2,2,3;
% 	2,1,0,0,2,2,2,3;
% 	2,1,1,1,2,2,2,3;
% 	1,1,1,1,1,1,1,3
% 	];
% RunSortingAlgorithm(state, params, debug_memory);
