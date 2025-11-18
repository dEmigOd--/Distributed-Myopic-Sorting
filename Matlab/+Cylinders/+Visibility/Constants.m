classdef Constants
    %CONSTANTS 
    
    properties (Constant)
        Empty = 0;
        Agent = 1;
        Wall = Parameters.SimulationParameters.wall; % edge
        Unspecified = 3;
        Possibilities = Cylinders.Visibility.Constants.Unspecified + 1;
        
        north = Parameters.SimulationParameters.north;
        east = Parameters.SimulationParameters.east;
        south = Parameters.SimulationParameters.south;
        west = Parameters.SimulationParameters.west;

        go_north = Cylinders.Visibility.Constants.north;
        go_east = Cylinders.Visibility.Constants.east;
        go_south = Cylinders.Visibility.Constants.south;
        go_west = Cylinders.Visibility.Constants.west;
        do_nothing = Parameters.SimulationParameters.do_nothing;
		Error = Parameters.SimulationParameters.Error;
		Stop = Parameters.SimulationParameters.Stop;
    end
end
