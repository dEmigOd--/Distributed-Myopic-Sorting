function [success] = RunMultipleCoverageAlgorithm(state, params)
	close all;

	check_coverage = state == params.no_vehicle;
    if(~any(any(check_coverage == false)))
        fprintf('Coverage completed before beginning\n');
        return;
    end
	
	if(params.visual_on)
		screen_sizes = get(0, 'ScreenSize');
		wanted_window_size = [540; 900];
		figure('Position', [(screen_sizes(3) - wanted_window_size(1) - 20) ... 
			(screen_sizes(4) - wanted_window_size(2) - 100) ...
			wanted_window_size(1) ...
			wanted_window_size(2)]);
		handl = gca;
	end

	memory = zeros(params.n, params.m);

	success = true;
	
	iteration = 0;
	road_passed = -1 * ones(size(state));
	while(true)
		if(params.visual_on)
			if(params.enable_color_tracking)
				road_to_show = road_passed;
				road_to_show(state == params.no_vehicle) = 0;
				Show.ShowMultiColoredRoad(handl, road_to_show, params);
			else
				Show.ShowRoad(handl, state, params);
			end
		end

		road_passed((state == params.no_vehicle) & (road_passed == -1)) = iteration + 1;
		[state, memory, collided, stop] = Rain.MultipleCoverageAlgorithm(state, memory, params);	
		iteration = iteration + 1;
		if(collided)
			fprintf('Algorithm stopped due to collision\n');
			success = false;
			break;
		end
		if(any(memory(state == params.no_vehicle)))
			fprintf('Memory is hold on non-agent\n');
			success = false;
			break;
		end
		state(check_coverage & (state ~= params.no_vehicle)) = params.vehicle_exit;
		check_coverage(state == params.no_vehicle) = true;
		if(stop)
			if(any(any(check_coverage == false)))
				fprintf('Algorithm stopped, but some cells not covered\n');
				success = false;
			end
			break;
		end

		if(params.visual_on)
			pause(params.pause_for);
		end
	end

	if(params.visual_on)
		if(params.enable_color_tracking)
			road_passed((state == params.no_vehicle) & (road_passed == -1)) = iteration + 1;
			road_to_show = road_passed;
			road_to_show(state == params.no_vehicle) = 0;
			Show.ShowMultiColoredRoad(handl, road_to_show, params);
		else
			Show.ShowRoad(handl, state, params);
		end
		pause(params.pause_for);
	end
	
	fprintf('Algorithm used %d iteration\n', iteration);
	if(success)
		fprintf('Algorithm stopped and all cells covered\n');
	end
end
