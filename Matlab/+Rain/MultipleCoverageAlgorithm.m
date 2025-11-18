function [new_state, new_memory, collided, stopped] = MultipleCoverageAlgorithm( state, memory, params )
%MULTIPLECOVERAGEALGORITHM Simulate rain-like multiple empty slots coverage algorithm

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
	do_nothing = params.do_nothing; Error = params.Error; stop_run = params.Stop; empty_direction = -1;
	fsm = Utility.Helper.GetFSM(params);
	map_memory = fsm.GetMemoryMap();
	map_direction = fsm.GetDirectionMap();
    mapping = fsm.GetDirectionMapping();

    % neighborhoods
	m_0_down = boolean([0;0;1]);
	m_0_up = boolean([1;0;0]);
	m_0_right = m_0_down';
	m_0_left = m_0_up';
	
	% areas
	where_zeros = state == params.no_vehicle;
	where_zeros_above = Utility.Helper.Conv2(where_zeros, m_0_down, 'same'); % to the north of the cell
	where_zeros_below = Utility.Helper.Conv2(where_zeros, m_0_up, 'same'); % to the south of the cell
	where_zeros_onleft = Utility.Helper.Conv2(where_zeros, m_0_right, 'same'); % to the west of the cell
	where_zeros_onright = Utility.Helper.Conv2(where_zeros, m_0_left, 'same'); % to the east of the cell
	
	where_zeros_num = uint8(1 + 1 * where_zeros_above + 2 * where_zeros_onright + ...
		4 * where_zeros_below + 8 * where_zeros_onleft);
	
	indexes = (1:numel(state))';

	stopped = false;
	collided = false;
	new_state = state;
	new_memory = memory;
	
	area_map = Utility.Helper.MapAreas(params);
	direction_indexes = mapping(sub2ind(size(mapping), area_map(:), where_zeros_num(:)));
	current_directions = map_direction(sub2ind(size(map_direction), memory(:) + 1, direction_indexes, area_map(:)));
	current_directions(where_zeros) = empty_direction;
	
	if(Utility.Helper.Any(current_directions == Error))
		fprintf('The table is in the wrong state\n');
		stopped = true;
		return;
	end
	
	after_movement = zeros(numel(state), 1);
	
	shift_in = [-1;params.n;1;-params.n];
	for direction = go_north:go_west
		actual_indexes_moving = indexes(current_directions == direction);
		after_movement(actual_indexes_moving + shift_in(direction + 1)) = ...
			after_movement(actual_indexes_moving + shift_in(direction + 1)) + 1;
		new_state(actual_indexes_moving + shift_in(direction + 1) ) = state(actual_indexes_moving);
		new_state(actual_indexes_moving) = params.no_vehicle;
	end
	
	if(Utility.Helper.Any(after_movement > 1))
		collided = true;
		return;
	end	
	
	new_memory = map_memory(sub2ind(size(map_memory), memory(:) + 1, direction_indexes, area_map(:)));	
	zero_indexes = indexes(where_zeros);
	future_occupied_zeros = false(size(zero_indexes));
	
	for direction = go_north:go_west
		actual_indexes_moving = indexes(current_directions == direction);
		future_occupied_zeros = future_occupied_zeros | ismember(zero_indexes, actual_indexes_moving + shift_in(direction + 1));
		new_memory(actual_indexes_moving + shift_in(direction + 1)) = new_memory(actual_indexes_moving);
		new_memory(actual_indexes_moving) = 0;
	end
	
	new_memory(zero_indexes(~future_occupied_zeros)) = 0;
	new_memory = reshape(new_memory, params.n, params.m);
	if(~Utility.Helper.Any(state ~= new_state) && ~Utility.Helper.Any(memory ~= new_memory))
        % currently assumed no agent is able to claim completion
		stopped = true;
	end

end

