classdef BasicSolver
    %BASICSOLVER The one that do not solve a thing
    
    methods
        function [moving_indexes, solved] = SolveCollision(~, want_to_move, ~)
            moving_indexes = want_to_move;
            solved = false;
            if(Utility.Helper.Sum(cellfun(@isempty, want_to_move)) == size(want_to_move, 1) - 1)
                solved = true;
            end
        end
    end
end

