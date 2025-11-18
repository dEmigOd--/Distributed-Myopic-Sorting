classdef TempoSpatialPrinter < handle
    %TEMPOSPATIALPRINTER to visualize the state of the column throughout time
    
    properties (Access = private)
        automaticTab;
        scale;
    end
    
    methods(Access = private)
        function [] = PrintRow(obj, file, string)
            if(startsWith(string, '\end'))
                obj.automaticTab = obj.automaticTab - 1;
            end
            for i = 1:obj.automaticTab
                fprintf(file, '\t');
            end
            fprintf(file, '%s\n', string);
            if(startsWith(string, '\begin'))
                obj.automaticTab = obj.automaticTab + 1;
            end
        end
        
        function [] = PrintHeader(obj, file)
PrintRow(obj, file, '\documentclass[tikz]{standalone}');
PrintRow(obj, file, '');

PrintRow(obj, file, '\usepackage{tikz}');
PrintRow(obj, file, '\usepackage{standalone}');
PrintRow(obj, file, '\usetikzlibrary{arrows.meta}');
PrintRow(obj, file, '');

PrintRow(obj, file, '\begin{document}');
PrintRow(obj, file, '\begin{tikzpicture}');
PrintRow(obj, file, sprintf('\\pgfmathsetmacro{\\stepsize}{%0.1f}', obj.scale));
PrintRow(obj, file, '');

        end
        function [] = PrintFooter(obj, file)
PrintRow(obj, file, '');

PrintRow(obj, file, '\end{tikzpicture}');
PrintRow(obj, file, '\end{document}');
        end
        
        function [] = PrintGrid(obj, file, column_t)
            %[step=\\stepsize]
PrintRow(obj, file, sprintf('\\draw (0, 0) grid (%d * \\stepsize, %d * \\stepsize);', size(column_t')));
PrintRow(obj, file, '');
        end
        function [] = PrintBeginScope(obj, file)
PrintRow(obj, file, '\begin{scope}[black!40, opacity = 0.4]');
        end
        function [] = PrintEndScope(obj, file)
PrintRow(obj, file, '\end{scope}');
        end
        
        function [] = PrintNextTimeTick(obj, file, column, column_idx)
            indeces = find(flip(column));
            values = sprintf('%d,', indeces-1);
			PrintRow(obj, file, sprintf('\\foreach \\y in {%s}', values(1:end-1)));
			PrintRow(obj, file, '{');
				PrintRow(obj, file, sprintf('\t\\fill (%d * \\stepsize, \\y * \\stepsize) rectangle (%d * \\stepsize, \\y * \\stepsize + 1 * \\stepsize);', ...
                    column_idx - 1, column_idx));
			PrintRow(obj, file, '}');
        end
    end
    
    methods
        function obj = TempoSpatialPrinter(scale)
            obj.automaticTab = 0;
            obj.scale = scale;
        end
        
        function [] = Print(obj, columns, filename)
            for j = 1:size(columns, 2)
                obj.PrintColumn(reshape(columns(:, j, :), [size(columns, 1), size(columns, 3)]), ...
                    sprintf('%s.%d.tex', filename, j));
            end
        end
        
        function [] = PrintColumn(obj, column_t, filename)
            file = fopen(filename, 'w');
            
            obj.PrintHeader(file);
            obj.PrintGrid(file, column_t);
            
            obj.PrintBeginScope(file);
            
            for j = 1:size(column_t, 2)
                obj.PrintNextTimeTick(file, column_t(:, j), j);
            end
            
            obj.PrintEndScope(file);
            obj.PrintFooter(file);
            
            fclose(file);
        end
    end
end

