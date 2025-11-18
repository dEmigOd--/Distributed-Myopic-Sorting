classdef StateMachine < Cylinders.StateMachine.Sorting.Ver3101.StateMachine
    %STATEMACHINE Actual Implementation of Sorting algorithm
    % works on AT LEAST TWO ROWS and TWO COLUMNS ! [Need to check]
    %
    % Based on covering algorithm Ver 9
    % This is a SORTING algorithm for 1's [EXITING vehicles]
    %
    % Ver = 314 (310) (1 for exiting, 2 for continuing)
    %
    % 2 bit timer [LSB bits] - 00 and 01 are times at which COVERING algo is executed; 10 is the Pos 7,9 exiting vehicles moving  south; 11 - Pos 8
    % continuing vehicles moving west
    % 1 bit state : non-MSB bit - is the state bit for COVERING algo; 
    %
    % Fixing Move-West to be picked over North-South directions
    % revert Slow East movement in Position 7 continue vehicles
    % adds Position 1 faster Western movement
    %
    % WORKS
    
end

