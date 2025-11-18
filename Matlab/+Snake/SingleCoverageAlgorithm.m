function [ new_state, new_memory, collided, stopped ] = SingleCoverageAlgorithm( state, memory, params, iteration )
	%SINGLECOVERAGEALGORITHM simulate snake tail algorithm with limited memory in the agents only !
	% setting 3 is essential, otherwise cells are colliding when both above and below are 2-s
	% input direction
	north = params.north + 1; east = params.east + 1; south = params.south + 1; west = params.west + 1;
	% agent decision	
	go_north = params.go_north; go_west = params.go_west;
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%             TABLE              %
	% ------------------------------ %
	% | 3 |       | 7 |        | 4 | %
	% -----       -----        ----- %
	% |                            | %
	% -----       -----        ----- %
	% | 6 |       | 9 |        | 8 | %
	% -----       -----        ----- %
	% |                            | %
	% -----       -----        ----- %
	% | 2 |       | 5 |        | 1 | %
	% ------------------------------ %
	%                                %
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	% prepare memory and direction mapping
	do_nothing = params.do_nothing; Error = params.Error; stop_run = params.Stop;
    
    % create fsm
	fsm = Utility.Helper.GetFSM(params);
	map_memory = fsm.GetMemoryMap();
	map_direction = fsm.GetDirectionMap();
    % create collision solver
    solver = Utility.Helper.GetCollisionSolver(params.collision_solver);
    
	% neighborhoods
	m_0_down = boolean([0;0;1]);
	m_0_up = boolean([1;0;0]);
	m_0_right = m_0_down';
	m_0_left = m_0_up';
	
	% areas
	where_zeros = state == params.no_vehicle;
	zeros_on = cell(west - north + 1,1);
	
	zeros_on{north} = Utility.Helper.Conv2(where_zeros, m_0_down, 'same'); % to the north of the cell
	zeros_on{east} = Utility.Helper.Conv2(where_zeros, m_0_left, 'same'); % to the east of the cell
	zeros_on{south} = Utility.Helper.Conv2(where_zeros, m_0_up, 'same'); % to the south of the cell
	zeros_on{west} = Utility.Helper.Conv2(where_zeros, m_0_right, 'same'); % to the west of the cell
	
	
	indexes = (1:numel(state))';
	movement_possibilities = cell(go_west - go_north + 1, 1);
	for direction = go_north:go_west
		movement_possibilities{direction + 1} = indexes(zeros_on{direction + 1});
	end

	stopped = false;
	collided = false;
	new_state = state;
	new_memory = memory;
	
	directions = cell(go_west - go_north + 1, 1);
	area_map = Utility.Helper.MapAreas(params);
	for direction = north:west
		directions{direction} = map_direction(memory(zeros_on{direction}) + 1, direction, area_map(zeros_on{direction}));
		if(Utility.Helper.Any(directions{direction} == Error))
			fprintf('The table is in the wrong state\n');
			stopped = true;
			return;
		end
		if(Utility.Helper.Any(directions{direction} == stop_run))
			% fix new state before stopping
			moving_index = movement_possibilities{direction};
			new_state(state == params.no_vehicle) = state(moving_index);
			new_state(moving_index) = params.no_vehicle;
			new_memory(state == params.no_vehicle) = Utility.Helper.GetEntries(map_memory, memory, direction, area_map, moving_index);
			new_memory(moving_index) = 0;
            if(~params.suppress_output)
                fprintf('The algorithm stopped, due to completion\n');
            end
			stopped = true;
			return;
		end
	end
	
	no_direction_set = cellfun(@isempty, directions);
    directions(no_direction_set) = { -1 };
    intend_to_move = ([directions{:}] == (go_north:go_west))';
    
    if(Utility.Helper.Sum(intend_to_move) > 1)
        [moving_indexes, solved] = solver.SolveCollision(movement_possibilities(intend_to_move), iteration);
        if (~solved)
            collided = true;
            return;
        end
        gave_up = cellfun(@isempty, moving_indexes);
        % no you can't drop second find
        intend_to_move(nonzeros(find(intend_to_move) .* gave_up)) = 0;
    end
    
	% index offsets
	offset = [-1; params.n; 1; -params.n];
	for direction = go_north:go_west
		move_possibilities = movement_possibilities{direction + 1};
		actual_indexes_to_move = move_possibilities((directions{direction + 1} == direction) && intend_to_move(direction + 1));
        if(~isempty(actual_indexes_to_move))
            new_state(actual_indexes_to_move + offset(direction + 1)) = state(actual_indexes_to_move);
            new_state(actual_indexes_to_move) = params.no_vehicle;
            new_memory(actual_indexes_to_move + offset(direction + 1)) = Utility.Helper.GetEntries(map_memory, memory, direction + 1, area_map, move_possibilities);
            new_memory(actual_indexes_to_move) = 0;
        end
		
        if(~isempty(move_possibilities) && ~intend_to_move(direction + 1))
    		staying_indexes = move_possibilities(directions{direction + 1} == do_nothing);
            new_memory(staying_indexes) = Utility.Helper.GetEntries(map_memory, memory, direction + 1, area_map, staying_indexes);
        end
	end

	
end
