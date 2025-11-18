classdef (Abstract) BasicCircles
	%BASICCIRCLES provides interface for executing little circles algorithm
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%           VISIBILITY RANGE           %
	%                ------                %
	%                | 21 |                %
	%           -----+----+-----           %
	%           | 20 |  9 | 13 |           %
	%      -----+----+----+----+-----      %
	%      | 19 |  8 |  1 |  5 | 14 |      %
	% -----+----+----+----+----+----+----- %
	% | 24 | 12 |  4 | me |  2 | 10 | 22 | %
	% -----+----+----+----+----+----+----- %
	%      | 18 |  7 |  3 |  6 | 15 |      %
	%      -----+----+----+----+-----      %
	%           | 17 | 11 | 16 |           %
	%           -----+----+-----           %
	%                | 23 |                %
	%                ------                %
	%                                      %
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	properties (Access = protected, Constant)
		% column / row detectors
		M0_COLUMN = 2; M1_COLUMN = 10; M2_COLUMN = 22;
        L0_COLUMN = 4;
		U0_ROW = 1; U1_ROW = 9; U2_ROW = 21;
		D0_ROW = 3; D1_ROW = 11; D2_ROW = 23;
	end
	
	properties (Access = public, Constant)
		% field indexes
		MY_STATUS = 1;
		DIRECTION = LittleCircles.BasicCircles.MY_STATUS + 1;
		NEIGHBORS_EXITING = LittleCircles.BasicCircles.DIRECTION + 1;
		NEIGHBORS_CONTINUE = LittleCircles.BasicCircles.NEIGHBORS_EXITING + 1;
		REQUIREMENTS_COLUMN = LittleCircles.BasicCircles.NEIGHBORS_CONTINUE + 1;
		REQUIREMENTS_ROW = LittleCircles.BasicCircles.REQUIREMENTS_COLUMN + 1;
		FIELD_COUNT = LittleCircles.BasicCircles.REQUIREMENTS_ROW;	
		
		ME = 25;
	end
	
	properties (Access = public)
		VCONTINUE;
		VEXIT;
		EMPTY;
		NORTH;
		EAST;
		SOUTH;
		WEST;		
	end
	
	properties (Access = protected)
		priorities;
	end
	
	methods
		function [obj] = BasicCircles(params)
			obj.VCONTINUE = params.vehicle_continue;
			obj.VEXIT = params.vehicle_exit;
			obj.EMPTY = params.no_vehicle;

			% ok we need to understand if coverage should work or some 1 is in the neighborhood of acting cells
			% we can fast and furious ignore more than one empty cell currently

			obj.NORTH = params.north + 1;
			obj.EAST = params.east + 1;
			obj.SOUTH = params.south + 1;
			obj.WEST = params.west + 1;
		end
		
		[updated_memory] = UpdateMemoryBeforeAlgoExecution(this, state, memory, neighborhood);
		
		function [priorities] = GetPriorities(this)
			%% priorities
			% if other rule also fires, the highest priority wins

			priorities = this.priorities;
		end
		
		function [no_priority] = GetNoPriority(this)
			no_priority = size(this.priorities, 1) + 1;
		end
	end
	
end

