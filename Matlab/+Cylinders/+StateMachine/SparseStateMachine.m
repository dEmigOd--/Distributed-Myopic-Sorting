classdef SparseStateMachine < Cylinders.StateMachine.GenericStateMachine
    %SPARSESTATEMACHINE State Machine that allows storing only specified
    % actions, others wil be marked as  NO ACTION
    % CHECK OUT: Print is not supported
    
    properties
        memorySize;
    end
    
    methods (Access = protected, Static)
        function stateMachine = CreatePatchedStateMachine(masks, state_index, memorySize, index_extract, column_list)
            patched_column_list = cell(1, size(column_list, 2));
            % patch actions and missing actions
            for column=1:size(column_list, 2)
                actions = cell(1, memorySize);
                for action = 1:memorySize
                    actions{action} = Cylinders.StateMachine.Action(memorySize - 1, Cylinders.Visibility.Constants.do_nothing);
                end
                for action=1:size(column_list{1, column}{1, 2}, 2)
                    actions{1 + index_extract(column_list{1, column}{1, 2}{1, action}{1, 1})} = ...
                        Cylinders.StateMachine.Action(column_list{1, column}{1, 2}{1, action}{1, 2}{1, 1}(column_list{1, column}{1, 2}{1, action}{1, 1}), ...
                            column_list{1, column}{1, 2}{1, action}{1, 2}{1, 2});
                end
                patched_column_list{1, column} = {column_list{1, column}{1, 1}, actions};
            end
            % call for state machine creation procedure
            stateMachine = Cylinders.StateMachine.GenericStateMachine.CreateStateMachine(masks, state_index, patched_column_list);
        end        
    end
    
    methods (Access = protected)
        function stateMachine = CreateStateMachine(this, masks, state_index, index_extract, column_list)
            this.memorySize = 2 ^ this.ValueBits;
            stateMachine = Cylinders.StateMachine.SparseStateMachine.CreatePatchedStateMachine(masks, state_index, this.memorySize, index_extract, column_list);
        end
    end  
    
    methods
        function [ignorable_states] = GetIgnorableStates(this)
            ignorable_states = [this.memorySize - 1];
        end        
    end
end

