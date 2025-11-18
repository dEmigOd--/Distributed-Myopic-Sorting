classdef LeavingAgent < Cylinders.Agent.AgentWrapper
    %LEAVINGAGENT Agents capable of leaving the road in the right-most lane
    
    properties
        visibility;
    end
    
    methods
        function obj = LeavingAgent(actual_agent, ranger, row, column)
            obj = obj@Cylinders.Agent.AgentWrapper(actual_agent, ranger, row, column);
            obj.visibility = ranger.visibility;
        end
        
        function [action, new_row, new_column] = Decide(this, wholeRoad)
            % read sensors before we give its readings to agent
            visible_neighborhood = this.ranger.ReadNeighborhood(wholeRoad, this.row, this.column);
            
            % leave if possible
            if((visible_neighborhood(this.visibility + 1, this.visibility + 2) == Cylinders.Visibility.Constants.Wall) && this.GetToken())
                action = Cylinders.Visibility.Constants.go_east;
                new_row = this.row;
                new_column = this.column + 1;
            else
                [action, new_row, new_column] = Decide@Cylinders.Agent.AgentWrapper(this, wholeRoad);
            end
        end
    end
end

