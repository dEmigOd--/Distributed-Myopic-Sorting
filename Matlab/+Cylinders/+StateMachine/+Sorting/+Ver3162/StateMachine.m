classdef StateMachine < Cylinders.StateMachine.Sorting.Ver3102.StateMachine
    %STATEMACHINE Actual Implementation of Sorting algorithm
    % works on AT LEAST TWO ROWS and TWO COLUMNS ! [Need to check]
    %
    % Based on covering algorithm Ver 9
    % This is a SORTING algorithm for -1's [CONTINUING vehicles]
    %
    % Ver = 316 (1 for exiting, 2 for continuing)
    %
    % 2 bit timer [LSB bits] - 00 and 01 are times at which COVERING algo is executed; 10 is the Pos 9 exiting vehicles moving  east; 11 - Pos 8
    % continuing vehicles moving west
    % 1 bit state : non-MSB bit - is the state bit for COVERING algo; 
    %
    % == 310, only Exiting vehicles changed
    %
    % WORKS
end

