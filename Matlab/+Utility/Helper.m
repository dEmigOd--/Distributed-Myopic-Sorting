classdef Helper
    %HELPER common functions implementation
    
    methods(Static)
        function [fsm] = GetFSM(params)
            if(params.coverage_algo_version > 1000)
                fsm = eval(sprintf('Rain.mFSMv%d', params.coverage_algo_version - 1000));
            else                
                fsm = Snake.(sprintf('FSMv%d', params.coverage_algo_version))(params);
            end
        end
        
        function [strategy] = GetRandomStrategy(params)
        	strategy = Random.(sprintf('Annilingv%d', params.random_strategy_version))(params);
        end
        
        function [bits_in_fsm] = GetBitsInFsm(coverage_algo_version)
            if(coverage_algo_version > 1000)
                bits_in_fsm = Rain.(sprintf('mFSMv%d', coverage_algo_version - 1000)).GetBits();
            else                
                bits_in_fsm = Snake.(sprintf('FSMv%d', coverage_algo_version)).GetBits();
            end
        end

        function [solver] = GetCollisionSolver(name)
            try
                solver = eval(sprintf('CollisionSolver.%sSolver', name));
            catch
                solver = CollisionSolver.BasicSolver();
            end
        end
        
        function [area_index] = MapAreas(params)
            % masks
            first_row = false(params.n, params.m); first_row(1,:) = true;
            last_row = false(size(first_row)); last_row(end,:) = true;
            first_column = false(size(first_row)); first_column(:, 1) = true;
            last_column = false(size(first_row)); last_column(:, end) = true;
            left_upper_corner = false(size(first_row)); left_upper_corner(1,1) = true;
            right_upper_corner = false(size(first_row)); right_upper_corner(1,end) = true;
            right_bottom_corner = false(size(first_row)); right_bottom_corner(end,end) = true;
            left_bottom_corner = false(size(first_row)); left_bottom_corner(end,1) = true;

            [rows, cols] = size(first_row);

            area_index = ...
                1 * right_bottom_corner + ...
                2 * (cols > 1 && rows > 1) * left_bottom_corner + ...
                3 * left_upper_corner + ...
                4 * (cols > 1 && rows > 1) * right_upper_corner + ...
                5 * (cols > 2) * (last_row & ~(right_bottom_corner | left_bottom_corner)) + ...
                6 * (cols > 1 && rows > 2) * (first_column & ~(left_bottom_corner | left_upper_corner)) + ...
                7 * (cols > 2 && rows > 1) * (first_row & ~(left_upper_corner | right_upper_corner)) + ...
                8 * (rows > 2) * (last_column & ~(right_upper_corner | right_bottom_corner)) + ...
                9 * (cols > 2 && rows > 2) * (~(first_column | first_row | last_column | last_row));
        end

        function [available_directions] = GetAvailableDirections()
            available_directions = [true,false,false,true;
                true,true,false,false;
                false,true,true,false;
                false,false,true,true;
                true,true,false,true;
                true,true,true,false;
                false,true,true,true;
                true,false,true,true;
                true,true,true,true]';
        end
        
        function [result_lookup] = GetDirectionMapping()
            persistent direction_mapping;

            if(isempty(direction_mapping))
                empty = 1; north = 2; east = 3; south = 5; west = 9;
                north_east = 4; north_south = 6; north_west = 10;
                east_south = 7; east_west = 11; south_west = 13;
                north_east_south = 8; north_east_west = 12; north_south_west = 14;
                east_south_west = 15; every = 16;

                direction_mapping = -1 * ones(9, 16);
                direction_mapping(:, empty) = 1;

                direction_mapping(1, [north,  west, north_west]) = 2:4;
                direction_mapping(2, [north,  east, north_east]) = 2:4;
                direction_mapping(3, [ east, south, east_south]) = 2:4;
                direction_mapping(4, [south,  west, south_west]) = 2:4;
                direction_mapping(5, [north,  east,  west,  north_east,  north_west,  east_west,  north_east_west]) = 2:8;
                direction_mapping(6, [north,  east, south,  north_east, north_south, east_south, north_east_south]) = 2:8;
                direction_mapping(7, [ east, south,  west,  east_south,   east_west, south_west,  east_south_west]) = 2:8;
                direction_mapping(8, [north, south,  west, north_south,  north_west, south_west, north_south_west]) = 2:8;
                direction_mapping(9, [north, east, south, west, north_east, north_south, north_west, east_south ...
                    east_west, south_west, north_east_south, north_east_west, north_south_west, east_south_west, every]) = ...
                    [2, 1, 3, 1, 2, 4, 2, 3, 1, 3, 4, 2, 4, 3, 4];
            end

            result_lookup = direction_mapping;
        end
        
        function [anyset] = Any(m)
            anyset =  any(any(m));
        end

        function [sumall] = Sum(m)
            sumall =  sum(sum(m));
        end

        function [ConvB] = Conv2(M1, M2, type)
            ConvB = boolean(conv2(double(M1), double(M2), type));
        end

        function [values] = GetEntries(map, memory, input_direction, area_map, entries)
            if(isempty(entries))
                values = double.empty(size(entries));
            else
                sizes = size(map);
                indexes = sub2ind(sizes, memory(entries) + 1, input_direction * ones(numel(area_map(entries)), 1), area_map(entries));
                values = map(indexes);
            end
        end
    end
end

