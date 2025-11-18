classdef (Abstract) AbstractFSM
	%ABSTRACTFSM the main FSM interface
	
	properties (Constant, Access = protected)
		Stop = Parameters.SimulationParameters.Stop;
		Error = Parameters.SimulationParameters.Error;
		do_nothing = Parameters.SimulationParameters.do_nothing;
		% direction
		north = Parameters.SimulationParameters.north; 
        east = Parameters.SimulationParameters.east; 
        south = Parameters.SimulationParameters.south; 
        west = Parameters.SimulationParameters.west;
		% agent decision	
		go_north = Snake.AbstractFSM.north; go_east = Snake.AbstractFSM.east; 
		go_south = Snake.AbstractFSM.south; go_west = Snake.AbstractFSM.west;

        num_readings = 4;
    end
	
    methods (Static)
        function [printable] = IsPrintable()
            printable = true;
        end
    end
    
    methods
        function [result_lookup] = GetDirectionMapping(~)
            result_lookup = Utility.Helper.GetDirectionMapping();
        end
    end
    
	methods (Abstract)
		[result_memory_map] = GetMemoryMap(this);
		[result_direction_map] = GetDirectionMap(this);
	end
	
end

