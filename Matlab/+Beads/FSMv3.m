classdef FSMv3 < Beads.AbstractFSM
    %FSMV3 The visibility = 1 memory-based sorting for two lanes blocks
    % the cooldown is the same
    % The split is now on which lane agents move: left-right
    %i.e.	time = 0: left up and right
    %       time = 1: right down and left
    %       time = 2: left down and right
    %       time = 3: right up and left
    
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
        function obj = FSMv3()
			do_nothing = Beads.AbstractFSM.do_nothing;
			Error = Beads.AbstractFSM.Error;
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
    % i.e. car : cont + left  = 1
    %            cont + right = 2
    %            exit + left  = 3
    %            exit + right = 4
            
            cont_left = 1;
            cont_rigt = 2;
            exit_left = 3;
            exit_rigt = 4;
            
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

            % first set if moving north-south
            obj.memory_map(1, north_indices, [cont_left, exit_left]) = lock1 + 2;
            obj.memory_map(2, south_indices, [cont_rigt, exit_rigt]) = lock1 + 2;
            obj.memory_map(3, south_indices, [cont_left, exit_left]) = lock1;
            obj.memory_map(4, north_indices, [cont_rigt, exit_rigt]) = lock1;
            obj.direction_map(1, north_indices, [cont_left, exit_left]) = go_north;
            obj.direction_map(3, south_indices, [cont_left, exit_left]) = go_south;
            obj.direction_map(2, south_indices, [cont_rigt, exit_rigt]) = go_south;
            obj.direction_map(4, north_indices, [cont_rigt, exit_rigt]) = go_north;            

            % then re-write if needed and go east-west - cause it is more important ?? (next 4 rows are weird)
            obj.memory_map([1,5,9],  west_indices, cont_left) = 1;
            obj.memory_map([2,6,10], east_indices, exit_rigt) = 1;
            obj.memory_map([3,7,11], west_indices, cont_left) = 3;
            obj.memory_map([4,8,12], east_indices, exit_rigt) = 3;
            
            obj.direction_map([1,3,5,7, 9,11], east_indices, exit_left) = go_east;
            obj.direction_map([2,4,6,8,10,12], west_indices, cont_rigt) = go_west;
            
        end
        
		function [result_memory_map] = GetMemoryMap(this)
			result_memory_map = this.memory_map;
		end

		function [result_direction_map] = GetDirectionMap(this)
			result_direction_map = this.direction_map;
		end
    end
end

