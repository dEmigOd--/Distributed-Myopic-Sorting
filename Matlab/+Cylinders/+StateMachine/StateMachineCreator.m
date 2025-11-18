classdef StateMachineCreator
    %STATEMACHINECREATOR Create State machine from version
    
    methods
        function [stateMachine] = CreateStateMachine(~, version)
            if(version < 1000) 
                stateMachine = Cylinders.StateMachine.(sprintf('Ver%d', version)).StateMachine();
            else
                stateMachine = Cylinders.StateMachine.Sorting.(sprintf('Ver%d', version)).StateMachine();
            end
        end
    end
end

