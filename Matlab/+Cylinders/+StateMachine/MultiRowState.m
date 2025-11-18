classdef MultiRowState < Cylinders.StateMachine.AbstractState
    %MULTIROWSTATE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
        rows_of_states;
    end
    
    methods (Access = private)
    end
    
    methods
        function obj = MultiRowState(rows)
            obj.rows_of_states = rows;
        end
        
        function [new_memory_state, action] = GetAction(this, readings, memory_state)
%              if(1 + memory_state > size(this.rows_of_states, 1))
%                  fprintf('Hm');
%              end
            [new_memory_state, action] = this.rows_of_states{1 + memory_state}.GetAction(readings);
        end
        
        function [active_internal_states] = GetNumberOfStatesRequired(this)
            active_internal_states = sum(cellfun(@(x) x.GetNumberOfStatesRequired(), this.rows_of_states), 1);
        end
        
        function [handleable_states] = GetHandleableStates(this)
            if(size(this.rows_of_states, 1) > 0)
                handleable_states = this.rows_of_states{1}.GetHandleableStates();
            else
                handleable_states = {};
            end
        end
        
        function [neighbor_rows, neighbor_columns] = GetNeighborsToTrace(this)
            if(size(this.rows_of_states, 1) > 0)
                [neighbor_rows, neighbor_columns] = this.rows_of_states{1}.GetNeighborsToTrace();
            else
                neighbor_rows = 0;
                neighbor_columns = 0;
            end
        end
        
        function [new_memories, actions] = GetActions(this)
            if(~isempty(this.rows_of_states))
                innerOutput = cellfun(@(x) GetActionsOfWholeRow(x), this.rows_of_states, 'UniformOutput', false);
                singleOutputVector = vertcat(innerOutput{:});
                row_length = size(singleOutputVector, 1) / (2 * size(this.rows_of_states, 1));
                matrixOutput = reshape(singleOutputVector, row_length, size(singleOutputVector, 1) / row_length);
                new_memories = matrixOutput(:, 1:2:end)';
                actions = matrixOutput(:, 2:2:end)';
            else
                new_memories = {};
                actions = {};
            end
            
            function [singleOutput] = GetActionsOfWholeRow(state)
                [avec, bvec] = state.GetActions();
                singleOutput = [avec; bvec];
            end
        end      
    end
end

