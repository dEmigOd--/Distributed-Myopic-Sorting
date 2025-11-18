classdef Async_Scheduler < handle
    %ASYNC_SCHEDULER create next action execution time
    % basically, we want move + post_move decision to take the same time as no_move + post no_move decision
    
    properties
        time_to_decision;
        time_to_forward_move;
        time_to_side_move;
    end
    
    methods
        function obj = Async_Scheduler(time_to_decision, time_to_forward_move, time_to_side_move)
            obj.time_to_decision = time_to_decision;
            obj.time_to_forward_move = time_to_forward_move;
            obj.time_to_side_move = time_to_side_move;
        end
        
        function time = GetForwardMoveDuration(obj)
            time = obj.time_to_forward_move;
        end
        
        function time = GetSideMoveDuration(obj)
            time = obj.time_to_side_move;
        end
        
        function time = GetDecisionDuration(obj)
            time = obj.time_to_decision;
        end
        
        function time = GetPostActionDecisionTime(obj)
            time = exprnd(0.5 * obj.GetDecisionDuration()); 
        end
        
        function time = GetDecisionTime(obj)
            time = exprnd(obj.GetDecisionDuration()); 
        end        
    end
end

