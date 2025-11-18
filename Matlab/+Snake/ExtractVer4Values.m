 n = 10; % sizes of the table
 m = 10;
% y_no_vehicle = 8; % set empty cell
% x_no_vehicle = 7;

% n = randi(12); % sizes of the table
% m = randi(12);
y_no_vehicle = randi(n); % set empty cell
x_no_vehicle = randi(m);

version_to_run = 8; % apply algo
enable_color_tracking = true;
fakeparam = 0;
pause_for = 0.01;
params = SimulationParameters(n, m, true, pause_for, version_to_run, ...
	fakeparam, (255 - [51;255;51]) / 255, (255 - [255;153;153]) / 255, enable_color_tracking);

params.suppress_output = true;

area_map = MapAreas(params);

interesting_points = [100;99;95;92;91;90;89;85;82;81;80;71;20;19;12;11;10;9;5;2;1];
memory_map = zeros(4, 5, 9);
direction_map = zeros(4, 5, 9);
map_initialized = false(4, 5, 9);

for i=1:size(interesting_points, 1)
	state = ones(n, m);
    state(interesting_points(i)) = params.no_vehicle;
    
    neighbors = GetNeighbors(n, m, interesting_points(i));
    actual_neighbors = neighbors(neighbors ~= 0);
    empty_space_from = mod((1:size(neighbors, 1))' + 1, 4) + 1;
    empty_space_from = empty_space_from(neighbors ~= 0);
    
    for j=0:255
        memory = zeros(n, m);
        
        neighbor_entry = 1;
        k = j;
        while(k > 0)
            if(neighbors(neighbor_entry) > 0)
                memory(neighbors(neighbor_entry)) = mod(k, 4);
            end
            k = idivide(k, uint8(4), 'floor');
            neighbor_entry = neighbor_entry + 1;
        end
        
        [ new_state, new_memory, collided, stop ] = Snake.SnakeTailVer4( state, memory, params );
        if ~collided
            entry_indexes = sub2ind(size(map_initialized), memory(actual_neighbors) + 1, empty_space_from, area_map(actual_neighbors));
            already_initialized = map_initialized(entry_indexes);
            already_set_mem_value = memory_map(entry_indexes);
            already_set_dir_value = direction_map(entry_indexes);
            moved_to = new_state(actual_neighbors) == params.no_vehicle;
            curr_mem_value = new_memory(actual_neighbors);
            curr_mem_value(moved_to) = new_memory(state == params.no_vehicle);
            curr_dir_value = params.do_nothing * ones(size(actual_neighbors));
            curr_dir_value(moved_to) = empty_space_from(moved_to) - 1;
            
            if(any(already_set_mem_value(already_initialized) ~= curr_mem_value(already_initialized)) || ...
                any(already_set_dir_value(already_initialized) ~= curr_dir_value(already_initialized)))
                fprintf('Inconsistency detected\n');
                return;
            end
            
            map_initialized(entry_indexes) = true;
            memory_map(entry_indexes) = curr_mem_value;
            direction_map(entry_indexes) = curr_dir_value;
        else
            % fprintf('Collision detected\n');
        end
        
        % remove setting-s
        new_memory(actual_neighbors) = memory(actual_neighbors);
        new_memory(state == params.no_vehicle) = 0;
        % new_state(actual_neighbors) = state(actual_neighbors);
        % new_state(state == params.no_vehicle) = params.no_vehicle;
        if(any(any(new_memory ~= memory)))
            fprintf('Changes detected for still agents\n');
        end
    end    
end

PrintFSM('+Snake/FSMv4.txt', memory_map, direction_map, map_initialized);

% end of main script

function [neighbors] = GetNeighbors(n, m, ind)
    x = idivide(uint16(ind - 1), n);
    y = mod(ind - 1, n);
    
    neighbors = zeros(4, 2);
    if(y > 0)
        neighbors(1, :) = [x, y - 1 + 1];
    end
    if(x < m - 1)
        neighbors(2, :) = [x+1, y + 1];
    end
    if(y < n - 1)
        neighbors(3, :) = [x, y + 1 + 1];
    end
    if(x > 0)
        neighbors(4, :) = [x-1, y + 1];
    end
    
    neighbors = neighbors * [n; 1];
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

function [] = PrintFSM(filename, memory_map, direction_map, initialized_map)
    fileId = fopen(filename, 'w');
	
fprintf(fileId, 'classdef FSMv4 < Snake.AbstractFSM\n');
	fprintf(fileId, '\t%%FSMV4 is a recreation of v4 into the new format\n');
fprintf(fileId, '\n');
	fprintf(fileId, '\tproperties\n');
		fprintf(fileId, '\t\tmemory_map;\n');
		fprintf(fileId, '\t\tdirection_map;\n');
	fprintf(fileId, '\tend\n');
fprintf(fileId, '\n');
	fprintf(fileId, '\tmethods\n');
		fprintf(fileId, '\t\tfunction obj = FSMv4()\n');
			fprintf(fileId, '\t\t\terror = Snake.AbstractFSM.error;\n');
			fprintf(fileId, '\t\t\tdo_nothing = Snake.AbstractFSM.do_nothing;\n');
			fprintf(fileId, '\t\t\t%% agent decision\n');	
			fprintf(fileId, '\t\t\tgo_north = Snake.AbstractFSM.go_north; go_east = Snake.AbstractFSM.go_east;\n');
			fprintf(fileId, '\t\t\tgo_south = Snake.AbstractFSM.go_south; go_west = Snake.AbstractFSM.go_west;\n');
fprintf(fileId, '\n');
			fprintf(fileId, '\t\t\tobj.bits_in_memory = 2;\n');
			fprintf(fileId, '\t\t\tobj.memory_map = error * ones(2 ^ obj.bits_in_memory, 4, 9); %% 5 is when no input is given\n');
			fprintf(fileId, '\t\t\tobj.direction_map = error * ones(2 ^ obj.bits_in_memory, 4, 9);\n');

	for state=1:9
			fprintf(fileId, '\t\t\tobj.memory_map(:, :, %d) = [ ...\n', state);
		for bit = 1:4
				fprintf(fileId, '\t\t\t\t\t');
			for col = 1:4			
				if(initialized_map(bit, col, state))
					fprintf(fileId, '%d', memory_map(bit, col, state));
				else
					fprintf(fileId, 'error');
				end
				if(col < 4)
					fprintf(fileId, ',');
				else
					if(bit < 4)
						fprintf(fileId, '; ...\n');
					else
						fprintf(fileId, '];\n');
					end
				end
			end
		end
	end
fprintf(fileId, '\n');

	movements = {'go_north'; 'go_east'; 'go_south'; 'go_west'; 'do_nothing'; 'error'; 'stop' };
	for state=1:9
			fprintf(fileId, '\t\t\tobj.direction_map(:, :, %d) = [ ...\n', state);
		for bit = 1:4
				fprintf(fileId, '\t\t\t\t\t');
			for col = 1:4			
				if(initialized_map(bit, col, state))
					fprintf(fileId, '%s', movements{direction_map(bit, col, state) + 1});
				else
					fprintf(fileId, 'error');
				end
				if(col < 4)
					fprintf(fileId, ',');
				else
					if(bit < 4)
						fprintf(fileId, '; ...\n');
					else
						fprintf(fileId, '];\n');
					end
				end
			end
		end
	end

		fprintf(fileId, '\t\tend\n');
fprintf(fileId, '\n');
		fprintf(fileId, '\t\tfunction [result_memory_map] = GetMemoryMap(this)\n');
			fprintf(fileId, '\t\t\tresult_memory_map = this.memory_map;\n');
		fprintf(fileId, '\t\tend\n');
fprintf(fileId, '\n');
		fprintf(fileId, '\t\tfunction [result_direction_map] = GetDirectionMap(this)\n');
			fprintf(fileId, '\t\t\tresult_direction_map = this.direction_map;\n');
		fprintf(fileId, '\t\tend\n');
fprintf(fileId, '\n');
	fprintf(fileId, '\tend\n');
fprintf(fileId, '\n');	
fprintf(fileId, 'end\n');

    fclose(fileId);
end
