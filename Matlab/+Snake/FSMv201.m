classdef FSMv201 < Snake.AbstractFSM
	%FSMV201 The first random distributed version
	
	properties (Access = private)
        memory_map;
		threshold_map;
        canonic_directions;
        iteration;
	end
	
    methods(Static)
        function [bits_in_memory] = GetBits()
            bits_in_memory = 0;
        end
        
        function [printable] = IsPrintable()
            printable = false;
        end
    end
    
    
	methods
		function obj = FSMv201(params)
            obj.iteration = 0;
            
            threshold = [ params.anniling_params.covg_north_probability; ...
                params.anniling_params.covg_east_probability; ...
                params.anniling_params.covg_south_probability; ...
                params.anniling_params.covg_west_probability;];
            obj.threshold_map = kron(ones(1, 9), threshold);
            obj.threshold_map(~Utility.Helper.GetAvailableDirections()) = 0;
            obj.threshold_map = obj.threshold_map ./ sum(obj.threshold_map);
            
			obj.memory_map = zeros(2 ^ Snake.FSMv201.GetBits(), 4, 9);
            obj.canonic_directions = kron(ones(1, 9), (Snake.AbstractFSM.go_north:Snake.AbstractFSM.go_west)');
		end
		
		function [result_memory_map] = GetMemoryMap(this)
			result_memory_map = this.memory_map;
		end

		function [result_direction_map] = GetDirectionMap(this)
            this.iteration = this.iteration + 1;
            
			direction_map = Snake.AbstractFSM.do_nothing * ones(2 ^ Snake.FSMv201.GetBits(), 4, 9); % 5 is when no input is given
            rand_decisions = rand(4 ,9);
            decision = rand_decisions < this.threshold_map;
            
			result_direction_map(1, :, :) = this.canonic_directions .* decision + squeeze(direction_map) .* ~decision;
		end

	end
	
end

