function [success, iteration] = RunSortingAlgorithm(state, params, debug_memory)
	close all;

	if(params.visual_on)
		figure('Position', [1360 60 540 900]);
		handl = gca;
	end

	if nargin > 2
		memory = debug_memory;
	else
		memory = zeros(params.n, params.m);
	end
	
	success = true;
	
	iteration = 0;
	while(true)
		if(params.visual_on)
			Show.ShowRoad(handl, state, params);
		end

		[state, memory, collided, stopped] = LittleCircles.ExecuteSortingAlgorithm(state, memory, params);
		iteration = iteration + 1;
		
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
		if(stopped)
			if(Utility.Helper.Sum(state(~Utility.Mask(params).m_column) == params.vehicle_exit) > 0)
				fprintf('Algorithm stopped, but not all exiting vehicles are in place\n');
				success = false;
			end
			break;
		end

		if(params.visual_on)
			pause(params.pause_for);
		end
	end

	if(params.visual_on)
		pause(params.pause_for);
		Show.ShowRoad(handl, state, params);
		fprintf('Algorithm finished in %d iterations\n', iteration);
	end
end
