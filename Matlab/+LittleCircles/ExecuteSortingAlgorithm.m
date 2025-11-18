function [  new_state, new_memory, collided, stopped  ] = ExecuteSortingAlgorithm( state, memory, params )
	%EXECUTESORTINGALGORITHM Always try to execute circles, otherwise do covering
	
	VCONTINUE = params.vehicle_continue;
	VEXIT = params.vehicle_exit;
	EMPTY = params.no_vehicle;
	WALL = params.wall;
	FAKE_EMPTY = WALL + 1;
	
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
	stopped = false;

	if(size(state, 2) == 1)
		fprintf('One lane roads are already solved, aka by definition\n');
		stopped = true;
		return;
	end
	if(size(state, 2) == 2)
		[ new_state, new_memory, collided, stopped ] = Beads.ExecuteTwoColumnSorting( state, memory, params );
		return;		
	end
	if(size(state, 1) == 1)
		if ((state(1, end) == VCONTINUE) || ((state(1, end) == EMPTY) && (state(1, end - 1) == VCONTINUE)))
			fprintf('One row road with exit vehicle left to some continuing is unsolvable\n');
		else
			fprintf('This state is trivially solvable\n');
		end
		stopped = true;
		return;
	end
	if(size(state, 1) == 2 && params.sorting_algo_version ~= 5 && params.coverage_algo_version ~= 0)
		fprintf('2 row roads should be handled by special 0 bit-memory algorithm\n');
		stopped = true;
		return;
	end
	
	circlesAlgo = feval(sprintf('LittleCircles.LittleCirclesv%d', params.sorting_algo_version), params);
    patcherAlgo = feval(sprintf('LittleCircles.Patcher.Patchv%d', params.coverage_algo_version), params);
	% get priorities as agent sees them, ignore the internal state
	[my_priority, neighbors_priority, suspected_neighbors_priority] = ...
		GetPriorities(circlesAlgo, state, neighborhood, params);
	
	move_intentions = (my_priority < min(neighbors_priority, suspected_neighbors_priority));
	has_intentions = (my_priority < neighbors_priority) & (my_priority > suspected_neighbors_priority);
	move_intentions = move_intentions | (has_intentions & (memory == 3));
	
	if (MeAndMyNeighborsSeeThingsDifferently(state, params, my_priority, neighbors_priority, suspected_neighbors_priority))
		printf('Potentially they can move\n');
		stopped = true;
		return;
	end
	
	if(Utility.Helper.Sum(move_intentions) > 1)
		collided = true;
		fprintf('Sorting: collision detected (priority conflict)\n');
		return;
	end
	
	memory = patcherAlgo.UpdateMemoryBeforeApplyingCoverageAlgorithm(state, memory, neighborhood);

	if(Utility.Helper.Any(move_intentions))
        new_memory = patcherAlgo.UpdateMemoryAfterApplyingSortingAlgorithm(state, memory, neighborhood, move_intentions);
		
		new_memory(move_intentions) = 0;
		new_state(state == EMPTY) = state(move_intentions);
		new_state(move_intentions) = EMPTY;
	else
		if(~Utility.Helper.Any(has_intentions))
		
			% simulate covering algo to detect movable pieces
			[sim_state, sim_memory, sim_collided, sim_stopped] = Snake.SingleCoverageAlgorithm(state, memory, params);

			if(sim_collided)
				collided = true;
				fprintf('Sorting: collision detected (searching conflict)\n');
				return;
			end

			new_state = sim_state;
			new_memory = sim_memory;
			stopped = sim_stopped;
		else
			MeAndMyNeighborsSeeThingsDifferently(state, params, my_priority, neighbors_priority, suspected_neighbors_priority, ~params.suppress_output);
            if(~params.suppress_output)
                fprintf('Has intensions fired\n');
            end
		end		
	end
    if(Utility.Helper.Any(has_intentions & ~move_intentions))
        new_memory(has_intentions & ~move_intentions) = 3;
    end
	
    new_memory = patcherAlgo.UpdateMemoryUnconditionally(state, new_memory, neighborhood);
	
	if(~Utility.Helper.Any(new_state(:, end) ~= VEXIT) && ((new_memory(2, end) == 3) || (params.sorting_algo_version == 5)))
		stopped = true;
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

