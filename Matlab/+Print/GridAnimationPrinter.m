classdef GridAnimationPrinter < handle
    %GridAnimationPrinter Class to print grid frame by frame
    
    properties (Access = public, Constant)
        DirName = '../../Thesis/PhD Seminar/animations/';
    end
    
    properties (Access = private)
        printer;
        frameCounter;
        n;
        m;
        frameRate;
        scale; % grid could be easily too large, scale it down
        gridFileName;
    end
    
    methods (Access = private)
        function success = CreateWorkingDirectories(this)
            success = false;
            [result, ~, ~] = mkdir('../', this.DirName);
            if(~result)
                fprintf('Unable to create directory\n');
                return;
            end
            
            success = true;
        end
        
        function [str] = ToCommaSeparatedList(~, list, last)
            fmt=[',' repmat('%d,',1,size(list, 2)) ' '];
            str = sprintf(fmt(2:end-1-last), list);
        end
        
        function [] = PrintGrid(this, grid)
            this.printer.PrintLine('\renewcommand\grid{%');
            this.printer.BeginIndentation();
                for row=1:this.n
                    this.printer.PrintLine(this.ToCommaSeparatedList(grid(row, :), row == this.n));
                end
            this.printer.EndIndentation();
            this.printer.PrintLine('}');
        end
        
        function [] = AddPackage(this, packageName, packageOptions)
            packageStr = '\usepackage';
            if(nargin > 2)
                packageStr = strcat(packageStr, '[', packageOptions, ']');
            end
            packageStr = strcat(packageStr, '{', packageName, '}');
            this.printer.PrintLine(packageStr);
        end
        
        function [] = PrintHeader(this)
            this.printer.PrintLine('\documentclass[tikz]{standalone}');

            this.printer.PrintEndLine();

            this.AddPackage('standalone');
            this.AddPackage('import');
            this.AddPackage('animate');
            
            this.printer.PrintEndLine();

            this.printer.PrintLine('\newcommand\grid{}');
            
            this.printer.PrintEndLine();
        end
        
    end
    
    methods
        function obj = GridAnimationPrinter(n, m, gridFileName, frameRate, scale)
            obj.printer = Print.TabbedPrinter();
            obj.n = n;
            obj.m = m;
            obj.frameCounter = 0;
            if(nargin > 2)
                obj.gridFileName = gridFileName;
            else
                obj.gridFileName = 'grid.agents.common';
            end            
            if(nargin > 3)
                obj.frameRate = frameRate;
            end
            if(nargin > 4)
                obj.scale = scale;
            end
        end
        
        function [] = StartPrint(this, filename)
            if(~this.CreateWorkingDirectories())
                return;
            end
            
            this.printer.OpenFile(this.DirName, filename);
            
            this.PrintHeader();
            this.printer.BeginSection('document', '', '');
            this.printer.BeginSection('tikzpicture', '', '');

            this.printer.BeginFreeSection('animateinline', ['[autoplay, loop]{' num2str(this.frameRate) '}']);
        end
        
        function [] = EndPrint(this)
            this.printer.EndSection(); % animateinline
            
            this.printer.PrintEndLine();

            this.printer.EndSection(); % tikzpicture
            this.printer.EndSection(); % document
            
            this.printer.CloseFile();
        end
        
        function [] = PrintFrame(this, grid)
            %% TEX content
            this.frameCounter = this.frameCounter + 1;
            this.printer.PrintLine(['% frame No: ' num2str(this.frameCounter)]);
            if(this.frameCounter == 1)
                this.printer.BeginIndentation();
            else
                this.printer.BeginlessSection('newframe', '', '');
            end
            
            this.printer.PrintLine('\centering');
            this.printer.PrintLine(['\pgfmathtruncatemacro{\iN}{' num2str(this.n) '}']);
            this.printer.PrintLine(['\pgfmathtruncatemacro{\iM}{' num2str(this.m) '}']);
            
            this.PrintGrid(grid);
            
            if(this.scale < 1)
                this.printer.PrintLine(['scalebox{' num2str(this.scale) '}{'])
                this.printer.BeginIndentation();
            end
            this.printer.PrintLine(['\import{../images/}{' this.gridFileName '}']);
            if(this.scale < 1)                
                this.printer.EndIndentation();
                this.printer.PrintLine('}');
            end                

            this.printer.PrintEndLine();
            if(this.frameCounter == 1)
                this.printer.EndIndentation();
            else
                this.printer.EndSection
            end
        end
    end
end

