classdef LittleCirclesv5 < LittleCircles.BasicCircles
	%LITTLECIRCLESV5 Little Circles v5 - Supports only 2 rows
	
	methods
		function [obj] = LittleCirclesv5(params)
			obj = obj@LittleCircles.BasicCircles(params);

			%% constants
			VEXIT = obj.VEXIT;
			VCONTINUE = obj.VCONTINUE;
			NORTH = obj.NORTH;
			EAST = obj.EAST;
			SOUTH = obj.SOUTH;
			WEST = obj.WEST;
			L0_COLUMN = LittleCircles.BasicCircles.L0_COLUMN; 
			M0_COLUMN = LittleCircles.BasicCircles.M0_COLUMN; 
			M1_COLUMN = LittleCircles.BasicCircles.M1_COLUMN; 
			U0_ROW = LittleCircles.BasicCircles.U0_ROW; 
			D0_ROW = LittleCircles.BasicCircles.D0_ROW; 
			
			%% states
            exit_move_to_corner = 3;
            exit_move_right = 5;
            up_right_1 = 6;
            up_right_2 = 7;
            up_right_3 = 1;
            up_right_4 = 2;
            exit_move_down = 4;
            continue_move_in7 = 8;
            continue_move_in2 = 9;
            continue_move_in5 = 10;
            continue_move_in1 = 11;

			PRIORITIES_COUNT = continue_move_in5;

			priorities = cell(PRIORITIES_COUNT, LittleCircles.BasicCircles.FIELD_COUNT);

			priorities(exit_move_to_corner, :) = {     VEXIT,  EAST,	{5},	{},  {M1_COLUMN},         {}};
			priorities(    exit_move_right, :) = {     VEXIT,  EAST,	 {},	{},           {},         {}};
			priorities(         up_right_1, :) = {        [], SOUTH,	{6},    {},           {},         {}};
			priorities(         up_right_2, :) = {	      [],  WEST,	{3},    {},           {},         {}};
			priorities(         up_right_3, :) = {	      [],  WEST,	{7},    {},           {},         {}};
			priorities(         up_right_4, :) = {	      [], NORTH,	{4},    {},           {},         {}};
			priorities(     exit_move_down, :) = {     VEXIT, SOUTH,	 {},    {},           {},         {}};
			priorities(  continue_move_in7, :) = { VCONTINUE,  EAST,	 {},    {},           {},	{U0_ROW}};
			priorities(  continue_move_in2, :) = { VCONTINUE, NORTH,	 {},    {},  {L0_COLUMN},         {}};
			priorities(  continue_move_in5, :) = { VCONTINUE,  WEST,	 {},    {},           {},	{D0_ROW}};
			priorities(  continue_move_in1, :) = { VCONTINUE, SOUTH,	 {},    {},  {M0_COLUMN},         {}};
			
			obj.priorities = priorities;			
		end
		
		function [updated_memory] = UpdateMemoryBeforeAlgoExecution(~, ~, memory, ~)
            updated_memory = memory;
		end
	end
	
end

