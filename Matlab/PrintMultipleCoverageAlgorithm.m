version = 319;

% set one cell entry as figure, all entries in it are subfigures
% config = { % for version 107, 310
%     {{1,5}, {2,3,4}, {6,7,8}, {9}}, ...
%     {{1,5}, {2,3,4}, {6,7}, {8,9}}, ...
%     };
%config = {% for version 308
%    {{1,2,4}, {3, 8}, {6}}, ...
%    {{1,2,3}, {4, 6}, {8}}, ...
%    };
config = { % for version 319
    {{1,2,4}, {3,8}, {6}}, ...
    {{1,2,3}, {4,6}, {8}}, ...
    };

%config = {{1,2,3,4}, {5,6, 7}, {8,9}};
%config = {{1},{2,3,4},{5},{6,7,8},{9}};

drop_do_not_care = false;

if(size(config, 1) > 1)
    fprintf('Wrong config supplied\n');
    return;
end

if (version > 300 && version <= 400)
    multiplier = 10;
    subVersion = 1:2;
else
    multiplier = 1;
    subVersion = 0;
end

for sv = 1:numel(subVersion)
    printer = Print.BaseCylinderPrinter(multiplier * version + subVersion(sv));
    printer.Print(config{sv}, drop_do_not_care);
    %printer.PrintInOneTable(drop_do_not_care);
end

return;

%% OLD STUFF

    subfigure_width = 0.3;

    % create state machine
    state_machine = Cylinders.StateMachine.(sprintf('Ver%d', version)).StateMachine();
    % print all state machines

    [result, ~, ~] = mkdir('.', '+Cylinders');
    if(~result)
        fprintf('Unable to create directory\n');
        return;
    end
    [result, ~, ~] = mkdir('./+Cylinders', 'Tables');
    if(~result)
        fprintf('Unable to create directory\n');
        return;
    end

    directory = './+Cylinders/Tables';
    filename = sprintf('Table.Ver_%d.Position_', version);

    % GenericStateMachine is the one printing things
    state_machine.Print(directory, filename, version);

    % TEX content                
    % print one file with all the figures
    filename_all = sprintf('Table.Ver_%d.All', version);
    file = fopen(sprintf('%s/%s.tex', directory, filename_all), 'w+'); 

    fprintf(file, '\\documentclass{article}\n');

    fprintf(file, '\n');

    fprintf(file, '\\usepackage{standalone}\n');
    fprintf(file, '\\usepackage{tikz}\n');
    fprintf(file, '\\usepackage{amsmath}\n');
    fprintf(file, '\\usepackage{amssymb}\n');
    fprintf(file, '\\usepackage{subcaption}\n');
    fprintf(file, '\\usepackage{fmtcount}%% http://ctan.org/pkg/fmtcount\n');
    fprintf(file, '\\usetikzlibrary{calc, patterns, intersections}\n');

    fprintf(file, '\n');

    fprintf(file, '\\begin{document}\n');

    fprintf(file, '\t\\begin{figure}\n');
        fprintf(file, '\t\t\\centering\n');
        fprintf(file, '\t\t\\input{%s%d}\n', filename, 1);
        fprintf(file, '\t\t\\caption{State machine at position 1}\n');
        fprintf(file, '\t\t\\label{fig:fg_%d_1}\n', version);
    fprintf(file, '\t\\end{figure}\n');
    
    fprintf(file, '\t\\begin{figure}\n');    
    for position = 2:4
        fprintf(file, '\t\t\\begin{subfigure}[b]{%.2f\\textwidth}\n', subfigure_width);
            fprintf(file, '\t\t\t\\centering\n');
            fprintf(file, '\t\t\t\\input{%s%d}\n', filename, position);
            fprintf(file, '\t\t\t\\caption{Position %d}\n', position);
            fprintf(file, '\t\t\t\\label{fig:fg_%d_%d}\n', version, position);
        fprintf(file, '\t\t\\end{subfigure}\n');
    end
        fprintf(file, ...
            '\t\t\\caption{State machines (\\subref{fig:fg_%d_%d}) at position %d, (\\subref{fig:fg_%d_%d}) at position %d, (\\subref{fig:fg_%d_%d}) at position %d}\n', ...
        version, 2, 2, version, 3, 3, version, 4, 4);
    fprintf(file, '\t\\end{figure}\n');

    fprintf(file, '\t\\begin{figure}\n');
        fprintf(file, '\t\t\\centering\n');
        fprintf(file, '\t\t\\input{%s%d}\n', filename, 5);
        fprintf(file, '\t\t\\caption{State machine at position 5}\n');
        fprintf(file, '\t\t\\label{fig:fg_%d_5}\n', version);
    fprintf(file, '\t\\end{figure}\n');
    
    fprintf(file, '\t\\begin{figure}\n');    
    for position = 6:8
        fprintf(file, '\t\t\\begin{subfigure}[b]{%.2f\\textwidth}\n', subfigure_width);
            fprintf(file, '\t\t\t\\centering\n');
            fprintf(file, '\t\t\t\\input{%s%d}\n', filename, position);
            fprintf(file, '\t\t\t\\caption{Position %d}\n', position);
            fprintf(file, '\t\t\t\\label{fig:fg_%d_%d}\n', version, position);
        fprintf(file, '\t\t\\end{subfigure}\n');
    end
        fprintf(file, ...
            '\t\t\\caption{State machines (\\subref{fig:fg_%d_%d}) at position %d, (\\subref{fig:fg_%d_%d}) at position %d, (\\subref{fig:fg_%d_%d}) at position %d}\n', ...
        version, 6, 6, version, 7, 7, version, 8, 8);
    fprintf(file, '\t\\end{figure}\n');
    
    fprintf(file, '\t\\begin{figure}\n');
        fprintf(file, '\t\t\\centering\n');
        fprintf(file, '\t\t\\input{%s%d}\n', filename, 9);
        fprintf(file, '\t\t\\caption{State machine at position 9}\n');
        fprintf(file, '\t\t\\label{fig:fg_%d_9}\n', version);
    fprintf(file, '\t\\end{figure}\n');
    
    fprintf(file, '\n');

    fprintf(file, '\\end{document}\n');
