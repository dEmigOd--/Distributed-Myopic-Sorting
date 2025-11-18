function [success, iteration] = RunCoverageAlgorithm(state, params)
	close all;

	success = true;
	iteration = 0;
	check_coverage = state == params.no_vehicle;
    if(~Utility.Helper.Any(check_coverage == false))
        fprintf('Coverage completed before beginning\n');
        return;
    end
	
	if(params.visual_on)
		figure('units','normalized','outerposition',[0.2 0.2 0.8 0.8]);
		handl_table = subplot(1,2,1);
		%figure;%('Position', [960 60 540 900]);
		handl_memory = subplot(1,2,2);
	end

	memory = zeros(params.n, params.m);

    passed_iteration = 0;
	hitMap = zeros(size(state));
	while(true)
		if(params.visual_on)
			if(params.enable_color_tracking)
				heatMap = hitMap - min(min(hitMap)) + 1;
				heatMap(state == params.no_vehicle) = 0;
				Show.ShowMultiColoredRoad(handl_table, heatMap, params);
			else
				Show.ShowRoad(handl_table, state, params);
			end
			Show.ShowMemoryMap(handl_memory, memory, params); 
		end

		hitMap(state == params.no_vehicle) = iteration;
        prevState = state;
		[state, memory, collided, stop] = Snake.SingleCoverageAlgorithm(state, memory, params, iteration);	
		if(collided)
			fprintf('Algorithm stopped due to collision\n');
			success = false;
			break;
		end
		if(memory(state == params.no_vehicle) > 0)
			fprintf('Memory is hold on non-agent\n');
			success = false;
			break;
        end
        if(~params.suppress_output && ~any(any(prevState ~= state)))            
            fprintf('Passed after iterations %d\n', iteration - passed_iteration);
            passed_iteration = iteration;
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

        if(params.stop_on_coverage_complete && ~any(any(check_coverage == false)))
            fprintf('Algorithm stopped. Coverage completed.\n');
            success = true;
            break;
        end

        if(params.visual_on)
			pause(params.pause_for);
		end
		
		iteration = iteration + 1;
	end

	if(params.visual_on)
		if(params.enable_color_tracking)
			heatMap = hitMap - min(min(hitMap));
			heatMap(state == params.no_vehicle) = 0;
			Show.ShowMultiColoredRoad(handl_table, heatMap, params);
		else
			Show.ShowRoad(handl_table, state, params);
		end
		Show.ShowMemoryMap(handl_memory, memory, params); 
	end
end
