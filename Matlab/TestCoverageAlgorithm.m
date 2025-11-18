% Tests that a specific coverage algorithm runs into coverage and eventual completion
ns = [1;3;5;8];
ms = [1;2;4;7];

starting_pos = [...
			1,1; ...
			1,2; ...
			1,3; ...
			2,1; ...
			2,2; ...
			2,3; ...
			3,1; ...
			3,2; ...
			3,3; ...
			4,5];
		
visual_on = false;
pause_for = 0.1;
test_version = 5;

fprintf('Testing algorithm ...\n');
for ni=1:size(ns, 1)
	for mi=1:size(ms,1)
		if(ns(ni) == 1 && ms(mi) == 1)
			continue;
		end
		fprintf('\tn = %d\tm = %d ...\n', ns(ni), ms(mi));
		for si=1:size(starting_pos, 1)
			params = Parameters.SimulationParameters(ns(ni), ms(mi), visual_on, pause_for, test_version);
            params.stop_on_coverage_complete = true;
			if (starting_pos(si,1) <= ns(ni) && ...
					starting_pos(si,2) <= ms(mi))

				state = params.vehicle_continue * ones(params.n, params.m);
				state(starting_pos(si,1),starting_pos(si,2)) = params.no_vehicle;
				%special_indeces = randsample(params.n * params.m, 1);
				%state(special_indeces(:)) = params.no_vehicle;
				if ~RunCoverageAlgorithm(state, params)
					return;
				end
			end
			if (1 <= ns(ni) - starting_pos(si,1) && ...
					1 <= ms(mi) - starting_pos(si,2) && ...
					(starting_pos(si,1) ~= 1 || starting_pos(si,2) ~= 1))

				state = params.vehicle_continue * ones(params.n, params.m);
				state(1 + end - starting_pos(si,1), 1 + end - starting_pos(si,2)) = params.no_vehicle;
				if ~RunCoverageAlgorithm(state, params)
					return;
				end
			end
			if (starting_pos(si,1) <= ns(ni) && ...
					1 <= ms(mi) - starting_pos(si,2))

				state = params.vehicle_continue * ones(params.n, params.m);
				state(starting_pos(si,1), 1 + end - starting_pos(si,2)) = params.no_vehicle;
				if ~RunCoverageAlgorithm(state, params)
					return;
				end
			end
			if (1 <= ns(ni) - starting_pos(si,1) && ...
					starting_pos(si,2) <= ms(mi))

				state = params.vehicle_continue * ones(params.n, params.m);
				state(1 + end - starting_pos(si,1), starting_pos(si,2)) = params.no_vehicle;
				if ~RunCoverageAlgorithm(state, params)
					return;
				end
			end
		end
	end
end

fprintf('All tests passed!\n');
