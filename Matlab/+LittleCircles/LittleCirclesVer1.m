function [ new_state, new_memory, collided, stop ] = LittleCirclesVer1( state, memory, params )
	%LITTLECIRCLESVER1 Execute covering algorithm, until exiting vehicle found
	% move exiting vehicle by small circles around to (m-1) and m columns
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%           VISIBILITY RANGE           %
	%                ------                %
	%                | 21 |                %
	%           -----+----+-----           %
	%           | 20 |  9 | 13 |           %
	%      -----+----+----+----+-----      %
	%      | 19 |  8 |  1 |  5 | 14 |      %
	% -----+----+----+----+----+----+----- %
	% | 24 | 12 |  4 | me |  2 | 10 | 22 | %
	% -----+----+----+----+----+----+----- %
	%      | 18 |  7 |  3 |  6 | 15 |      %
	%      -----+----+----+----+-----      %
	%           | 17 |  9 | 16 |           %
	%           -----+----+-----           %
	%                | 23 |                %
	%                ------                %
	%                                      %
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	VCONTINUE = params.vehicle_continue;
	VEXIT = params.vehicle_exit;
	EMPTY = params.no_vehicle;
	WALL = params.wall;
	FAKE_EMPTY = WALL + 1;
	
	switch(params.run_version)
		case 5
			CoverageAlgorithm = @SnakeTailVer5;
		case 6
			CoverageAlgorithm = @SnakeTailVer6;
		otherwise
			CoverageAlgorithm = @SnakeTailVer4;
	end
	
	% calculate neighborhoods of all cells
	unzeroed_state = state;
	unzeroed_state(unzeroed_state == EMPTY) = FAKE_EMPTY;
	neighborhood = GetNeighborhood(unzeroed_state);
	neighborhood(neighborhood == 0) = WALL;
	neighborhood(neighborhood == FAKE_EMPTY) = EMPTY;
	
	% set return values to defaults
	new_state = state;
	new_memory = memory;
	collided = false;
	stop = false;

	% column detectors
	m_column = false(size(state)); m_column(:, end) = true;
	m1_column = false(size(state));
	m2_column = false(size(state));
	u_row = false(size(state));
	u1_row = false(size(state));
	d_row = false(size(state));
	d1_row = false(size(state));
	
	if(size(state, 2) > 1)
		m1_column(:, end - 1) = true;
	else
		fprintf('One lane roads are already solved, aka by definition\n');
		stop = true;
		return;
	end
	if(size(state, 2) > 2)
		m2_column(:, end - 2) = true;
	else
		fprintf('Need to think how to handle two column roads\n');
		% tipa chetki, tuda-suda
		stop = true;
		return;		
	end
	if(size(state, 1) == 1)
		if ((state(1, end) == VCONTINUE) || ((state(1, end) == EMPTY) && (state(1, end - 1) == VCONTINUE)))
			fprintf('One row road with exit vehicle left to some continuing is unsolvable\n');
		else
			fprintf('This state is trivially solvable\n');
		end
		stop = true;
		return;
	end
	if(size(state, 1) == 2)
		fprintf('Special algo should be implemented for 2 row roads\n');
		stop = true;
		return;
	end
	
	u_row(1, :) = true;
	u1_row(2, :) = true;
	d_row(end, :) = true;
	d1_row(end - 1, :) = true;
	
	% detect if we are yet to detect left bottom corner
	initialCovering = ~Any(memory(conv2(double(state == EMPTY), [0,1,0;1,0,1;0,1,0], 'same') > 0) > 1);
	
	if ~initialCovering
	% ok we need to understand if coverage should work or some 1 is in the neighborhood of acting cells
	% we can fast and furious ignore more than one empty cell currently
	
		% detect if this exiting vehicle can move east
		movable_ones_to_east = (neighborhood(:, :, 2) == EMPTY) & (state == VEXIT);
		movable_m1_ones_to_east = movable_ones_to_east & m1_column & (neighborhood(:, :,  5) ~= VEXIT);
		movable_other_ones_to_east = movable_ones_to_east & ~(m1_column | m2_column) & ...
			(neighborhood(:, :, 14) ~= VEXIT) & (neighborhood(:, :, 10) ~= VEXIT) & (neighborhood(:, :, 15) ~= VEXIT);
		movable_m2_to_east = (neighborhood(:, :, 2) == EMPTY) & m2_column & (memory == 3) & ...
			((state == VEXIT) | (neighborhood(:, :, 5) == VEXIT));

		down_cycle_step_0 = (neighborhood(:, :, 3) == EMPTY) & (state == VEXIT) & (neighborhood(:, :, 11) ~= VEXIT) & m_column;
		down_cycle_step_1 = (neighborhood(:, :, 2) == EMPTY) & (neighborhood(:, :, 6) == VEXIT) & (neighborhood(:, :, 16) == VCONTINUE) & m1_column;
		down_cycle_step_2 = (neighborhood(:, :, 1) == EMPTY) & (neighborhood(:, :, 2) == VEXIT) & (neighborhood(:, :,  6) == VCONTINUE) & m1_column;
		down_cycle_step_3 = (neighborhood(:, :, 1) == EMPTY) & (neighborhood(:, :, 5) == VEXIT) & (neighborhood(:, :,  2) == VCONTINUE) & m1_column;
		down_cycle_step_4 = (neighborhood(:, :, 4) == EMPTY) & (neighborhood(:, :, 1) == VEXIT) & ...
			((neighborhood(:, :,  3) ~= VEXIT) | (neighborhood(:, :,  11) ~= VCONTINUE)) & (state == VCONTINUE) & m_column;

		up_cycle_step_1 = (neighborhood(:, :, 2) == EMPTY) & (neighborhood(:, :, 5) == VEXIT) & m2_column & ...
			 ((memory == 3) | ((neighborhood(:, :, 10) == VEXIT) & (neighborhood(:, :, 15) ~= VCONTINUE)));
		up_cycle_step_2 = (neighborhood(:, :, 3) == EMPTY) & (neighborhood(:, :, 2) == VEXIT) & (neighborhood(:, :, 15) == VEXIT) & m2_column;
		intent_up_cycle_step_3 = (neighborhood(:, :, 3) == EMPTY) & (neighborhood(:, :, 6) == VEXIT) & m2_column;
		up_cycle_step_3 = intent_up_cycle_step_3 & (memory == 3);
		up_cycle_step_4 = (neighborhood(:, :, 4) == EMPTY) & (neighborhood(:, :, 3) == VEXIT) & m1_column;
		up_cycle_step_5 = (neighborhood(:, :, 1) == EMPTY) & (state == VEXIT) & (neighborhood(:, :, 2) == VEXIT) & m1_column & ~u1_row;
		up_cycle_step_6 = (neighborhood(:, :, 4) == EMPTY) & (neighborhood(:, :, 3) ~= VEXIT) & (neighborhood(:, :, 7) == VEXIT) & m_column;
		up_cycle_step_7 = (neighborhood(:, :, 1) == EMPTY) & (state ~= VEXIT) & (neighborhood(:, :, 4) == VEXIT) & m_column;

		down_right_cycle_state_1 = (neighborhood(:, :, 1) == EMPTY) & (neighborhood(:, :, 5) == VEXIT) & (neighborhood(:, :, 10) ~= VEXIT) & ~(m_column | m1_column);
		down_right_cycle_state_2 = (neighborhood(:, :, 4) == EMPTY) & (neighborhood(:, :, 1) == VEXIT) & (neighborhood(:, :, 2) ~= VEXIT) & ~m_column;
		down_right_cycle_state_3 = (neighborhood(:, :, 4) == EMPTY) & (neighborhood(:, :, 8) == VEXIT) & ...
			(state ~= VEXIT) & (neighborhood(:, :, 1) ~= VEXIT) & ...
			(~m_column | ((neighborhood(:, :, 3) ~= VEXIT) | (neighborhood(:, :, 11) == VEXIT)));
		down_right_cycle_state_4 = (neighborhood(:, :, 3) == EMPTY) & (neighborhood(:, :, 4) == VEXIT) & (neighborhood(:, :, 7) ~= VEXIT) & ...
			(state ~= VEXIT) & (~m_column | ((neighborhood(:, :, 11) ~= VEXIT) | (neighborhood(:, :, 23) == VEXIT))) & ...
			((neighborhood(:, :, 2) ~= VEXIT) | (neighborhood(:, :, 6) == VEXIT)) & ...
			((neighborhood(:, :, 6) ~= VEXIT) | (neighborhood(:, :, 16) ~= VCONTINUE)) & (neighborhood(:, :, 16) ~= VEXIT);

		up_right_cycle_state_1 = (neighborhood(:, :, 3) == EMPTY) & (neighborhood(:, :, 6) == VEXIT) & ~(m_column | m1_column) & d1_row;
		up_right_cycle_state_2 = (neighborhood(:, :, 4) == EMPTY) & (neighborhood(:, :, 3) == VEXIT) & ~(m_column | m1_column) & d1_row;
		up_right_cycle_state_3 = (neighborhood(:, :, 4) == EMPTY) & (neighborhood(:, :, 7) == VEXIT) & d1_row & ...
			 ~m_column & (neighborhood(:, :, 8) ~= VEXIT) & (~m1_column | ((state ~= VEXIT) & (neighborhood(:, :, 1) ~= VEXIT)));
		up_right_cycle_state_4 = (neighborhood(:, :, 1) == EMPTY) & (neighborhood(:, :, 4) == VEXIT) & d_row & ...
			~m_column & (neighborhood(:, :, 20) ~= VEXIT) & (neighborhood(:, :, 9) ~= VEXIT) & (neighborhood(:, :, 13) ~= VEXIT);

		up_corner_state_1 = (neighborhood(:, :, 4) == EMPTY) & (neighborhood(:, :, 7) == VEXIT) & (neighborhood(:, :, 3) == VEXIT) & u_row;
		up_corner_state_2 = (neighborhood(:, :, 1) == EMPTY) & (state == VEXIT) & (neighborhood(:, :, 4) == VEXIT) & u1_row & m_column;
		up_corner_state_3 = (neighborhood(:, :, 2) == EMPTY) & (state == VEXIT) & (neighborhood(:, :, 5) == VEXIT) & u1_row & m1_column;
		
		% detect who wants to move
		move_intentions = movable_m1_ones_to_east | movable_m2_to_east | movable_other_ones_to_east | ...
			down_cycle_step_0 | down_cycle_step_1 | down_cycle_step_2 | down_cycle_step_3 | down_cycle_step_4 | ...
			up_cycle_step_1 | up_cycle_step_2 | up_cycle_step_3 | up_cycle_step_4 | up_cycle_step_5 | up_cycle_step_6 | up_cycle_step_7 | ...
			down_right_cycle_state_1 | down_right_cycle_state_2 | down_right_cycle_state_3 | down_right_cycle_state_4 | ...
			up_right_cycle_state_1 | up_right_cycle_state_2 | up_right_cycle_state_3 | up_right_cycle_state_4 | ...
			up_corner_state_1 | up_corner_state_2 | up_corner_state_3;
	end
	
	if(~initialCovering && Sum(move_intentions) > 1)
		collided = true;
		fprintf('Sorting: collision detected\n');
		return;
	end	

	if(~initialCovering && Any(move_intentions))
		% we are near some one and moving it
		% set memory for moving into first or last row to 1
		new_memory(neighborhood(:, :, 2) == EMPTY & ~(u_row | d_row) & ~move_intentions) = 2;
		new_memory(neighborhood(:, :, 2) == EMPTY & (u_row | d_row) & ~move_intentions) = 1;
		new_memory(state == EMPTY & ~(u_row | d_row)) = 2;
		new_memory(state == EMPTY & (u_row | d_row)) = 1;
		
		move_intent_north = (neighborhood(:, :, 1) == EMPTY) & move_intentions;
		move_intent_east = (neighborhood(:, :, 2) == EMPTY) & move_intentions;
		move_intent_south = (neighborhood(:, :, 3) == EMPTY) & move_intentions;
		move_intent_west = (neighborhood(:, :, 4) == EMPTY) & move_intentions;
		
		new_memory(find(move_intent_north & state == VEXIT) - 1) = 3;
		new_memory(find(move_intent_east & state == VEXIT) + params.n) = 3;
		new_memory(find(move_intent_south & state == VEXIT) + 1) = 3;
		new_memory(find(move_intent_west & state == VEXIT) - params.n) = 3;
		new_memory(find(move_intent_north & state == VCONTINUE) - 1) = 2;
		new_memory(find(move_intent_east & state == VCONTINUE) + params.n) = 2;
		new_memory(find(move_intent_south & state == VCONTINUE) + 1) = 2;
		new_memory(find(move_intent_west & state == VCONTINUE) - params.n) = 2;
		
		new_memory(move_intentions) = 0;
		
		new_state(state == EMPTY) = state(move_intentions);
		new_state(move_intentions) = EMPTY;
	else
		if (~initialCovering)
			has_intent_but_cannot_decide_now = movable_ones_to_east | intent_up_cycle_step_3;
		end
		if(~initialCovering && Any(has_intent_but_cannot_decide_now)) % we are are in state where we want to move but not yet moving
			new_memory(has_intent_but_cannot_decide_now) = 2 + (memory(has_intent_but_cannot_decide_now) == 2);
		else
			% patch specific case in column m1
			memory(m1_column & (memory == 2) & (neighborhood(:, :, 3) == EMPTY) & ...
				(state ~= VEXIT) & (neighborhood(:, :, 6) == VEXIT)) = 3;

			% simulate covering algo to detect movable pieces
			[sim_state, sim_memory, sim_collided, sim_stopped] = CoverageAlgorithm(state, memory, params);

			new_state = sim_state;
			new_memory = sim_memory;
			collided = sim_collided;
			stop = sim_stopped;
			return;
		end
	end
	
	% detect cells without neighboring empty cells and re-ignite them
	no_empty_cell_neighbor = zeros(size(new_memory));
	for direction = 1:8
		no_empty_cell_neighbor = no_empty_cell_neighbor | (neighborhood(:, :, direction) == EMPTY);
	end
	new_memory((new_memory == 3) & ~no_empty_cell_neighbor & ~m_column & ~(u_row | d_row)) = 2;
	new_memory((new_memory >= 2) & ~no_empty_cell_neighbor & ~m_column & (u_row | d_row)) = 1;
	
	if((new_state(2, end) == VEXIT) && (new_memory(2, end) == 3) && (new_state(1, end) == VEXIT))
		stop = true;
	end
end

function [visibility_range] = GetNeighborhood(state)
	% hardcoded for visibility range manhattan = 3
	% convolution matrix of size 7x7 (indexes should be transposed + weird conv2)
	
	entries_to_set = ...
		[...
			32;24;18;26; ...
			31;17;19;33; ...
			39;23;11;27; ...
			38;30;16;10; ...
			12;20;34;40; ...
			46;22;4;28;
		];
	
	radius = 3;
	
	visibility_range = zeros(size(state, 1), size(state, 2), size(entries_to_set, 1));
	for i = 1: numel(entries_to_set)
		mask = zeros(2 * radius + 1);
		mask(entries_to_set(i)) = 1;
		mask = mask';
		visibility_range(:, :, i) = conv2(state, mask, 'same');
	end
end

function [anyset] = Any(m)
	anyset =  any(any(m));
end

function [anyset] = Sum(m)
	anyset =  sum(sum(m));
end
