classdef (Abstract) AbstractState < handle
    %ABSTRACTSTATE State interface
    
    methods (Abstract)
        [new_memory_state, action] = GetAction(this, readings);
        
        [active_internal_states] = GetNumberOfStatesRequired(this);        
        [handleable_states] = GetHandleableStates(this);
        [neighbor_rows, neighbor_columns] = GetNeighborsToTrace(this);
        [new_memories, actions] = GetActions(this);
    end
end