function [my_priority, neighbors_priority, suspected_neighbors_priority] = ...
		GetPriorities(circlesAlgorithm, state, neighborhood, params)
	NORTH = circlesAlgorithm.NORTH;
	WEST = circlesAlgorithm.WEST;

	% neighborhood indexes
	neighborhood_indexes = [...
		 0,  0,  0, 21,  0,  0,  0;
		 0,  0, 20,  9, 13,  0,  0;
		 0, 19,  8,  1,  5, 14,  0;
		24, 12,  4, -1,  2, 10, 22;
		 0, 18,  7,  3,  6, 15,  0;
		 0,  0, 17, 11, 16,  0,  0;
		 0,  0,  0, 23,  0,  0,  0;
		];
	
	ni_lookup = zeros(numel(neighborhood_indexes), 1);
	for i = 1:numel(ni_lookup)
		if(neighborhood_indexes(i) > 0)
			ni_lookup(neighborhood_indexes(i)) = i;
		end
	end
	
	%% priorities
	% if other rule also fires, the highest priority wins
	
	% field indexes
	DIRECTION = LittleCircles.BasicCircles.DIRECTION;
	NEIGHBORS_EXITING = LittleCircles.BasicCircles.NEIGHBORS_EXITING;
	NEIGHBORS_CONTINUE = LittleCircles.BasicCircles.NEIGHBORS_CONTINUE;
	
	priorities = circlesAlgorithm.GetPriorities();
	PRIORITIES_COUNT = size(priorities, 1);

	no_priority = circlesAlgorithm.GetNoPriority();
	my_priority = no_priority * ones(size(state));
	is_priority = true([size(state), PRIORITIES_COUNT]);
	for pi = PRIORITIES_COUNT:-1:1
		current_priority = ConvertPriority(state, neighborhood, neighborhood_indexes, ni_lookup, priorities(pi, :), params);
		
		is_priority(:, :, pi) = current_priority;
		my_priority(current_priority) = pi;
	end
	
	neighbors_priority = no_priority * ones(size(state));
	suspected_neighbors_priority = no_priority * ones(size(state));
	for direction = NORTH:WEST		
		for npi = PRIORITIES_COUNT:-1:1
			if direction ~= priorities{npi, DIRECTION}
				priority_entry = CreateOffsetPriorityRule(neighborhood_indexes, ni_lookup, priorities(npi, :), direction, params);
				if(~isempty(priority_entry))
					[current_priority, suspicious] = ConvertPriority(state, neighborhood, neighborhood_indexes, ni_lookup, priority_entry, params);
					% if unable to decide, since not everything is visible
					if((~isempty(priority_entry{NEIGHBORS_EXITING}) && any(ismember(cell2mat(priority_entry{NEIGHBORS_EXITING}), 0))) || ...
							(~isempty(priority_entry{NEIGHBORS_CONTINUE}) && any(ismember(cell2mat(priority_entry{NEIGHBORS_CONTINUE}), 0))) || ...
							suspicious)
						suspected_neighbors_priority(current_priority) = npi;
					else
						neighbors_priority(current_priority) = npi;
					end
				end
			end
		end
	end

end

