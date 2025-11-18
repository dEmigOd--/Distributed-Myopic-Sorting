function [success, iteration] = RunRandomSorting(state, params)

	close all;

    mapper = Utility.Helper.GetRandomStrategy(params);
    
	if(params.visual_on)
		figure('Position', [1360 60 540 900]);
		handl = gca;
	end

	success = true;
	
	iteration = 0;
	while(true)
        if(params.visual_on && mod(iteration, params.frequency_of_update) == 0)
            Show.ShowRoad(handl, state, params);
        end

        iteration = iteration + 1;
        [mapper, exit_prob_map, cont_prob_map] = mapper.GetProbabilityMaps(iteration);
		[new_state] = Random.ProcessRandomState(state, params, exit_prob_map, cont_prob_map);
		
        if(Utility.Helper.Sum(new_state(:, end) == params.vehicle_exit) == params.n)
            success = true;
            break;
        end

        state = new_state;
        
        if(params.visual_on && (mod(iteration, params.frequency_of_update) == 0))
            pause(params.pause_for);
        end
        
        if(params.random_sorting_fail_at_iteration <= iteration)
            success = false;
            break;
        end
	end

	if(params.visual_on)
		pause(params.pause_for);
		Show.ShowRoad(handl, state, params);
		fprintf('Algorithm finished in %d iterations\n', iteration);
	end
    
end

