classdef LittleCirclesv3 < LittleCircles.BasicCircles
	%LITTLECIRCLESV3 Little Circles v3 - the working (once) one
	
	properties (Access = private)
		m_column;
		m1_column;
	end
	
	methods
		function [obj] = LittleCirclesv3(params)
			obj = obj@LittleCircles.BasicCircles(params);

			%% constants
			VEXIT = obj.VEXIT;
			VCONTINUE = obj.VCONTINUE;
			NORTH = obj.NORTH;
			EAST = obj.EAST;
			SOUTH = obj.SOUTH;
			WEST = obj.WEST;
			M0_COLUMN = LittleCircles.BasicCircles.M0_COLUMN; 
			M1_COLUMN = LittleCircles.BasicCircles.M1_COLUMN; 
			M2_COLUMN = LittleCircles.BasicCircles.M2_COLUMN;
			U0_ROW = LittleCircles.BasicCircles.U0_ROW; 
			U1_ROW = LittleCircles.BasicCircles.U1_ROW;
			D0_ROW = LittleCircles.BasicCircles.D0_ROW; 
			D1_ROW = LittleCircles.BasicCircles.D1_ROW;
			
			%% states
			right_upper_cycle_1 = 1;
			right_upper_cycle_2 = 2;
			right_upper_cycle_3 = 3;
			down_cycle_1 = 6;
			down_cycle_2 = 5;
			down_cycle_3 = 7;
			down_cycle_4 = 8;
			down_cycle_5 = 9;
			up_cycle_1 = 10;
			up_cycle_2 = 11;
			up_cycle_3 = 12;
			up_cycle_4 = 13;
			up_cycle_5 = 14;
			up_cycle_6 = 16;
			up_cycle_7 = 17;
			up_cycle_8 = 18;
			up_cycle_9 = 19;
			up_cycle_10 = 4;
			down_right_1 = 27;
			down_right_2 = 20;
			down_right_3 = 15;
			down_right_4 = 21;
			down_right_5 = 23;
			down_right_6 = 26;
			up_right_1 = 25;
			up_right_2 = 22;
			up_right_3 = 24;
			up_right_4 = 28;

			PRIORITIES_COUNT = up_right_4;

			priorities = cell(PRIORITIES_COUNT, LittleCircles.BasicCircles.FIELD_COUNT);

			priorities(right_upper_cycle_1, :) = {	   VEXIT, SOUTH,      {6,16},    {2},  {M1_COLUMN},  {U0_ROW}};
			priorities(right_upper_cycle_2, :) = { VCONTINUE,  WEST,    {3,7,11},     {},  {M0_COLUMN},  {U0_ROW}};
			priorities(right_upper_cycle_3, :) = {	   VEXIT, NORTH,       {3,4},    {8},  {M0_COLUMN},  {U1_ROW}};
			priorities(       down_cycle_1, :) = {	   VEXIT, SOUTH,          {},     {},  {M0_COLUMN},        {}};
			priorities(       down_cycle_2, :) = { VCONTINUE,  EAST,         {6},   {16},  {M1_COLUMN},        {}};
			priorities(       down_cycle_3, :) = {        [], NORTH,         {2},    {6},  {M1_COLUMN}, {-D0_ROW}};
			priorities(       down_cycle_4, :) = {        [], NORTH,         {5},    {2},  {M1_COLUMN},        {}};
			priorities(       down_cycle_5, :) = { VCONTINUE,  WEST,         {1},     {},  {M0_COLUMN},        {}};
			priorities(         up_cycle_1, :) = {	   VEXIT, NORTH,         {2},     {},  {M1_COLUMN},        {}};
			priorities(         up_cycle_2, :) = {	   VEXIT, NORTH,          {},     {},  {M1_COLUMN},  {D0_ROW}};
			priorities(         up_cycle_3, :) = {        [],  EAST, {5, 10, 15},     {},  {M2_COLUMN}, {-U1_ROW}};
			priorities(         up_cycle_4, :) = {        [],  EAST,     {5, 10},     {},  {M2_COLUMN},  {D0_ROW}};
			priorities(         up_cycle_5, :) = {        [], SOUTH,     {2, 15},     {},  {M2_COLUMN}, {-U0_ROW}};
			priorities(         up_cycle_6, :) = {        [], SOUTH,         {6},     {},  {M2_COLUMN},        {}};
			priorities(         up_cycle_7, :) = { VCONTINUE,  WEST,         {3},     {},  {M1_COLUMN},        {}};
			priorities(         up_cycle_8, :) = { VCONTINUE,  WEST,         {7},    {3},  {M0_COLUMN},        {}};
			priorities(         up_cycle_9, :) = { VCONTINUE, NORTH,         {4},     {},  {M0_COLUMN}, {-D0_ROW}};
			priorities(         up_cycle_10, :) = {	   VEXIT,  EAST,          {},     {},  {M1_COLUMN}, {-D0_ROW}};
			priorities(       down_right_1, :) = {	   VEXIT,  EAST,          {},     {}, {-M1_COLUMN},        {}};
			priorities(       down_right_2, :) = {        [], NORTH,         {5},     {}, {-M1_COLUMN},        {}};
			priorities(       down_right_3, :) = {        [],  WEST,         {1},     {},  {M1_COLUMN},  {U1_ROW}};
			priorities(       down_right_4, :) = {        [],  WEST,         {1},     {}, {-M0_COLUMN},        {}};
			priorities(       down_right_5, :) = { VCONTINUE,  WEST,         {8},    {1},           {},        {}};
			priorities(       down_right_6, :) = { VCONTINUE, SOUTH,         {4},     {},           {},        {}};
			priorities(         up_right_1, :) = {        [], SOUTH,         {6},     {}, {-M1_COLUMN},  {D1_ROW}};
			priorities(         up_right_2, :) = {        [],  WEST,         {3},     {}, {-M0_COLUMN},  {D1_ROW}};
			priorities(         up_right_3, :) = { VCONTINUE,  WEST,         {7},     {},           {},  {D1_ROW}};
			priorities(         up_right_4, :) = { VCONTINUE, NORTH,         {4},     {}, {-M0_COLUMN},  {D0_ROW}};
			
			obj.priorities = priorities;
			
			obj.m_column = false(params.n, params.m);
			obj.m1_column = false(params.n, params.m);
			obj.m_column(:, end) = true;
			obj.m1_column(:, end - 1) = true;
			
		end
		
		function [updated_memory] = UpdateMemoryBeforeAlgoExecution(this, state, memory, neighborhood)
			EMPTY = this.EMPTY;
			VEXIT = this.VEXIT;
			
			updated_memory = memory;
			% patch specific case in column m1 to enable down searching without going up in m column
			updated_memory(this.m1_column & (memory == 2) & (neighborhood(:, :, 3) == EMPTY) & ...
				(state ~= VEXIT) & (neighborhood(:, :, 6) == VEXIT)) = 3;
			% patch 1 in the right bottom corner
			updated_memory(this.m_column & (state == VEXIT)) = 3;
		end
	end
	
end

