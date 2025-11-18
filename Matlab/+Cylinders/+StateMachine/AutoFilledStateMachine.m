classdef (Abstract) AutoFilledStateMachine < Cylinders.StateMachine.TimerStateMachine
    %AUTOFILLEDSTATEMACHINE All the positions will be auto-filled by copying
    % i.e. if there are 8 posibilities and only 2 first actions provided, than 
    % 4 copies will be stored
    
    methods (Access = protected, Static)
        function stateMachine = CreatePatchedStateMachine(masks, state_index, timerBits, valueBits, column_list)
            
            known_possible_states = 2 ^ (timerBits + valueBits);
            % patch missed actions
            for column=1:size(column_list, 2)
                actual_actions_defined = size(column_list{1, column}{1,2}, 2);
                if(actual_actions_defined < known_possible_states)
                    updated_actions = cell(1, known_possible_states);
                    for copy_no=0:(ceil(known_possible_states / actual_actions_defined) - 1)
                        updated_actions(1, copy_no * actual_actions_defined + (1:actual_actions_defined)) = ...
                            cellfun(@(x) x.GetCopy(), column_list{1, column}{1,2}(1, :), 'UniformOutput', false);
                    end
                    column_list{1, column}{1,2} = updated_actions;
                end
            end
            
            % call for state machine creation procedure
            stateMachine = Cylinders.StateMachine.TimerStateMachine.CreatePatchedStateMachine(masks, state_index, timerBits, column_list);
        end
    end
    
    methods (Access = protected)
        function stateMachine = CreateStateMachine(this, masks, state_index, column_list)
            stateMachine = Cylinders.StateMachine.AutoFilledStateMachine.CreatePatchedStateMachine(masks, state_index, ...
                this.TimerBits, this.ValueBits, column_list);
        end
    end  
    
end

