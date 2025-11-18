function [ new_state, new_memory, collided, stop ] = SnakeTailVer4( state, memory, params )
	%SNAKETAILVER4 simulate snake tail algorithm with 2 bit memory in the agents only !
	
	where_zeros = state == params.no_vehicle;
	count_eq_0 = memory == 0; % moves at first stage
	count_eq_1 = memory == 1; % corner cases
	count_eq_2 = memory == 2; % should move
	count_eq_3 = memory == 3; % to treat special case
	
	% neighborhoods
	whole_neighborhood = boolean([0,1,0; 1,0,1; 0,1,0]);
	m_0_down = boolean([0;0;1]); m_down = m_0_down;
	m_0_up = boolean([1;0;0]); m_up = m_0_up;
	m_0_right = m_0_down'; m_right = m_0_right;
	m_0_left = m_0_up'; m_left = m_0_left;
	% masks
	first_row = false(size(state)); first_row(1,:) = true;
	last_row = false(size(state)); last_row(end,:) = true;
	first_column = false(size(state)); first_column(:, 1) = true;
	last_column = false(size(state)); last_column(:, end) = true;
	left_upper_corner = false(size(state)); left_upper_corner(1,1) = true;
	right_upper_corner = false(size(state)); right_upper_corner(1,end) = true;
	right_bottom_corner = false(size(state)); right_bottom_corner(end,end) = true;
	left_bottom_corner = false(size(state)); left_bottom_corner(end,1) = true;
	
	% speaking properties
	can_move = Conv2(where_zeros, whole_neighborhood, 'same');
	can_move_0 = can_move & count_eq_0;
	can_move_01 = can_move & (count_eq_0 | count_eq_1);
	can_move_2 = can_move & count_eq_2;
	can_move_3 = can_move & count_eq_3;
	
	where_zeros_above = Conv2(where_zeros, m_0_down, 'same');
	where_zeros_below = Conv2(where_zeros, m_0_up, 'same');
	where_zeros_onleft = Conv2(where_zeros, m_0_right, 'same');
	where_zeros_onright = Conv2(where_zeros, m_0_left, 'same');
	
	stage_1_vertical = where_zeros_above & can_move_0;
	stage_1_vertical_last_column = where_zeros_above & can_move_0 & last_column;
	stage_1_horizontal = where_zeros_onleft & can_move_0 & last_row & ~right_bottom_corner;
	stage_1_right_bottom_corner = where_zeros_onleft & can_move_0 & right_bottom_corner;
	stage_2_unmoving_last_column = where_zeros_below & can_move_01 & last_column;
	stage_2_unmoving_border_horizontal = (where_zeros_onright | where_zeros_below | where_zeros_above) ...
		& can_move_01 & (first_row | last_row) & ~right_upper_corner;
	stage_2_special_left_to_right_bottom = where_zeros_onright & can_move_3;
	stage_2_zero_passing_on_the_right = where_zeros_onright & can_move & ~(first_row | last_row);
	stage_2_2final_moving_down = where_zeros_below & can_move_2 & ~left_upper_corner;
	stage_2_2final_moving_up = where_zeros_above & can_move_2 & ~last_column & ~left_bottom_corner;
	stage_2_2final_moving_right = where_zeros_onright & can_move_2 & (first_row | last_row);
	stage_2_stop_up = where_zeros_below & can_move_2 & left_upper_corner;
	stage_2_stop_bottom = where_zeros_above & can_move_2 & left_bottom_corner;
	stage_2_one_row = where_zeros_onright & can_move_2 & (left_upper_corner & left_bottom_corner); 

	% agent movement
	moving_up = stage_1_vertical | stage_2_2final_moving_up | stage_2_stop_bottom;
	moving_down = stage_2_2final_moving_down | stage_2_stop_up;
	moving_right = stage_2_2final_moving_right;
	moving_left = stage_1_right_bottom_corner | stage_1_horizontal;
	
	moving = moving_up + moving_down + moving_right + moving_left;
	
	% prepare output
	collided = false;
	stop = false;
    new_state = state;
    new_memory = memory;
	
	% check collisions
	if(Sum(moving) > 1)
        if(~params.suppress_output)
    		fprintf('Collision detected\n');
        end
		collided = true;
		return;
	end
	
	% check falling of road
	if(Any((moving_up & first_row) | (moving_down & last_row) | ...
			(moving_right & last_column) | (moving_left & first_column)))
		fprintf('Unfeasible move detected\n');
		stop = true;
	end
	
	% set new road state
	new_state = state;
	new_state(Conv2(moving_up, m_up, 'same')) = state(moving_up);
	new_state(Conv2(moving_down, m_down, 'same')) = state(moving_down);
	new_state(Conv2(moving_right, m_right, 'same')) = state(moving_right);
	new_state(Conv2(moving_left, m_left, 'same')) = state(moving_left);
	new_state(moving_up | moving_down | moving_right | moving_left) = 0;
	
	zero = 0; one = 1; two = 2; three = 3; MAX_VALUE = 4;
	zeroed_memory = zeros(size(memory));
	mem_stage_1_vertical = zeroed_memory; 
	mem_stage_1_vertical_last_column = zeroed_memory; 
	mem_stage_1_horizontal = zeroed_memory;
	mem_stage_1_right_bottom_corner = zeroed_memory;
	mem_stage_2_unmoving_last_column = zeroed_memory;
	mem_stage_2_unmoving_border_horizontal = zeroed_memory;
	mem_stage_2_special_left_to_right_bottom = zeroed_memory;
	mem_stage_2_2final_moving_down = zeroed_memory;
	mem_stage_2_2final_moving_up = zeroed_memory;
	mem_stage_2_2final_moving_right = zeroed_memory;
	mem_stage_2_stop_up = zeroed_memory;
	mem_stage_2_stop_bottom = zeroed_memory;

	mem_stage_1_vertical(Conv2(stage_1_vertical, m_up, 'same')) = zero;
	mem_stage_1_vertical_last_column(Conv2(stage_1_vertical_last_column, m_up, 'same')) = one;
	mem_stage_1_horizontal(Conv2(stage_1_horizontal, m_left, 'same')) = zero;
	mem_stage_1_right_bottom_corner(Conv2(stage_1_right_bottom_corner, m_left, 'same')) = three;
	mem_stage_2_unmoving_last_column(stage_2_unmoving_last_column & ~moving) = one;
	mem_stage_2_unmoving_border_horizontal(stage_2_unmoving_border_horizontal & ~moving) = one;
	mem_stage_2_special_left_to_right_bottom(stage_2_special_left_to_right_bottom) = one;
	mem_stage_2_2final_moving_down(Conv2(stage_2_2final_moving_down, m_down, 'same')) = one;
	mem_stage_2_2final_moving_up(Conv2(stage_2_2final_moving_up, m_up, 'same')) = one;
	mem_stage_2_2final_moving_right(Conv2(stage_2_2final_moving_right, m_right, 'same')) = one;
	mem_stage_2_stop_up(Conv2(stage_2_stop_up, m_down, 'same')) = one;
	mem_stage_2_stop_bottom(Conv2(stage_2_stop_bottom, m_up, 'same')) = one;
	
	if(Any(stage_2_stop_up + stage_2_stop_bottom + stage_2_one_row))
		stop = true;
	end
	
	new_memory = memory;
	new_memory(new_state == params.no_vehicle) = 0;
	new_memory(state == params.no_vehicle) = memory(new_state == params.no_vehicle);
	memory_change = ...
		mem_stage_1_vertical + ...
		mem_stage_1_vertical_last_column + ...
		mem_stage_1_horizontal + ...
		mem_stage_1_right_bottom_corner + ...
		mem_stage_2_unmoving_last_column + ...
		mem_stage_2_unmoving_border_horizontal + ...
		mem_stage_2_special_left_to_right_bottom + ...
		mem_stage_2_2final_moving_down + ...
		mem_stage_2_2final_moving_up + ...
		mem_stage_2_2final_moving_right + ...
		mem_stage_2_stop_up + ...
		mem_stage_2_stop_bottom;
	new_memory = new_memory + memory_change;
	new_memory(stage_2_zero_passing_on_the_right) = two;
	new_memory = mod(new_memory, MAX_VALUE);

end

function [anyset] = Any(m)
	anyset =  any(any(m));
end

function [anyset] = Sum(m)
	anyset =  sum(sum(m));
end

function [ConvB] = Conv2(M1, M2, type)
	ConvB = boolean(conv2(double(M1), double(M2), type));
end
