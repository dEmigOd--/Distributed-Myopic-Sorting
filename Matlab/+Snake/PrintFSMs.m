function [ ] = PrintFSMs()
    [filepath, ~, ~] = fileparts(mfilename('fullpath'));
    availableFSMs = dir(fullfile(filepath, 'FSMv*.m'));
    
    for i = 1:size(availableFSMs, 1)
        filename_pe = availableFSMs(i).name;
        filename = filename_pe(1:length(filename_pe) - 2);
        if(Snake.(filename).IsPrintable())
            params = Parameters.SimulationParameters(1, 1, true, 0.1, str2num(filename(5:end)));
            fsm = Snake.(filename)(params);
            Snake.PrintFsm(fsm);
            [status, message] = copyfile(fullfile(filepath, 'C++ Files', strcat(filename, '.h')), '../Latex/Coverage Algorithm/C++/CreateFSMTable/CreateFSMTable');
            if ~status
                fprintf('Failed to copy %s: msg = %s\n', filename, message);
            end
        end
    end
end
