function [ new_state, new_memory, collided, stop ] = SnakeTailVer6( state, memory, params )
	%SNAKETAILVER5 simulate snake tail algorithm with 2 bit memory in the agents only !
	% setting 3 is essential, otherwise cells are colliding when both above and below are 2-s
	% input direction
	north = 0; east = 1; south = 2; west = 3;
	% agent decision	
	go_north = north; go_east = east; go_south = south; go_west = west;
	
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
	error = 5; do_nothing = 4;
	map_memory = GetMemoryMap();
	map_direction = GetDirectionMap();

	% neighborhoods
	m_0_down = boolean([0;0;1]);
	m_0_up = boolean([1;0;0]);
	m_0_right = m_0_down';
	m_0_left = m_0_up';
	
	% areas
	where_zeros = state == params.no_vehicle;
	where_zeros_above = Conv2(where_zeros, m_0_down, 'same'); % to the north of the cell
	where_zeros_below = Conv2(where_zeros, m_0_up, 'same'); % to the south of the cell
	where_zeros_onleft = Conv2(where_zeros, m_0_right, 'same'); % to the west of the cell
	where_zeros_onright = Conv2(where_zeros, m_0_left, 'same'); % to the east of the cell
	
	indexes = (1:numel(state))';
	indexes_to_north = indexes(where_zeros_above);
	indexes_to_east = indexes(where_zeros_onright);
	indexes_to_south = indexes(where_zeros_below);
	indexes_to_west = indexes(where_zeros_onleft);

	stop = false;
	collided = false;
	new_state = state;
	new_memory = memory;
	
	area_map = MapAreas(params);
    direction_zeros_above = map_direction(memory(where_zeros_above) + 1, north + 1, area_map(where_zeros_above));
	if(Any(direction_zeros_above == error))
		fprintf('The table is in the wrong state\n');
		stop = true;
		return;
	end
    direction_zeros_below = map_direction(memory(where_zeros_below) + 1, south + 1, area_map(where_zeros_below));
	if(Any(direction_zeros_below == error))
		fprintf('The table is in the wrong state\n');
		stop = true;
		return;
	end
    direction_zeros_onleft = map_direction(memory(where_zeros_onleft) + 1, west + 1, area_map(where_zeros_onleft));
	if(Any(direction_zeros_onleft == error))
		fprintf('The table is in the wrong state\n');
		stop = true;
		return;
	end
    direction_zeros_onright = map_direction(memory(where_zeros_onright) + 1, east + 1, area_map(where_zeros_onright));
	if(Any(direction_zeros_onright == error))
		fprintf('The table is in the wrong state\n');
		stop = true;
		return;
	end
	
	after_movement = zeros(numel(state), 1);
	
	actual_indexes_to_north = indexes_to_north(direction_zeros_above == go_north);
	staying_indexes_to_north = indexes_to_north(direction_zeros_above == do_nothing);
	if(~isempty(actual_indexes_to_north))
		after_movement(actual_indexes_to_north - 1) = after_movement(actual_indexes_to_north - 1) + 1;
		new_state(actual_indexes_to_north - 1) = state(actual_indexes_to_north);
		new_state(actual_indexes_to_north) = params.no_vehicle;
	end
	actual_indexes_to_east = indexes_to_east(direction_zeros_onright == go_east);
	staying_indexes_to_east = indexes_to_east(direction_zeros_onright == do_nothing);
	if(~isempty(actual_indexes_to_east))
		after_movement(actual_indexes_to_east + params.n) = after_movement(actual_indexes_to_east + params.n) + 1;
		new_state(actual_indexes_to_east + params.n) = state(actual_indexes_to_east);
		new_state(actual_indexes_to_east) = params.no_vehicle;
	end
	actual_indexes_to_south = indexes_to_south(direction_zeros_below == go_south);
	staying_indexes_to_south = indexes_to_south(direction_zeros_below == do_nothing);
	if(~isempty(actual_indexes_to_south))
		after_movement(actual_indexes_to_south + 1) = after_movement(actual_indexes_to_south + 1) + 1;
		new_state(actual_indexes_to_south + 1) = state(actual_indexes_to_south);
		new_state(actual_indexes_to_south) = params.no_vehicle;
	end
	actual_indexes_to_west = indexes_to_west(direction_zeros_onleft == go_west);
	staying_indexes_to_west = indexes_to_west(direction_zeros_onleft == do_nothing);
	if(~isempty(actual_indexes_to_west))
		after_movement(actual_indexes_to_west - params.n) = after_movement(actual_indexes_to_west - params.n) + 1;
		new_state(actual_indexes_to_west - params.n) = state(actual_indexes_to_west);
		new_state(actual_indexes_to_west) = params.no_vehicle;
	end
	
	new_memory(actual_indexes_to_north - 1) = GetEntries(map_memory,memory, north, area_map, indexes_to_north);
	new_memory(actual_indexes_to_north) = 0;
	new_memory(staying_indexes_to_north) = GetEntries(map_memory, memory, north, area_map, staying_indexes_to_north);
	new_memory(actual_indexes_to_east + params.n) = GetEntries(map_memory, memory, east, area_map, actual_indexes_to_east);
	new_memory(actual_indexes_to_east) = 0;
	new_memory(staying_indexes_to_east) = GetEntries(map_memory, memory, east, area_map, staying_indexes_to_east);
	new_memory(actual_indexes_to_south + 1) = GetEntries(map_memory, memory, south, area_map, actual_indexes_to_south);
	new_memory(actual_indexes_to_south) = 0;
	new_memory(staying_indexes_to_south) = GetEntries(map_memory, memory, south, area_map, staying_indexes_to_south);
	new_memory(actual_indexes_to_west - params.n) = GetEntries(map_memory, memory, west, area_map, actual_indexes_to_west);
	new_memory(actual_indexes_to_west) = 0;
	new_memory(staying_indexes_to_west) = GetEntries(map_memory, memory, west, area_map, staying_indexes_to_west);
	
	if(Any(after_movement > 1))
		collided = true;
		return;
	end
	
	if(any(ismember(actual_indexes_to_south, 1)) || ...
			((params.m ~= 1) && any(ismember(actual_indexes_to_north, params.n)) && (memory(end, 1) == 2)) || ...
			((params.n == 1) && any(ismember(actual_indexes_to_east, 1))))
		stop = true;
	end
