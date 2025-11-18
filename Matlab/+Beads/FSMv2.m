classdef FSMv2 < Beads.AbstractFSM
    %FSMV2 The visibility = 1 memory-based sorting for two lanes blocks
    % the cooldown is the same
    
	properties
		memory_map;
		direction_map;
    end

    methods(Static)
        function [bits_in_memory] = GetBits()
            bits_in_memory = 4;
        end
    end
    
    methods
        function obj = FSMv2()
			do_nothing = Beads.AbstractFSM.do_nothing;
			Error = Beads.AbstractFSM.Error;
			Stop = Beads.AbstractFSM.Stop;
			% agent decision	
			go_north = Beads.AbstractFSM.go_north; go_east = Beads.AbstractFSM.go_east; 
			go_south = Beads.AbstractFSM.go_south; go_west = Beads.AbstractFSM.go_west;
			
            input_size = 16;
            lock1 = 4;
            lock2 = 8;
			obj.memory_map = Error * ones(2 ^ Beads.FSMv1.GetBits(), input_size, 4); % 16 is all the possible readings on 4 different sensors
			obj.direction_map = Error * ones(2 ^ Beads.FSMv1.GetBits(), input_size, 4); % there reading is the empty slot
            % check out 1 is for -1 in 1st column, 2 for -1 in 2nd column [left-to-right
            % 3 for 1 in 1st column and 4 for 1 in 2nd column
            % 2 bits for clock and 2 bits for lock

			obj.memory_map(1:4, :, 1) = kron(ones(1, input_size), [1;2;3;0]);
            obj.memory_map(5:8, :, 1) = lock1 + obj.memory_map(1:4, :, 1);
            obj.memory_map(9:12, :, 1) = lock2 + obj.memory_map(1:4, :, 1);
            for st=2:4
                obj.memory_map(:, :, st) = obj.memory_map(:, :, 1);
            end

            obj.direction_map(1:9, :, :) = do_nothing;

            all_indices = (1:input_size)-1;
            north_indices = find(bitget(all_indices, go_north + 1));
            east_indices = find(bitget(all_indices, go_east + 1));
            south_indices = find(bitget(all_indices, go_south + 1));
            west_indices = find(bitget(all_indices, go_west + 1));
            
            % increase lock count
            obj.memory_map(5, :, :) = lock2 + 1;
            obj.memory_map(9, :, :) = 1;

            obj.memory_map([1,5,9], west_indices, 1) = 1;
            obj.memory_map([1,5,9], east_indices, 4) = 1;
            obj.memory_map([3,7,11], west_indices, 1) = 3;
            obj.memory_map([3,7,11], east_indices, 4) = 3;
            
            obj.direction_map([1,3,5,7,9,11], east_indices, 3) = go_east;
            obj.direction_map([1,3,5,7,9,11], west_indices, 2) = go_west;
            
            obj.memory_map(2, north_indices, [1, 3]) = lock1 + 2;
            obj.memory_map(2, south_indices, [2, 4]) = lock1 + 2;
            obj.memory_map(4, south_indices, [1, 3]) = lock1;
            obj.memory_map(4, north_indices, [2, 4]) = lock1;
            obj.direction_map(2, north_indices, [1, 3]) = go_north;
            obj.direction_map(4, south_indices, [1, 3]) = go_south;
            obj.direction_map(2, south_indices, [2, 4]) = go_south;
            obj.direction_map(4, north_indices, [2, 4]) = go_north;            
        end
        
		function [result_memory_map] = GetMemoryMap(this)
			result_memory_map = this.memory_map;
		end

		function [result_direction_map] = GetDirectionMap(this)
			result_direction_map = this.direction_map;
		end
    end
end

