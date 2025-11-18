classdef BaseRecorder < handle
    %BASERECORDER interface
    
    methods (Abstract)
        [] = PreRun(obj, table);        
        [] = PostRun(obj, table);
        [] = PreStep(obj, table);
        [] = PostStep(obj, table);
    end
end