function [offsetted_priority] = CreateOffsetPriorityRule(neighborhood_indexes, ni_lookup, priority_entry, direction, params)
	acting_neighbors = [ ...
		-1,  8,  9,  5;
		 6, -1,  5, 10;
		11,  7, -1,  6;
		 7, 12,  8, -1;
		];
	
	% field indexes
	MY_STATUS = LittleCircles.BasicCircles.MY_STATUS;
	DIRECTION = LittleCircles.BasicCircles.DIRECTION;
	NEIGHBORS_EXITING = LittleCircles.BasicCircles.NEIGHBORS_EXITING;
	NEIGHBORS_CONTINUE = LittleCircles.BasicCircles.NEIGHBORS_CONTINUE;
	REQUIREMENTS_COLUMN = LittleCircles.BasicCircles.REQUIREMENTS_COLUMN;
	REQUIREMENTS_ROW = LittleCircles.BasicCircles.REQUIREMENTS_ROW;
	
	VCONTINUE = params.vehicle_continue;
	VEXIT = params.vehicle_exit;
	
	[new_column_rule, is_impossible, do_not_care] = ...
			GetOffsettedColumnRule(neighborhood_indexes, direction, ...
			priority_entry{DIRECTION}, priority_entry{REQUIREMENTS_COLUMN});
	if (is_impossible)
		offsetted_priority = {};
		return;
	end
	if (do_not_care)
		new_column_rule = {};
	end
	[new_row_rule, is_impossible, do_not_care] = ...
			GetOffsettedRowRule(neighborhood_indexes, direction, ...
			priority_entry{DIRECTION}, priority_entry{REQUIREMENTS_ROW});
	if (is_impossible)
		offsetted_priority = {};
		return;
	end
	if (do_not_care)
		new_row_rule = {};
	end
	my_status = [];
	[me_in_list, neighbors_exiting] = ...
		ExtractNeighbors(neighborhood_indexes, ni_lookup, priority_entry{NEIGHBORS_EXITING}, direction, priority_entry{DIRECTION});
	if(me_in_list)
		my_status = VEXIT;
	end
	[me_in_list, neighbors_continue] = ...
		ExtractNeighbors(neighborhood_indexes, ni_lookup, priority_entry{NEIGHBORS_CONTINUE}, direction, priority_entry{DIRECTION});
	if(me_in_list)
		my_status = VCONTINUE;
	end
	if (~isempty(priority_entry{MY_STATUS}))
		if(priority_entry{MY_STATUS} == VEXIT)
			neighbors_exiting{1, end+1} = acting_neighbors(direction, priority_entry{DIRECTION});
		else
			neighbors_continue{1, end+1} = acting_neighbors(direction, priority_entry{DIRECTION});
		end
	end
	offsetted_priority = ...
	{ ...
		my_status, ...
		direction, ...
		neighbors_exiting, ...
		neighbors_continue, ...
		new_column_rule, ...
		new_row_rule ...
	};
end

function [me_in_list, neighbors_extracted] = ...
		ExtractNeighbors(neighborhood_indexes, ni_lookup, neighbors, direction, neighbor_direction)
	me_in_list = false;
	
	neighbors_extracted = GetOffsettedNeighbors(neighborhood_indexes, ni_lookup, neighbors, direction, neighbor_direction);
	if(any(ismember(cell2mat(neighbors_extracted), -1)))
		me_in_list = true;
		mat_neighbors = cell2mat(neighbors_extracted);
		neighbors_extracted = num2cell(mat_neighbors(mat_neighbors ~= -1));
	end
end

function [new_line_rule, is_impossible, do_not_care] = ...
		GetOffsettedLineRule(available_lines, my_direction, neighbor_direction, neighbor_line, base_line)
	is_impossible = false;
	do_not_care = false;
	new_line_rule = {};
	
	lookup(available_lines) = (1:numel(available_lines))';
	
	absent_rule = isempty(neighbor_line);
	if(~absent_rule)		
		nc_lookup_index = lookup(abs(neighbor_line{:}));
		detected_sign  = sign(neighbor_line{:});
	else
		nc_lookup_index = 0;
		detected_sign = -1;
	end
	
	my_index = base_line(my_direction) - base_line(neighbor_direction) + nc_lookup_index;
	
	if my_index <= 0
		if (absent_rule || (neighbor_line{1} < 0))
			do_not_care = true;
		else
			is_impossible = true;
		end
		return;
	end
	if my_index > numel(available_lines)
		new_line_rule{1} = -available_lines(end);
		return;
	end
	
	new_line_rule{1} = detected_sign * available_lines(my_index);
end

