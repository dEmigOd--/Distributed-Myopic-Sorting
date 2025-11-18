classdef ALOHASolver < CollisionSolver.BasicSolver
    %ALOHASOLVER no collision, but none is moving
    
    methods
        function [moving_indexes, solved] = SolveCollision(~, want_to_move, ~)
            moving_indexes = cell(size(want_to_move));
            if(Utility.Helper.Sum(cellfun(@isempty, want_to_move)) == size(want_to_move, 1) - 1)
                moving_indexes = want_to_move;
            end
            solved = true;
        end
    end
end

