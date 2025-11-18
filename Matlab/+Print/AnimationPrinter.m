classdef AnimationPrinter < handle
    %ANIMATIONPRINTER Class to print road with vehicles frame by frame
    
    properties (Access = public, Constant)
        DirName = '2021.09.01. Algorithm Animations';
        ImagesDirName = '2020.11.10. Sorting Algorithm 310. Take 2/clipart';
    end
    
    properties (Access = private)
        printer;
        frameCounter;
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
        
        function [str] = ToCommaSeparatedList(~, list)
            fmt=[',' repmat('%.2f,',1,size(list, 1)) ' '];
            str = sprintf(fmt(2:end-2), list);
        end
        function [str] = ToCommaSeparatedList2D(~, mtx)
            fmt=[',' repmat('%.2f/%.2f,',1,size(mtx, 1)) ' '];
            str = sprintf(fmt(2:end-2), mtx');
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
            this.printer.PrintLine('\documentclass{article}');

            this.printer.PrintEndLine();

            this.AddPackage('standalone');
            this.AddPackage('graphicx');
            this.AddPackage('tikz');
            this.AddPackage('import');
%            this.printer.PrintLine('\usetikzlibrary{calc, patterns, intersections}');

            this.printer.PrintEndLine();
            
            this.printer.PrintLine(sprintf('\\graphicspath{{../%s/}{./images/}}', this.ImagesDirName));
           
            this.printer.PrintLine('\newcommand\righttrees{}');
            this.printer.PrintLine('\newcommand\lefttrees{}');
            this.printer.PrintLine('\newcommand\GreenCars{}');
            this.printer.PrintLine('\newcommand\RedCars{}');
            
            this.printer.PrintEndLine();
        end
        
    end
    
    methods
        function obj = AnimationPrinter()
            obj.printer = Print.TabbedPrinter();
            obj.frameCounter = 0;
        end
        
        function [] = StartPrint(this, filename)
            if(~this.CreateWorkingDirectories())
                return;
            end
            
            this.printer.OpenFile(['../' this.DirName], filename);
            
            this.PrintHeader();
            this.printer.BeginSection('document', '', '');
        end
        
        function [] = EndPrint(this)
            this.printer.EndSection();
            
            this.printer.CloseFile();
        end
        
        function [] = PrintFrame(this, ltrees, rtrees, gcars, rcars, distance)
            %% TEX content
            this.frameCounter = this.frameCounter + 1;
            this.printer.PrintLine(['% frame No: ' num2str(this.frameCounter)]);
            
            this.printer.PrintLine(['\renewcommand\lefttrees{' this.ToCommaSeparatedList(ltrees) '}']);
            this.printer.PrintLine(['\renewcommand\righttrees{' this.ToCommaSeparatedList(rtrees) '}']);
            this.printer.PrintLine(['\renewcommand\GreenCars{' this.ToCommaSeparatedList2D(gcars) '}']);
            this.printer.PrintLine(['\renewcommand\RedCars{' this.ToCommaSeparatedList2D(rcars) '}']);
            this.printer.PrintLine(['\pgfmathsetmacro{\distance}{' num2str(distance) '}']);
            this.printer.PrintLine('\import{.}{Frame.Moving.Cars}');

            this.printer.PrintEndLine();
        end
    end
end

