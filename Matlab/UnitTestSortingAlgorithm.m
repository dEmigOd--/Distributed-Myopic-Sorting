% parameters
max_n = 6;
max_m = 2;
% those are useless
k = 1; % number of empty spaces
num_exiting = 47;%n - 1;

test_version = 308;
% supported cases
% Random; Frame; Comb3; TotallyRandom;
% , though come with k
test_name = 'Random';
        
update_progress_frequency = 1000;

visual_on = false;

capture_video = false;
frames_per_second = 24;
continue_to_capture = true;
for_at_least_that_much = 5; % seconds

debug_memory_on = false;
debug_tempo_spatiality = false;
debug_tempo_spatiality_scale = 0.1;
debug_tempo_spatiality_iterations = 2000;
debug_tempo_spatiality_skip_iterations = 2000;
keep_track_of_last_visits = false;
update_ui_frequency = 1;
pause_between_frames = 0.01;

read_from_file = true;
filename_agents = 'Data/unittestgrid.txt';
filename_memory = 'Data/unittestmemory.txt'; % we will write zeroes

max_iterations = 1000; % we will call it failed, if not completed until this
stop_on_completion = true; % stop ASAP if completed

counter = 0;
failed = false;

for n = 2:max_n
    for m = 2:max_m
        
        if(failed)
            break;
        end
        
        memory = zeros(n, m);
        csvwrite(filename_memory, memory);
        
        for cfg = 1:(3^(n * m) - 1)
            
            config = CreateTrinaryConfig(n, m, cfg);
            csvwrite(filename_agents, config);
            
            if(any(config == 0, 'all'))
                % check if solved
                [problem_solved] = TestMultipleSortingAlgorithm_Runner(n, m, k, num_exiting, test_version, test_name, ...
                    visual_on, capture_video, frames_per_second, continue_to_capture, for_at_least_that_much, ...
                    debug_memory_on, debug_tempo_spatiality, debug_tempo_spatiality_scale, ...
                    debug_tempo_spatiality_iterations, debug_tempo_spatiality_skip_iterations, ...
                    keep_track_of_last_visits, update_ui_frequency, pause_between_frames, ...
                    read_from_file, filename_agents, filename_memory, ...
                    max_iterations, stop_on_completion, ...
                    []);

                if(~problem_solved)
                    PrintConfig(config);
                    failed = true;
                    break;
                end
            end
            counter = counter + 1;
            if(mod(counter, update_progress_frequency) == 0)
                fprintf('Progress: %d configs checked\n', counter);
            end
        end
    end
end

if(failed)
    fprintf('At least one config failed to become sorted\n');
else
    fprintf('The version %d succeeded in every tried config\n', test_version);
end

function [config] = CreateTrinaryConfig(n, m, ordinal)
    config = zeros(n, m);
    ordinal = int32(ordinal);
    for i = 1: n*m
        next_ordinal = idivide(ordinal, int32(3));
        config(i) = ordinal - int32(3) * next_ordinal;
        ordinal = next_ordinal;
    end
    config(config == 2) = -1;
end

function [] = PrintConfig(config)
    for row = 1:size(config, 1)
        for column = 1:size(config, 2)
            fprintf('%3d ', config(row, column));
        end
        fprintf('\n');
    end
end
