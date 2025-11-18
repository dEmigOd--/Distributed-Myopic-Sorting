classdef SimulationParameters
	%SIMULATIONPARAMETERS parameters of simulations
	
	properties (Constant)
		vehicle_continue = -1;
		wall = 2;
		vehicle_exit = 1;
		no_vehicle = 0;
		
		north = 0;
		east = 1;
		south = 2;
		west = 3;
		
		do_nothing = 4;
		Error = 5;
		Stop = 6;
        unspecified = 7;
	end
	
	properties
		n;
		m;
		k;
		makeStay; % some vehicles could find their place and not change it further
		frequency_of_update;
		
		vehicle_length;
		vehicle_width;
		
		do_horizontal_traversal;
		visual_on;
		coverage_algo_version;
		bits_in_coverage_algorithm;
		sorting_algo_version;
        random_strategy_version;
        random_sorting_fail_at_iteration;
        sorting__two_columns_algo_version;
		
		pause_for;
		
		color_exit;
		color_continue;
		
		enable_color_tracking;
		
		go_north;
		go_east;
		go_south;
		go_west;
		
		zoom_value;
        suppress_output;
        draw_frame;
    end
	
    properties (Access = public)
        collision_solver;
        anniling_params;
        stop_on_coverage_complete;
    end
    
	methods
		function obj = SimulationParameters(n, m, visual_on, pause_for, ...
				coverage_algo_version, sorting_algo_version, ...
				color_exit, color_continue, color_tracking)
			if (nargin >= 2)
				obj.n = n;
				obj.m = m;
			else
				obj.n = 8;
				obj.m = 7;
			end
			if (nargin >= 3)
				obj.visual_on = visual_on;
			else
				obj.visual_on = false;
			end
			if(nargin >= 4)
				obj.pause_for = pause_for;
			else
				obj.pause_for = 0.2;
			end
            if(nargin >= 5)
                obj.coverage_algo_version = coverage_algo_version;
            else
                obj.coverage_algo_version = 7;
            end
            if(nargin >= 6)
                obj.sorting_algo_version = sorting_algo_version;
            else
                obj.sorting_algo_version = 3;
            end
            obj.sorting__two_columns_algo_version = 1;
			if(nargin >= 7)
				obj.color_exit = color_exit;
				obj.color_continue = color_continue;
			else
				obj.color_exit = (255 - [51;255;51]) / 255;
				obj.color_continue = (255 - [255;153;153]) / 255;
			end
			if(nargin >= 9)
				obj.enable_color_tracking = color_tracking;
			else
				obj.enable_color_tracking = false;
			end
			
			obj.go_north = Parameters.SimulationParameters.north;
			obj.go_east = Parameters.SimulationParameters.east;
			obj.go_south = Parameters.SimulationParameters.south;
			obj.go_west = Parameters.SimulationParameters.west;
		
			obj.k = 5;
			obj.makeStay = true; % some vehicles could find their place and not change it further
			obj.frequency_of_update = 100;
			obj.vehicle_length = 4;
			obj.vehicle_width = 4;
			obj.do_horizontal_traversal = false;
			
			obj.zoom_value = 10;
            obj.suppress_output = false;
            obj.draw_frame = false;
            
            obj.bits_in_coverage_algorithm = Utility.Helper.GetBitsInFsm(obj.coverage_algo_version);
		end
	end
	
end

