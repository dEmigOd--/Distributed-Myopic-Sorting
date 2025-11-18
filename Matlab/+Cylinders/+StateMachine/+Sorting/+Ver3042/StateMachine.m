classdef StateMachine < Cylinders.StateMachine.Sorting.Ver3032.StateMachine
    %STATEMACHINE Actual Implementation of Sorting algorithm
    % works on AT LEAST TWO ROWS and TWO COLUMNS ! [Need to check]
    %
    % Based on covering algorithm Ver 9
    % This is a SORTING algorithm for 1's [CONTINUING vehicles]
    %
    % Ver = 304 (1 for exiting, 2 for continuing)
    %
    % 2 bit timer [LSB bits] - 00 and 01 are times at which COVERING algo is executed; 10 is the Pos 9 exiting vehicles moving  east; 11 - Pos 8
    % continuing vehicles moving west
    % 2 bit state : non-MSB bit - is the state bit for COVERING algo; both bits used at Pos 8 by continuing vehicles to count empty spaces moving up
    % in the one-to-last column (Pos 9). At the secong empty cell passing up - you are allowed to move West
end

