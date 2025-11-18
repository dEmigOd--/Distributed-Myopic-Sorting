function [problem_solved] = TestMultipleSortingAlgorithm_Runner(n, m, k, num_exiting, test_version, test_name, ...
    visual_on, capture_video, frames_per_second, continue_to_capture, for_at_least_that_much, ...
    debug_memory_on, debug_tempo_spatiality, debug_tempo_spatiality_scale, ...
    debug_tempo_spatiality_iterations, debug_tempo_spatiality_skip_iterations, ...
    keep_track_of_last_visits, update_ui_frequency, pause_between_frames, ...
    read_from_file, filename_agents, filename_memory, ...
    max_iterations, stop_on_completion, ...
    progress_recorders, ...
    async_run, async_scheduler)
%TESTMULTIPLESORTINGALGORITHM_RUNNER Execute Sorting Algorithms

%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   algorithm parameters
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% n - number of rows
% m - number of columns
% k - number of empty spaces
% num_exiting - number of exiting vehicles

% test_version - algorithm version to check

% test_name - how to setup an initial configuration
% supported cases
% Random; Frame; Comb3; TotallyRandom;
% , though come with k

%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                matlab simulation parameters
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% visual_on - should draw the simulation; true/false;
% capture_video - should capture video of simulation; true/false;
% frames_per_second - frames per second in captured video; unsigned;
% continue_to_capture - continue to capture after sorted config reached; true/false;
% for_at_least_that_much - amount of seconds to capture after a sorted config reached; unsigned;

% debug_memory_on - print memory values after each iteration; true/false;
% debug_frequency - debug visit frequency [probably from the cover algorithm stage; to capture unvisited cells]; true/false;
% debug_tempo_spatiality - follow the empty slots; true/false;
% debug_tempo_spatiality_scale - prob. scaling factor of the spatio-temporal plane; double;
% debug_tempo_spatiality_iterations - length of spatio-temporal plane track time; unsigned;
% debug_tempo_spatiality_skip_iterations - skip first iteration for tracking; unsigned;
% keep_track_of_last_visits - debug when was last visited[prob. from cover algorithms]; true/false;
% update_ui_frequency - how frequently to update UI; affects speed; unsigned;
% pause_between_frames - wait between consequent UI updates; double in seconds;

% read_from_file -read initial config from file; true/false;
% filename_agents - agents in initial config (0 - empty, 1 - exiting, -1 - continue agents); filename=string ('Data/testgrid.txt');
% filename_memory - D-bit state in initial config (timer comes from the algorithm itself); filename=string ('Data/testmemory.txt');

% max_iterations - stop, if that much iterations executed; unsigned;
% stop_on_completion - stop, if solved; true/false;

% progress_recorders - additional progress recorders

% async_run - let agents execute commands asynchronously
% async_scheduler - an object that allows async execution

    for_at_least_that_much = for_at_least_that_much * frames_per_second;

    use_initial_memory = false;
    if (read_from_file)
        grid = csvread(filename_agents);
        [n, m] = size(grid);
        params = Parameters.SimulationParameters(n, m, visual_on);

        if (isfile(filename_memory))
            initial_memory = 4 * csvread(filename_memory);
            if(isequal(size(grid), size(initial_memory)))
                use_initial_memory = true;
            end
        end
    else
        params = Parameters.SimulationParameters(n, m, visual_on);
        TestCase = Cylinders.Tests.(sprintf('%sTestCase', test_name))(n, m, k, params);
        grid = params.vehicle_continue * TestCase.CreateGrid(); 

        num_agents = sum(grid ~= params.no_vehicle, 'all');
        where_agents = find(grid);
        grid(where_agents(randsample(num_agents, num_exiting))) = params.vehicle_exit;
    end
    params.pause_for = pause_between_frames;

    if(any(ismember(test_version, [307, 309, 310]), 'all') && m == 2)
        test_version = 319;
    end
    if(test_version == 319 && m > 2)
        test_version = 310;
    end

    test_versions = 10 * test_version + [1;2];

    createAgentFunc_withoutMemory = @(sm) Cylinders.Agent.Agent(sm);
    createAgentFunc_withMemory = @(sm, memory) Cylinders.Agent.Agent(sm, memory);

    if(async_run)
        table = Cylinders.Table.AsyncTable(grid, params, test_versions, createAgentFunc_withMemory, ...
            @(sm) sm.RequiredVisibility(), async_scheduler, zeros(size(grid)));
    else
        if(use_initial_memory)
            table = Cylinders.Table.Table(grid, params, test_versions, createAgentFunc_withMemory, @(sm) sm.RequiredVisibility(), initial_memory);
        else
            table = Cylinders.Table.Table(grid, params, test_versions, createAgentFunc_withoutMemory, @(sm) sm.RequiredVisibility());
        end
    end

    clc;
    close all;
    recorder = Recorder.Recorder(params, keep_track_of_last_visits, debug_tempo_spatiality, capture_video, ...
                    frames_per_second, debug_memory_on, update_ui_frequency, continue_to_capture, ...
                    for_at_least_that_much, debug_tempo_spatiality_iterations, debug_tempo_spatiality_skip_iterations, ...
                    debug_tempo_spatiality_scale, max_iterations, stop_on_completion, ...
                    progress_recorders);
                
    recorder.PreRun(table);

    while(recorder.ShouldContinue())
        recorder.PreStep(table);

        table.ProcessTimeStep();
        
        recorder.PostStep(table);
    end  
    
    recorder.PostRun(table);
    
    problem_solved = recorder.ProblemSolved();
end

