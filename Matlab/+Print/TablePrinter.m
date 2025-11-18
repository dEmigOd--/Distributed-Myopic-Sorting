classdef TablePrinter < handle
    %TABLEPRINTER the basic class to print the table of movement for Lemma
    
    properties (Access = public, Constant)
        NO_VALUE = {3};
        EMPTY = {};
        INCLUDE_TYPE = false;
    end
    
    properties (Access = private)
        printer;
    end
    
    methods (Access = private)
        function success = CreateWorkingDirectories(~)
            success = false;
            [result, ~, ~] = mkdir('./', 'Latex');
            if(~result)
                fprintf('Unable to create directory\n');
                return;
            end
            
            success = true;
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

            this.AddPackage('xcolor', 'table');
            this.AddPackage('booktabs');
            this.AddPackage('graphicx');
            this.AddPackage('multirow');
            this.AddPackage('adjustbox');
            this.AddPackage('standalone');
            this.AddPackage('tikz');
            this.AddPackage('amsmath');
            this.AddPackage('amssymb');
            this.AddPackage('fmtcount');
            this.printer.PrintLine('\usetikzlibrary{calc, patterns, intersections}');

            this.printer.PrintEndLine();
            
            this.printer.PrintLine('\newcommand*{\tabhead}[1]{\textbf{#1}}%');
           
            this.printer.PrintEndLine();
        end
        
        function [] = PrintCommentLine(this, length)
            this.printer.PrintLine(repelem('%', length));
        end
        
        function [] = PrintCommentSection(this, str)
                this.printer.PrintEndLine();

                this.PrintCommentLine(32);
                this.PrintCommentLine(1);
                this.printer.PrintLine(sprintf('%%\t%s', str));
                this.PrintCommentLine(1);
                this.PrintCommentLine(32);
        end
        
        function [] = PrintValue(this, str, isLastColumn, verticalAllignment)
            if(isLastColumn)
                str = strcat(str, ' \\');
            else
                str = strcat(str, ' &');
            end
            if(isLastColumn && verticalAllignment ~= 0)
                str = strcat(str, sprintf('[%d pt]', verticalAllignment));
            end
            this.printer.PrintLine(str);
        end
        
        function [] = PrintMultiRow(this, heightRow, optionalVerticalTextAllignment, str, isLastColumn, verticalAllignment)
            mrStr = sprintf('\\multirow{%d}{*}', heightRow);
            if(optionalVerticalTextAllignment ~= 0)
                mrStr = strcat(mrStr, sprintf('[%d pt]', optionalVerticalTextAllignment));
            end
            mrStr = strcat(mrStr, '{', str, '}');
            this.PrintValue(mrStr, isLastColumn, verticalAllignment);
        end
        
        function [columns] = PrintMultiRowHeader(this, heightRow, optionalHzAllignment, str, isLastColumn, verticalAllignment)
            this.PrintMultiRow(heightRow, optionalHzAllignment, strcat('\tabhead{',str,'}'), isLastColumn, verticalAllignment);
            columns = 1;
        end
        
        function [columns] = PrintMultiColumn(this, width, str, isLastColumn)
            mcStr = sprintf('\\multicolumn{%d}{c}{\\tabhead{%s}}', width, str);
            this.PrintValue(mcStr, isLastColumn, 0);
            columns = width;
        end
        
        function [columns] = PrintTabularDataHeader(this, hzAdjustment)
            this.printer.PrintLine('\toprule');
            this.PrintCommentSection('main column headers');

            columns = zeros(4, 1);
            if(this.INCLUDE_TYPE)
                columns(1) = this.PrintMultiRowHeader(3, hzAdjustment, 'Pos.', false, 0);
                columns(2) = this.PrintMultiRowHeader(3, hzAdjustment, 'Type', false, 0);
            else
                columns(1) = this.PrintMultiRowHeader(3, hzAdjustment, 'Position', false, 0);
                columns(2) = 0;
            end
            columns(3) = this.PrintMultiColumn(3, 'Neighborhood', false);
            columns(4) = this.PrintMultiColumn(5, 'Memory state', true);

            this.PrintCommentSection('sub-headers in the multi-column headers');
            ccols = cumsum(columns);
            for i=3:4
                this.printer.PrintLine(sprintf('\\cmidrule(lr){%d-%d}', ccols(i-1) + 1, ccols(i)));
            end
            this.PrintValue('', false);
            if(this.INCLUDE_TYPE)
                this.PrintValue('', false);
            end
            for i=3:4
                for j=0:(columns(i) - 1)
                    if(j == 0)
                        this.PrintValue('{$t$}', false, 0);
                    else
                        this.PrintValue(sprintf('{$t+%d$}', j), i == 4 && j == (columns(i) - 1), 0);
                    end
                end
            end

            this.PrintValue('\midrule\midrule', true, -7);
            % adjust for excluded column
            if(~this.INCLUDE_TYPE)
                columns(2) = 1;
            end
        end
        
        function [str] = LowLevelBeautify(this, wrkStr)
            str = '';
            for i=1:this.printer.tab_num+1
                str = strcat(str, '\t');
            end
            str = strcat(str, wrkStr);
        end
        
        function [imgStr] = PrepareImageString(this, version, values)
            type = values{1};
            state = values{2};
            neighborhood = values{3};
            formatStr = strcat('\\adjustbox{max width=\\NeighborhoodWidth cm}{%%\n', ...
								this.LowLevelBeautify('\\hspace{\\AdjustSpace em}%%\n'), ...
								this.LowLevelBeautify('\\input{../../Matlab/+Cylinders/Tables/Ver.%d%d/State_%d.Readings_%d}%%\n'), ...
                                this.LowLevelBeautify('}'));
            imgStr = sprintf(formatStr, version, type, state, neighborhood);
        end
        
        function [] = PrintTabularData(this, version, content)
            
            columnCount = 9 + this.INCLUDE_TYPE;
            this.printer.BeginSection('tabular', sprintf('*{%d}{c}', columnCount), '');
            
                columns = this.PrintTabularDataHeader(3); % some horizontal adjustment of headers
                ccols = cumsum(columns);
                
                starts = zeros(1, size(content, 2));
                ends = starts;
                
                for entry=1:size(content, 1)
                    % print new entry or position
                    if(~isempty(content{entry, 1}))
                        % do not print another midrule
                        if(entry ~= 1)
                            this.printer.PrintLine('\midrule \\ [-5 pt]');
                        end
                        this.PrintCommentSection(sprintf('POSITION %d', content{entry, 1}));
                    else
                        this.PrintCommentSection('Next entry');
                    end
                    % detect if the value in each column should be multirow value
                    for col=1:size(content, 2)
                        if(~isempty(content{entry, col}))
                            starts(col) = entry;
                            ends(col) = entry;
                            for row=entry+1:size(content, 1)
                                if(~isempty(content{row, col}))
                                    break;
                                end
                                ends(col) = row;
                            end
                        end
                    end
                    
                    %detect if we need to print a value now at all
                    for col=1:size(content, 2)
                        % suppress type column
                        if(col == 2 && ~this.INCLUDE_TYPE)
                            continue;
                        end
                        if(~isempty(content{entry, col}))
                            switch(col)
                                case 1
                                    str = sprintf('%d', content{entry, col});
                                case 2
                                    str = content{entry, col};
                                case num2cell(ccols(2)+1:ccols(3)-1)
                                    % those are images
                                    str = this.PrepareImageString(version, content{entry, col});
                                case ccols(3)
                                    if(content{entry, ccols(3)}{1} ~= this.NO_VALUE{1})
                                        str = this.PrepareImageString(version, content{entry, col});
                                    else
                                        str ='';
                                    end                                        
                                case ccols(3)+1
                                    str = strcat('$', dec2bin(content{entry, col}, 3), '_2$');
                                otherwise
                                    if(isnumeric(content{entry, col}))
                                        str = strcat('$', dec2bin(4 * content{entry, col} + mod(content{entry, ccols(3) + 1} + col - ccols(3) - 1, 4), 3), '_2$');
                                    else
                                        if(iscell(content{entry, col}) && ~isempty(content{entry, col}) && (content{entry, col}{1} == this.NO_VALUE{1}))
                                            str = '';
                                        else
                                            str = content{entry, col};
                                        end
                                    end
                            end
                            
                            additionalVerticalSpace = 5 * ((1 - mod(entry, 2)) + (ends(3) == entry));
                            
                            if(starts(col) ~= ends(col))
                                %verticalTextAdjustment = 0;
                                %if(col > ccols(2) && col < ccols(3))
                                    verticalTextAdjustment = 7 - 2.5 * (ends(col) - starts(col) + 1);
                                %end
                                
                                this.PrintMultiRow(ends(col) - starts(col) + 1, verticalTextAdjustment, str, ...
                                    col == size(content, 2), additionalVerticalSpace);
                            else
                                this.PrintValue(str, col == size(content, 2), additionalVerticalSpace);
                            end
                        else
                            this.PrintValue('', col == size(content, 2), additionalVerticalSpace);
                        end
                    end
                end
                
            this.printer.PrintEndLine();
            this.printer.PrintLine('\bottomrule');
            this.printer.EndSection();
        end
        
        function [] = PrintCaption(this, content)
            this.printer.PrintLine('\caption{');
            this.printer.PrintLine('Enumeration of possible visible neighborhoods');
            this.printer.PrintLine('and memory state sequences of');
            switch(content{1, 2})
                case 'E'
                    this.printer.PrintLine('an exiting');
                case 'C'
                    this.printer.PrintLine('a continue');
            end
            this.printer.PrintLine('agent.');
            this.printer.PrintLine('After East-West movement cessation.');
            this.printer.PrintLine('Grid position; visible $L_1$ neighborhood and memory state in the binary format');
            this.printer.PrintLine('are provided for short periods of time starting at $t$.');
            this.printer.PrintLine('Where applicable agent movement direction is given instead of a memory state.');
            this.printer.PrintLine('Relevant agent positions: ');
                states = content(:, 1);
                states = cell2mat(states(cellfun(@(x) ~isempty(x), states)));
            this.printer.PrintLine(sprintf('%d', states(1)));
            for i = 2:size(states, 1) - 1
                this.printer.PrintLine(sprintf('\\!\\!, %d', states(i)));
            end
            this.printer.PrintLine(sprintf(' and %d.', states(end)));
            this.printer.PrintLine('Impossible states are excluded from enumeration.');
            this.printer.PrintLine('}');
            this.printer.PrintLine(sprintf('\\label{table:for-lemma-no-stalls-%c-%s}', content{1, 2}, strcat(num2str(states)')));
        end
        
        function [] = PrintTable(this, version, content)
            
            this.printer.BeginSection('table', '', '');
                this.printer.PrintLine('\pgfmathsetmacro{\NeighborhoodWidth}{1.2}');
                this.printer.PrintLine('\pgfmathsetmacro{\AdjustSpace}{-4}');
                this.printer.PrintLine('\centering');
                
                this.PrintTabularData(version, content);
                
                this.PrintCaption(content);
            this.printer.EndSection();
            
        end
        
        function [] = PrintToFile(this, directory, filename, version, content)
            %% TEX content                
            this.printer.OpenFile(directory, filename);
            
            this.PrintHeader();
            this.printer.BeginSection('document', '', '');
            this.PrintTable(version, content);
            this.printer.EndSection();
            
            this.printer.CloseFile();
        end
    end
    
    methods
        function obj = TablePrinter()
            obj.printer = Print.TabbedPrinter();
        end
        
        function [] = Print(this, filename, version, idx, content)
            if(~this.CreateWorkingDirectories())
                return;
            end
            
            this.PrintToFile('Latex', sprintf('%s_%d_%d', filename, version, idx), version, content);
        end
    end
end



