function [new_state] = ProcessRandomState(state, params, exit_prob_map, cont_prob_map)
%PROCESSRANDOMSTATE make a one time tick
	VCONTINUE = params.vehicle_continue;
	VEXIT = params.vehicle_exit;
	EMPTY = params.no_vehicle;
    
    all_zero_neighbors = uint8(conv2(state == EMPTY, [0,4,0; 2,0,8; 0,1,0], 'same'));
    all_zero_neighbors(state == EMPTY) = uint8(0);
    active = all_zero_neighbors > 0;
    active_exit = state == VEXIT & active;
    active_cont = state == VCONTINUE & active;
    
    round_probability = rand(size(state));
    round_probability(~active) = 2;
    
    area_map = Utility.Helper.MapAreas(params);
    
    probability = zeros(size(state));
    wants_to_move = zeros(size(state));
    
    for direction = 1:4
        probability(active_exit) = probability(active_exit) + exit_prob_map(sub2ind(size(exit_prob_map), ...
            area_map(active_exit), direction * ones(Utility.Helper.Sum(active_exit), 1)));
        probability(active_cont) = probability(active_cont) + cont_prob_map(sub2ind(size(cont_prob_map), ...
            area_map(active_cont), direction * ones(Utility.Helper.Sum(active_cont), 1)));
        % bit set and probability just right
        active_in_direction = (probability > round_probability) & (mod(idivide(all_zero_neighbors, 2 ^ (direction - 1)), 2) == 1);
        wants_to_move(active_in_direction) = 2 ^ (direction - 1);
        round_probability(probability > round_probability) = 2;
    end
    
    covered_zeros = conv2(wants_to_move == 1, [0,1,0; 0,0,0; 0,0,0], 'same') + ...
        conv2(wants_to_move == 2, [0,0,0; 0,0,1; 0,0,0], 'same') + ...
        conv2(wants_to_move == 4, [0,0,0; 0,0,0; 0,1,0], 'same') + ...
        conv2(wants_to_move == 8, [0,0,0; 1,0,0; 0,0,0], 'same');
    % ALOHA protocol
    free_zeros = (covered_zeros == 1) & (state == EMPTY);
    
    actually_moving = bitand(conv2(free_zeros, [0,4,0; 2,0,8; 0,1,0], 'same'), wants_to_move);
    offset = [-1, params.n, 1, -params.n];
    new_state = state;
    for direction = 1:4
        indexes_in_direction = find(actually_moving == 2 ^ (direction - 1));
        new_state(indexes_in_direction + offset(direction)) = state(indexes_in_direction);
    end
    new_state(actually_moving > 0) = EMPTY;
end

