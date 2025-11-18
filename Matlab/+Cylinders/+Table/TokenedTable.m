classdef TokenedTable < Cylinders.Table.Table
    %TOKENEDTABLE Table with one of the agents holding a token
    
    properties (Access = private)
        ReverseAgentLookup;
    end
    
    methods(Access = protected)
        function next_id = CreateAgent(obj, state_machine, ranger, row, column, current_id)
            next_id = CreateAgent@Cylinders.Table.Table(obj, state_machine, ranger, row, column, current_id);
            % set token
            if(current_id == 1)
                obj.agents{1}.SetToken();
            end
        end        
        
        function  [action, new_row, new_column] = DecideForAgent(this, agent_id)
            % missing how the token is passed around
            [action, new_row, new_column] = this.agents{agent_id}.Decide(this.grid);
            this.debug_tracker(agent_id, :) = [new_row, new_column];
        end

    end
    
    methods
        function obj = TokenedTable(grid, version)
            obj = obj@Cylinders.Table.Table(grid, version);
        end
    end
end

