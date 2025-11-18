classdef RoadLightsSolver < CollisionSolver.BasicSolver
    %ROADLIGHTSSOLVER If there is collision, the moving one is the side who's turn it is
    % Otherwise, like ALOHA - no moevment
    
    methods
        function [moving_indexes, solved] = SolveCollision(~, want_to_move, iteration)
            zero_based_iteration = iteration - 1;
            if(~isempty(want_to_move{mod(zero_based_iteration, 4) + 1}))
                moving_indexes = cell(size(want_to_move));
                moving_indexes{mod(zero_based_iteration, 4) + 1} = want_to_move{mod(zero_based_iteration, 4) + 1};
                solved = true;
            else
                [moving_indexes, solved] = CollisionSolver.ALOHASolver().SolveCollision(want_to_move, iteration);
            end
        end
    end
end

