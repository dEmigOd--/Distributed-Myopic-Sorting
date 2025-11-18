classdef AbstractTable < handle
    %ABSTRACTTABLE table interface
    
    methods
        grid = GetGrid(this);
        
        [sizes, object_occupancy] = GetAsyncGrid(this); 
        
        [] = ProcessTimeStep(this);
        
        [] = DebugMemory(this);
        [memory] = GetMemory(this);
    end
end

