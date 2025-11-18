classdef (Abstract) AbstractFSM
	%ABSTRACTFSM the main beads FSM interface
	
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
		go_north = Beads.AbstractFSM.north; go_east = Beads.AbstractFSM.east; 
		go_south = Beads.AbstractFSM.south; go_west = Beads.AbstractFSM.west;

        % num_readings = 4;
    end
	
    methods (Static)
        function [printable] = IsPrintable()
            printable = true;
        end
    end
    
	methods (Abstract)
		[result_memory_map] = GetMemoryMap(this);
		[result_direction_map] = GetDirectionMap(this);
	end
	
end