% function [new_column_rule, is_impossible, do_not_care] = ...
% 		GetOffsettedColumnRule(neighborhood_indexes, my_direction, neighbor_direction, neighbor_column)
% 	ME = LittleCircles.BasicCircles.ME;
% 	available_columns = neighborhood_indexes(ME + size(neighborhood_indexes, 1) * (1:3)');
% 	[new_column_rule, is_impossible, do_not_care] = ...
% 		GetOffsettedLineRule(available_columns, my_direction, neighbor_direction, neighbor_column, [0;1;0;-1]);
% end
function [new_column_rule, is_impossible, do_not_care] = ...
		GetOffsettedRColumnRule(available_columns, my_direction, neighbor_direction, neighbor_column)
	[new_column_rule, is_impossible, do_not_care] = ...
		GetOffsettedLineRule(available_columns, my_direction, neighbor_direction, neighbor_column, [0;1;0;-1]);
end
function [new_column_rule, is_impossible, do_not_care] = ...
		GetOffsettedLColumnRule(available_columns, my_direction, neighbor_direction, neighbor_column)
	[new_column_rule, is_impossible, do_not_care] = ...
		GetOffsettedLineRule(available_columns, my_direction, neighbor_direction, neighbor_column, [0;-1;0;1]);
end
function [new_column_rule, is_impossible, do_not_care] = ...
		GetOffsettedColumnRule(neighborhood_indexes, my_direction, neighbor_direction, neighbor_column)
	ME = LittleCircles.BasicCircles.ME;
	available_l_columns = neighborhood_indexes(ME - size(neighborhood_indexes, 1) * (1:3)');
	available_r_columns = neighborhood_indexes(ME + size(neighborhood_indexes, 1) * (1:3)');
	new_column_rule = [];
	if (isempty(neighbor_column) || ismember(abs(neighbor_column{1}), available_l_columns))
		[new_column_rule, is_impossible, do_not_care] = ...
			GetOffsettedLColumnRule(available_l_columns, my_direction, neighbor_direction, neighbor_column);
	end
	if ((isempty(neighbor_column) || ismember(abs(neighbor_column{1}), available_r_columns)) && isempty(new_column_rule))
		[new_column_rule, is_impossible, do_not_care] = ...
			GetOffsettedRColumnRule(available_r_columns, my_direction, neighbor_direction, neighbor_column);
	end
end

function [new_row_rule, is_impossible, do_not_care] = ...
		GetOffsettedURowRule(available_rows, my_direction, neighbor_direction, neighbor_row)
	[new_row_rule, is_impossible, do_not_care] = ...
		GetOffsettedLineRule(available_rows, my_direction, neighbor_direction, neighbor_row, [1;0;-1;0]);
end
function [new_row_rule, is_impossible, do_not_care] = ...
		GetOffsettedDRowRule(available_rows, my_direction, neighbor_direction, neighbor_row)
	[new_row_rule, is_impossible, do_not_care] = ...
		GetOffsettedLineRule(available_rows, my_direction, neighbor_direction, neighbor_row, [-1;0;1;0]);
end
function [new_row_rule, is_impossible, do_not_care] = ...
		GetOffsettedRowRule(neighborhood_indexes, my_direction, neighbor_direction, neighbor_row)
	ME = LittleCircles.BasicCircles.ME;
	available_u_rows = neighborhood_indexes(ME - (1:3)');
	available_d_rows = neighborhood_indexes(ME + (1:3)');
	new_row_rule = [];
	if (isempty(neighbor_row) || ismember(abs(neighbor_row{1}), available_u_rows))
		[new_row_rule, is_impossible, do_not_care] = ...
			GetOffsettedURowRule(available_u_rows, my_direction, neighbor_direction, neighbor_row);
	end
	if ((isempty(neighbor_row) || ismember(abs(neighbor_row{1}), available_d_rows)) && isempty(new_row_rule))
		[new_row_rule, is_impossible, do_not_care] = ...
			GetOffsettedDRowRule(available_d_rows, my_direction, neighbor_direction, neighbor_row);
	end
end

function [current_priority, suspicious] = ConvertPriority(state, neighborhood, neighborhood_indexes, ni_lookup, priorities_entry, params)
	MY_STATUS = LittleCircles.BasicCircles.MY_STATUS;
	DIRECTION = LittleCircles.BasicCircles.DIRECTION;
	NEIGHBORS_EXITING = LittleCircles.BasicCircles.NEIGHBORS_EXITING;
	NEIGHBORS_CONTINUE = LittleCircles.BasicCircles.NEIGHBORS_CONTINUE;
	REQUIREMENTS_COLUMN = LittleCircles.BasicCircles.REQUIREMENTS_COLUMN;
	REQUIREMENTS_ROW = LittleCircles.BasicCircles.REQUIREMENTS_ROW;
	
	VCONTINUE = params.vehicle_continue;
	VEXIT = params.vehicle_exit;
	EMPTY = params.no_vehicle;
	WALL = params.wall;

	suspicious = false;
	current_priority = true(size(state));
	if ~isempty(priorities_entry{MY_STATUS})
		current_priority = current_priority & (state == priorities_entry{MY_STATUS});
	end
	current_priority = current_priority & (neighborhood(:, :, priorities_entry{DIRECTION}) == EMPTY);
	for ni=1:numel(priorities_entry{REQUIREMENTS_COLUMN})
		[closer_columns, exact_column, wall_absent] = GetColumns(neighborhood_indexes, ni_lookup, priorities_entry{REQUIREMENTS_COLUMN}{1, ni});
		if wall_absent
			[~, ncol] = find(neighborhood_indexes == exact_column);
			if(ncol == size(neighborhood_indexes, 2))
				suspicious = true;
			end
			current_priority = current_priority & (neighborhood(:, :, exact_column) ~= WALL);
		else
			for cl = 1:numel(closer_columns)
				if(closer_columns(cl) ~= exact_column)
					current_priority = current_priority & (neighborhood(:, :, closer_columns(cl)) ~= WALL);
				else
					current_priority = current_priority & (neighborhood(:, :, exact_column) == WALL);
				end
			end
		end
	end
	for ni=1:numel(priorities_entry{REQUIREMENTS_ROW})
		[closer_rows, exact_row, wall_absent] = GetRows(neighborhood_indexes, ni_lookup, priorities_entry{REQUIREMENTS_ROW}{1, ni});
		if wall_absent
			[nrow, ~] = find(neighborhood_indexes == exact_row);
			if((nrow == size(neighborhood_indexes, 1)) || (nrow == 1))
				suspicious = true;
			end
			current_priority = current_priority & (neighborhood(:, :, exact_row) ~= WALL);
		else
			for cr = 1:numel(closer_rows)
				if(closer_rows(cr) ~= exact_row)
					current_priority = current_priority & (neighborhood(:, :, closer_rows(cr)) ~= WALL);
				else
					current_priority = current_priority & (neighborhood(:, :, exact_row) == WALL);
				end
			end
		end
	end
	detected_neighbors = cell2mat(priorities_entry{NEIGHBORS_EXITING});
	detected_neighbors = detected_neighbors(detected_neighbors > 0);
	for vi=1:numel(detected_neighbors)
		current_priority = current_priority & (neighborhood(:, :, detected_neighbors(vi)) == VEXIT);
	end
	detected_neighbors = cell2mat(priorities_entry{NEIGHBORS_CONTINUE});
	detected_neighbors = detected_neighbors(detected_neighbors > 0);
	for vi=1:numel(detected_neighbors)
		current_priority = current_priority & (neighborhood(:, :, detected_neighbors(vi)) == VCONTINUE);
	end
end

function [offsetted_indexes] = GetOffsettedNeighbors(neighborhood_indexes, ni_lookup, neighbors, movement_direction, direction)
	% offsets are relative in neighborhood_indexes
	offset = [...
		0, 1;
		-1, 0;
		0, -1;
		1, 0;
	];

	offsetted_indexes = {};
	if(isempty(neighbors))
		return;
	end
	
	effective_offset = offset(direction, :) - offset(movement_direction, :);
	% check out visibility range is currently enough to see all decision variables
	ME = LittleCircles.BasicCircles.ME;
	neighbors = cell2mat(neighbors);
	neighbors(neighbors == -1) = ME;
	offsetted_indexes = num2cell(neighborhood_indexes(ni_lookup(neighbors)' + effective_offset * [size(neighborhood_indexes, 1); 1]));
end

function [closer_lines, exact_line, wall_absent] = GetLines(neighborhood_indexes, ni_lookup, line_index, x_step, y_step)
	ME = LittleCircles.BasicCircles.ME;
	
	if ni_lookup(abs(line_index)) < ME
		x_step = -x_step;
		y_step = -y_step;
	end
	
	wall_absent = line_index < 0;
	exact_line = abs(line_index);

	closer_lines = [];
	step = size(neighborhood_indexes, 1) * x_step + y_step;
	if ~wall_absent
		closer_lines = neighborhood_indexes(ME+step:step:ni_lookup(exact_line));
	end	
end

function [closer_columns, exact_column, wall_absent] = GetColumns(neighborhood_indexes, ni_lookup, column_index)
	[closer_columns, exact_column, wall_absent] = GetLines(neighborhood_indexes, ni_lookup, column_index, 1, 0);
end

function [closer_rows, exact_row, wall_absent] = GetRows(neighborhood_indexes, ni_lookup, row_index)
	[closer_rows, exact_row, wall_absent] = GetLines(neighborhood_indexes, ni_lookup, row_index, 0, 1);
end

function [] = PrintCellState(neighbors, index, my_priority, neighbors_priority, suspected_neighbors_priority)	
	sz = size(my_priority);
	cell_index = sub2ind(sz, index(:, 1), index(:, 2));
	neighbors = sub2ind(sz, neighbors(:, 1), neighbors(:, 2));
	if(ismember(cell_index, neighbors))
		fprintf('%2d/%2d', my_priority(cell_index), min(neighbors_priority(cell_index), suspected_neighbors_priority(cell_index)));
	else
		fprintf('%*c', 5, ' ');			
	end
end

function [problematic_view] = MeAndMyNeighborsSeeThingsDifferently(state, params, my_priority, neighbors_priority, ...
		suspected_neighbors_priority, produce_output)
	persistent output_no;
	if(isempty(output_no))
		output_no = 0;
	end
	
	EMPTY = params.no_vehicle;
	sz = size(state);
	[zr, zc] = ind2sub(sz, find(state == EMPTY));
	% get 4 possible neighbors indices
	neighbors(1:4, 1:2) = [zr + [-1;0;1;0] zc + [0;1;0;-1]];
	% drop neighbors who are not on patch, i.e. in 0th column etc.
	neighbors = neighbors(all(neighbors, 2) & neighbors(:, 1) <= sz(1) & neighbors(:, 2) <= sz(2), :);
	% create circulant matrix of those neighbors
	movable_agents = gallery('circul', sub2ind(sz, neighbors(:, 1), neighbors(:, 2)));

	self_priorities = my_priority(movable_agents(1, :));
	seen_by_others_priorities = neighbors_priority(movable_agents(2:end, :));
	suspected_by_others_priorities = suspected_neighbors_priority(movable_agents(2:end, :));
	deduced_by_others = min(seen_by_others_priorities, suspected_by_others_priorities);
	problematic_view = Utility.Helper.Any(self_priorities < max(deduced_by_others, [], 1));
	
	if(nargin >= 6 && produce_output)
		output_no = output_no + 1;
		potential_neighbors = [zr + [-1;0;1;0] zc + [0;1;0;-1]];
		fprintf('\n\tEmpty space neighborhood state [self/min_seen_or_suspected] (ref. %d)\n', output_no);
        fprintf('%*c', 6, ' ');
        if (OnTable(sz, potential_neighbors(1, :)))
            PrintCellState(neighbors, potential_neighbors(1, :), my_priority, neighbors_priority, suspected_neighbors_priority);
        end
        fprintf('%*c\n', 6, ' ');
        if (OnTable(sz, potential_neighbors(4, :)))
            PrintCellState(neighbors, potential_neighbors(4, :), my_priority, neighbors_priority, suspected_neighbors_priority);
        end
        fprintf('%*c', 6, ' ');
        if (OnTable(sz, potential_neighbors(2, :)))
            PrintCellState(neighbors, potential_neighbors(2, :), my_priority, neighbors_priority, suspected_neighbors_priority);
        end
        fprintf('\n');
        fprintf('%*c', 6, ' ');
        if (OnTable(sz, potential_neighbors(3, :)))
            PrintCellState(neighbors, potential_neighbors(3, :), my_priority, neighbors_priority, suspected_neighbors_priority);
        end
        fprintf('%*c\n', 6, ' ');
	end
end

function [onTable] = OnTable(size, my_indexes)
    onTable = ~any(my_indexes == 0) && ~any(my_indexes > size);
end