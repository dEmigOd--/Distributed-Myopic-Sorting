classdef GridRecorder < Recorder.BaseRecorder
    %GRIDRECORDER Records a grid in an animateinline tikz
    % currently look for C:\Users\dmitry.ra\Desktop\Studies\Articles\PhD\Thesis\PhD Seminar\images\grid.agents.common.tex
    
    properties
        n;
        m;
        filename;
        frameRate;
        printer;
        gridFileName;
    end
    
    methods
        function obj = GridRecorder(n, m, filename, gridFileName, frameRate)
            obj.n = n;
            obj.m = m;
            obj.filename = filename;
            obj.gridFileName = gridFileName;
            obj.frameRate = frameRate;            
        end
        
        function [] = PreRun(obj, table)
            obj.printer = Print.GridAnimationPrinter(obj.n, obj.m, obj.gridFileName, obj.frameRate);
            obj.printer.StartPrint([obj.filename '.' datestr(now, 'yyyy-mm-dd-HH-MM-SS')]);
            
            obj.PostStep(table);
        end
        
        function [] = PostRun(obj, table)
            obj.printer.EndPrint();
        end
        
        function [] = PreStep(obj, table)
        end
        
        function [] = PostStep(obj, table)
            obj.printer.PrintFrame(table.GetGrid());
        end
    end
end

