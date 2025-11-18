classdef mFSMv4 < Snake.AbstractFSM
    %MFSMV4 the multiple empty space coverage automatons
    % like MFSMV3 but 6 should be east oriented
    
	properties
		memory_map;
		direction_map;
    end	
    
    methods(Static)
        function [bits_in_memory] = GetBits()
            bits_in_memory = 3;
        end
    end
    
	methods
		function obj = mFSMv4()
			do_nothing = Snake.AbstractFSM.do_nothing;
			Error = Snake.AbstractFSM.Error;
            mem_Error = 0;
			Stop = Snake.AbstractFSM.Stop;
			% agent decision	
			go_north = Snake.AbstractFSM.go_north; go_east = Snake.AbstractFSM.go_east; 
			go_south = Snake.AbstractFSM.go_south; go_west = Snake.AbstractFSM.go_west;
			
			obj.memory_map = mem_Error * ones(2 ^ Rain.mFSMv4.GetBits(), 2 ^ Snake.AbstractFSM.num_readings, 9);
			obj.direction_map = Error * ones(2 ^ Rain.mFSMv4.GetBits(), 2 ^ Snake.AbstractFSM.num_readings, 9);

            obj.memory_map(1, 1:4, 1) = [ ...
                0, 0, 0, 0];
            obj.memory_map(1:2, 1:4, 2) = [ ...
                0, 1, 0, 1; ...
                1, 0, mem_Error, mem_Error];
            obj.memory_map(1, 1:4, 3) = [ ...
                0, 0, 0, 0];
            obj.memory_map(1, 1:4, 4) = [ ...
                0, 0, 0, 0];
            obj.memory_map(1, 1:8, 5) = [ ...
                0, 0, 0, 0, 0, 0, 0, 0];
            obj.memory_map(1:4, 1:8, 6) = [ ...
                0, 2, 3, 0, 3, 2, 3, 3; ...
                mem_Error, mem_Error, 3, mem_Error, 2, mem_Error, 3, 2; ...
                0, 0, 3, 0, 3, 0, 3, 3; ...
                0, 2, 3, 0, 3, 2, 3, 3];
            obj.memory_map(1, 1:8, 7) = [ ...
                0, 0, 0, 0, 0, 0, 0, 0];
            obj.memory_map(1, 1:8, 8) = [ ...
                0, 0, 0, 0, 0, 0, 0, 0];
            obj.memory_map(4, 1:8, 8) = [ ...
                0, 0, 0, 0, 0, 0, 0, 0];
            obj.memory_map(1:6, 1:16, 9) = [ ...
                0, 0, 5, 0, 1, 5, 0, 1, 5, 1, 1, 5, 1, 1, 1, 1; ... % init state
                mem_Error, mem_Error, 2, mem_Error, mem_Error, 2, mem_Error, mem_Error, 2, 2, mem_Error, 2, 2, mem_Error, 2, 2; ... % moved west from init
                2, 2, 3, 2, 2, 3, 2, 2, 3, 3, 2, 3, 3, 2, 3, 3; ... % 1 round after moving west from init
                0, 0, 5, 0, 3, 5, 0, 3, 5, 4, 3, 5, 4, 3, 4, 4; ... % waiting 1 on east after previously moving west
                0, 0, 3, 0, 3, 3, 0, 3, 3, 3, 3, 3, 3, 3, 3, 3; ... % waited enough rounds to move east, after previously moving west
                0, 0, 3, 0, 1, 3, 0, 1, 3, 1, 1, 3, 1, 1, 1, 1;     % waiting 1 round for east
                ];

            obj.direction_map(1, 1:4, 1) = [ ...
                do_nothing, do_nothing, go_west, go_west];
            obj.direction_map(1:2, 1:4, 2) = [ ...
                do_nothing, do_nothing, do_nothing, do_nothing; ...
                do_nothing, go_north, Error, Error];
            obj.direction_map(1, 1:4, 3) = [ ...
                do_nothing, go_east, do_nothing, go_east];
            obj.direction_map(1, 1:4, 4) = [ ...
                do_nothing, go_south, do_nothing, go_south];
            obj.direction_map(1, 1:8, 5) = [ ...
                do_nothing, do_nothing, do_nothing, go_west, do_nothing, go_west, go_west, go_west];
            obj.direction_map(1:4, 1:8, 6) = [ ...
                do_nothing, do_nothing, do_nothing, do_nothing, do_nothing, do_nothing, do_nothing, do_nothing; ...
                Error, Error, do_nothing, Error, do_nothing, Error, do_nothing, do_nothing; ...
                do_nothing, go_north, do_nothing, do_nothing, do_nothing, go_north, do_nothing, do_nothing; ...
                do_nothing, do_nothing, go_east, do_nothing, go_east, do_nothing, go_east, go_east];
            obj.direction_map(1, 1:8, 7) = [ ...
                do_nothing, go_east, do_nothing, do_nothing, go_east, go_east, do_nothing, go_east];
            obj.direction_map(1, 1:8, 8) = [ ...
                do_nothing, do_nothing, go_south, do_nothing, go_south, do_nothing, go_south, go_south];
            obj.direction_map(4, 1:8, 8) = [ ...
                do_nothing, do_nothing, go_south, do_nothing, go_south, do_nothing, go_south, go_south];
            obj.direction_map(1:6, 1:16, 9) = [ ...
                do_nothing, do_nothing, do_nothing, do_nothing, go_west, do_nothing, do_nothing, go_west, do_nothing, go_west, go_west, do_nothing, go_west, go_west, go_west, go_west; ...
                Error, Error, do_nothing, Error, Error, do_nothing, Error, Error, do_nothing, do_nothing, Error, do_nothing, do_nothing, Error, do_nothing, do_nothing; ...
                do_nothing, do_nothing, go_east, do_nothing, do_nothing, go_east, do_nothing, do_nothing, go_east, go_east, do_nothing, go_east, go_east, do_nothing, go_east, go_east; ...
                do_nothing, do_nothing, do_nothing, do_nothing, do_nothing, do_nothing, do_nothing, do_nothing, do_nothing, do_nothing, do_nothing, do_nothing, do_nothing, do_nothing, do_nothing, do_nothing; ...
                do_nothing, do_nothing, go_east, do_nothing, do_nothing, go_east, do_nothing, do_nothing, go_east, go_east, do_nothing, go_east, go_east, do_nothing, go_east, go_east; ...
                do_nothing, do_nothing, go_east, do_nothing, go_west, go_east, do_nothing, go_west, go_east, go_west, go_west, go_east, go_west, go_west, go_west, go_west; ...
                ];
		end
		
		function [result_memory_map] = GetMemoryMap(this)
			result_memory_map = this.memory_map;
		end

		function [result_direction_map] = GetDirectionMap(this)
			result_direction_map = this.direction_map;
        end

        function [result_lookup] = GetDirectionMapping(~)
            persistent direction_mapping;

            if(isempty(direction_mapping))
                empty = 1; north = 2; east = 3; south = 5; west = 9;
                north_east = 4; north_south = 6; north_west = 10;
                east_south = 7; east_west = 11; south_west = 13;
                north_east_south = 8; north_east_west = 12; north_south_west = 14;
                east_south_west = 15; every = 16;

                direction_mapping = Utility.Helper.GetDirectionMapping();
                direction_mapping(9, [empty, north, east, south, west, north_east, north_south, north_west, east_south ...
                    east_west, south_west, north_east_south, north_east_west, north_south_west, east_south_west, every]) = 1:16;
            end
            
            result_lookup = direction_mapping;
        end

	end
end

