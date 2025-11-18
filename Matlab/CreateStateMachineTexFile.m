function [] = CreateStateMachineTexFile(version)
    % create state machine
    state_machine = Cylinders.(sprintf('Ver%d', version)).StateMachine();
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

    state_machine.Print(directory, filename);

    %% TEX content                
    % print one file with all the figures
    filename_all = sprintf('Table.Ver_%d.All', version);
    file = fopen(sprintf('%s/%s.tex', directory, filename_all), 'w+'); 

    TABS = 0;
    PrintTofile('\\documentclass{article}');

    fprintf(file, '\n');

    fprintf(file, '\\usepackage{standalone}\n');
    fprintf(file, '\\usepackage{tikz}\n');
    fprintf(file, '\\usepackage{amsmath}\n');
    fprintf(file, '\\usepackage{amssymb}\n');
    fprintf(file, '\\usepackage{fmtcount}%% http://ctan.org/pkg/fmtcount\n');
    fprintf(file, '\\usetikzlibrary{calc, patterns, intersections}\n');

    fprintf(file, '\n');

    fprintf(file, '\\begin{document}\n');
    fprintf(file, '\t\\begin{figure}\n');
        fprintf(file, '\t\t\\input{%s%d}\n', filename, 1);
    fprintf(file, '\t\\end{figure}\n');
    fprintf(file, '\t\\begin{figure}\n');
    for position = 2:4
        fprintf(file, '\t\\begin{subfigure}[b]{0.33\\textwidth}\n');
            fprintf(file, '\t\t\\centering\n');
            fprintf(file, '\t\t\\input{%s%d}\n', filename, position);
            fprintf(file, '\t\t\\label{fg%d_%d}\n', version, position);
            fprintf(file, '\t\t\\caption{Position %d}\n', position);
        fprintf(file, '\t\\end{subfigure}\n');
    end
    fprintf(file, '\t\\caption{State machines (\\subref{fg%d_%d}) at position %d, (\\subref{fg%d_%d}) at position %d, (\\subref{fg%d_%d}) at position %d}\n', ...
        version, 2, version, 3, version, 4);
    fprintf(file, '\t\\end{figure}\n');

    fprintf(file, '\n');

    fprintf(file, '\\end{document}\n');

    function [] = PrintTofile(msg)
        for tabs=1:TABS
            fprintf(file, '\\t');
        end
        fprintf(file, msg);
        fprintf(file, '\n');
    end
end
