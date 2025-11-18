function [ new_state, new_memory, collided, stopped ] = ExecuteTwoColumnSorting( state, memory, params )
%EXECUTETWOCOLUMNSORTING Executes sorting of two column roads

	VCONTINUE = params.vehicle_continue;
	VEXIT = params.vehicle_exit;
	EMPTY = params.no_vehicle;
	DO_NOTHING = params.do_nothing;
	go_north = params.go_north; go_west = params.go_west;

	sortingAlgo = feval(sprintf('Beads.FSMv%d', params.sorting__two_columns_algo_version));

    % neighborhoods
	m_0_down = boolean([0;0;1]);
	m_0_up = boolean([1;0;0]);
	m_0_right = m_0_down';
	m_0_left = m_0_up';
	
    % areas
	where_zeros = state == EMPTY;
	where_zeros_above = Utility.Helper.Conv2(where_zeros, m_0_down, 'same'); % to the north of the cell
	where_zeros_below = Utility.Helper.Conv2(where_zeros, m_0_up, 'same'); % to the south of the cell
	where_zeros_onleft = Utility.Helper.Conv2(where_zeros, m_0_right, 'same'); % to the west of the cell
	where_zeros_onright = Utility.Helper.Conv2(where_zeros, m_0_left, 'same'); % to the east of the cell
	
    % translate into bits, so it will be possible to understand where is the empty space around me
	where_zeros_num = uint8(1 * where_zeros_above + 2 * where_zeros_onright + ...
		4 * where_zeros_below + 8 * where_zeros_onleft);
    % remove this information from actual empty cells
	where_zeros_num(where_zeros) = 0;
    
	collided = false;
	new_state = state;
	
	map_memory = sortingAlgo.GetMemoryMap();
	map_direction = sortingAlgo.GetDirectionMap();
    
    m1_column = Utility.Mask(params).m1_column;
    m0_column = Utility.Mask(params).m_column;
    
    % own coding: sits on left - set LSB, sits on right set next bit (2), exits - then add 2
    % i.e. car : cont + left  = 1
    %            cont + right = 2
    %            exit + left  = 3
    %            exit + right = 4
    fsm_entry = uint8(1 * m1_column + 2 * m0_column + 2 * (state == VEXIT));
    
	current_directions = map_direction(sub2ind(size(map_direction), memory(:) + 1, where_zeros_num(:) + 1, fsm_entry(:)));
	current_directions = reshape(current_directions, params.n, params.m);
	current_directions(where_zeros) = DO_NOTHING;
    
    new_memory = map_memory(sub2ind(size(map_memory), memory(:) + 1, where_zeros_num(:) + 1, fsm_entry(:)));
    new_memory = reshape(new_memory, params.n, params.m);
    new_memory(where_zeros) = 0;
    
	shift_in = [-1;params.n;1;-params.n];
    for direction = go_north:go_west
        moving_indexes = find(current_directions == direction);
        if(~isempty(moving_indexes))
            new_state(moving_indexes + shift_in(direction + 1)) = state(moving_indexes);
            new_state(moving_indexes) = EMPTY;
            new_memory(moving_indexes + shift_in(direction + 1)) = new_memory(moving_indexes);
            new_memory(moving_indexes) = 0;
        end
    end
    stopped = ~Utility.Helper.Any(new_state(m1_column) == VEXIT);
end