end

function [result_memory_map] = GetMemoryMap()
	persistent memory_map;
	error = 5;
	
	if(isempty(memory_map))
		memory_map = error * ones(4, 4, 9); % 5 is when no input is given

		memory_map(:, :, 1) = [ ...
			2, error, error, 0; ...
			error, error, error, error; ...
			error, error, error, 3; ...
			3, error, error, 3];
		memory_map(:, :, 2) = [ ...
			1, 1, error, error; ...
			2, 2, error, error; ...
			3, 3, error, error; ...
			3, 1, error, error];
		memory_map(:, :, 3) = [ ...
			error, 1, 1, error; ...
			error, 2, 2, error; ...
			error, 3, 3, error; ...
			error, 2, 3, error];
		memory_map(:, :, 4) = [ ...
			error, error, 2, 0; ...
			error, error, 2, error; ...
			error, error, 3, error; ...
			error, error, 3, 3];
		memory_map(:, :, 5) = [ ...
			0, 1, error, 0; ...
			2, 2, error, 2; ...
			3, 2, error, 3; ...
			3, 1, error, 3];
		memory_map(:, :, 6) = [ ...
			0, 2, 1, error; ...
			2, 2, 2, error; ...
			3, 2, 3, error; ...
			3, 2, 3, error];
		memory_map(:, :, 7) = [ ...
			error, 1, 1, 0; ...
			error, 2, 2, 1; ...
			error, 3, 3, 2; ...
			error, 2, 3, 3];
		memory_map(:, :, 8) = [ ...
			1, error, 2, 0; ...
			error, error, 2, error; ...
			error, error, 3, error; ...
			3, error, 3, 3];
		memory_map(:, :, 9) = [ ...
			0, 2, 1, 0; ...
			2, 2, 2, 1; ...
			3, 2, 3, 2; ...
			3, 2, 3, 3];
	end
	
	result_memory_map = memory_map;
end

function [result_direction_map] = GetDirectionMap()
	persistent direction_map;
	
	if(isempty(direction_map))
		error = 5;
		do_nothing = 4;
		% direction
		north = 0; east = 1; south = 2; west = 3;
		% agent decision	
		go_north = north; go_east = east; go_south = south; go_west = west;
		direction_map = error * ones(4, 4, 9);

		direction_map(:, :, 1) = [ ...
			go_north, error, error, go_west; ...
			error, error, error, error; ...
			error, error, error, do_nothing; ...
			do_nothing, error, error, do_nothing];
		direction_map(:, :, 2) = [ ...
			go_north, do_nothing, error, error; ...
			do_nothing, do_nothing, error, error; ...
			go_north, go_east, error, error; ...
			do_nothing, do_nothing, error, error];
		direction_map(:, :, 3) = [ ...
			error, do_nothing, do_nothing, error; ...
			error, do_nothing, do_nothing, error; ...
			error, go_east, go_south, error; ...
			error, do_nothing, do_nothing, error];
		direction_map(:, :, 4) = [ ...
			error, error, do_nothing, do_nothing; ...
			error, error, do_nothing, error; ...
			error, error, go_south, error; ...
			error, error, go_south, do_nothing];
		direction_map(:, :, 5) = [ ...
			go_north, do_nothing, error, go_west; ...
			do_nothing, do_nothing, error, do_nothing; ...
			go_north, go_east, error, do_nothing; ...
			do_nothing, do_nothing, error, do_nothing];
		direction_map(:, :, 6) = [ ...
			go_north, do_nothing, do_nothing, error; ...
			do_nothing, do_nothing, do_nothing, error; ...
			go_north, do_nothing, go_south, error; ...
			do_nothing, do_nothing, do_nothing, error];
		direction_map(:, :, 7) = [ ...
			error, do_nothing, do_nothing, do_nothing; ...
			error, do_nothing, do_nothing, do_nothing; ...
			error, go_east, go_south, do_nothing; ...
			error, do_nothing, do_nothing, do_nothing];
		direction_map(:, :, 8) = [ ...
			go_north, error, do_nothing, do_nothing; ...
			error, error, do_nothing, error; ...
			error, error, go_south, error; ...
			do_nothing, error, go_south, do_nothing];
		direction_map(:, :, 9) = [ ...
			go_north, do_nothing, do_nothing, do_nothing; ...
			do_nothing, do_nothing, do_nothing, do_nothing; ...
			go_north, do_nothing, go_south, do_nothing; ...
			do_nothing, do_nothing, do_nothing, do_nothing];
	end

	result_direction_map = direction_map;
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

function [anyset] = Any(m)
	anyset =  any(any(m));
end

function [ConvB] = Conv2(M1, M2, type)
	ConvB = boolean(conv2(double(M1), double(M2), type));
end

function [values] = GetEntries(map, memory, input_direction, area_map, entries)
	if(isempty(entries))
		values = double.empty(size(entries));
	else
		sizes = size(map);
		indexes = sub2ind(sizes, memory(entries) + 1, (input_direction + 1) * ones(numel(area_map(entries)), 1), area_map(entries));
		values = map(indexes);
	end
end
