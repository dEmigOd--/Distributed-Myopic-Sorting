classdef (Abstract) TimerStateMachine < Cylinders.StateMachine.GenericStateMachine
    %TIMERSTATEMACHINE this state machine will track modular timer automatically
    % Check out that timer are LSB bits
    
    methods (Access = protected, Static)
        function stateMachine = CreatePatchedStateMachine(masks, state_index, timerBits, column_list)
            timerSize = 2 ^ timerBits;
            % patch action memories
            for column=1:size(column_list, 2)
                for action=1:size(column_list{1, column}{1,2}, 2)
                    column_list{1, column}{1,2}{1, action}.new_memory = timerSize * column_list{1, column}{1,2}{1, action}.new_memory + ...
                        mod(action, timerSize);
                end
            end
            % call for state machine creation procedure
            stateMachine = Cylinders.StateMachine.GenericStateMachine.CreateStateMachine(masks, state_index, column_list);
        end        
    end
    
    methods (Access = protected)
        function stateMachine = CreateStateMachine(this, masks, state_index, column_list)
            stateMachine = Cylinders.StateMachine.TimerStateMachine.CreatePatchedStateMachine(masks, state_index, this.TimerBits, column_list);
        end
    end  
    
end

