classdef AgentWrapper < Cylinders.Agent.BasicAgent
    %AGENTWRAPPER class to break dependency of real agent on necessity to sense its position on the table
    
    properties (Access = protected)
        agent;
        ranger;
        row;
        column;
    end
    
    methods
        function obj = AgentWrapper(actual_agent, ranger, row, column)
            obj = obj@Cylinders.Agent.BasicAgent();

            obj.agent = actual_agent;
            obj.ranger = ranger;
            obj.row = row;
            obj.column = column;
        end
        
        function [action, new_row, new_column] = Decide(this, wholeRoad)
            % read sensors before we give its readings to agent
            visible_neighborhood = this.ranger.ReadNeighborhood(wholeRoad, this.row, this.column);
            % let agent decide on visible neighborhood
            action = this.agent.Decide(visible_neighborhood);
            
            % analyse results
            go_north = Cylinders.Visibility.Constants.go_north;
            go_east = Cylinders.Visibility.Constants.go_east;
            go_south = Cylinders.Visibility.Constants.go_south;
            go_west = Cylinders.Visibility.Constants.go_west;
            Error = Cylinders.Visibility.Constants.Error;
            
            if(action == Error)
                fprintf('Inconsistency detected by an agent at (%d, %d)\n', this.row, this.column);
            end
            
            new_row = this.row + (action == go_north) * (-1) + (action == go_south) * 1;
            new_column = this.column + (action == go_west) * (-1) + (action == go_east) * 1;
            
            if(new_row < 1 || new_column < 1 || new_row > size(wholeRoad, 1) || new_column > size(wholeRoad, 2))
                fprintf('An agent at (%d, %d) falls of off the road\n', this.row, this.column);
            end
            
            this.row = new_row;
            this.column = new_column;
        end
        
        function [memory, row, column] = DebugMemory(this)
            memory = this.agent.DebugMemory();
            row = this.row;
            column = this.column;
        end
    end
end

