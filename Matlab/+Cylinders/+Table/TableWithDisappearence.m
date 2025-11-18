classdef TableWithDisappearence < Cylinders.Table.Table
    %TABLEWITHDISAPPEARENCE The same regular road, but that lets exiting vehicles to disappear on the right
    
    methods(Access = protected)
        function next_id = CreateAgent(obj, actual_agent, ranger, row, column, current_id)
            obj.agents{current_id} = Cylinders.Agent.LeavingAgent(actual_agent, ranger, row, column);
            next_id = current_id + 1;
        end        
    end
    
    methods
        function obj = TableWithDisappearence(grid, params, versions, funcCreateAgent, funcExtractVisibility)
            obj = obj@Cylinders.Table.Table(grid, params, versions, funcCreateAgent, funcExtractVisibility);
        end
    end
end

