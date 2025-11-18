classdef FramedRoad < handle
    %FramedRoad will present a multi-frame road
    
    properties(Access = protected)
        params;
        update_ui_frequency;
        test_version;
        frames;
        road_axes;
        iteration;
        problem_solved;
    end
    
     methods(Static, Access = protected)
        function [huge_grid, initial_memory] = CreateGrid(n, m, num_frames, ks, num_exiting, test_name)
            params_frame = Parameters.SimulationParameters(n, m, false);
            
            if(size(ks, 1) == 1)
                ks = ks * ones(num_frames, 1);
            end
            if(size(ks, 1) < num_frames)
                fprintf('Not all k''s were supplied. Filling with 1s\n');
                temp = ks;
                ks = ones(num_frames, 1);
                ks(1:size(temp, 1), :) = temp;
            end
            if(size(num_exiting, 1) == 1)
                num_exiting = num_exiting * ones(num_frames, 1);
            end
            if(size(num_exiting, 1) < num_frames)
                fprintf('Not all exiting vehicles were set. Missing frames will be assigned n-1 exiting vehicles\n');
                temp = num_exiting;
                num_exiting = ones(num_frames, 1);
                num_exiting(1:size(temp, 1), :) = temp;
            end
            
            huge_grid = zeros(n * num_frames, m);
            for i=1:num_frames
                TestCase = Cylinders.Tests.(sprintf('%sTestCase', test_name))(n, m, ks(i), params_frame);
                grid = params_frame.vehicle_continue * TestCase.CreateGrid(); 

                num_agents = sum(grid ~= params_frame.no_vehicle, 'all');
                where_agents = find(grid);
                grid(where_agents(randsample(num_agents, num_exiting(i)))) = params_frame.vehicle_exit;

                huge_grid((i - 1) * n + (1:n), :) = grid;
            end
            
            initial_memory = zeros(size(huge_grid));
        end
    end
    
   methods(Access = private)
        function [subgrid] = GetSubgrid(~, grid, frame_size, frame_num)
            subgrid = grid((frame_num - 1) * frame_size + (1:frame_size), :);
        end
    end
    
    methods
        %% varargin 1: subplot_num, 2: subplot_count
        function obj = FramedRoad(n, m, num_frames, grid, initial_memory, test_version, ...
            visual_on, draw_frame, update_ui_frequency, pause_between_frames, varargin)
            test_versions = 10 * test_version + [1;2];

            params_frame = Parameters.SimulationParameters(n, m, visual_on);
            obj.params = Parameters.SimulationParameters(n * num_frames, m, visual_on);
            obj.params.draw_frame = draw_frame;
            obj.update_ui_frequency = update_ui_frequency;
            obj.params.pause_for = pause_between_frames;
            obj.test_version = test_version;
            
            obj.frames = cell(num_frames, 1);
            
            %createAgentFunc_withoutMemory = @(sm) Cylinders.Agent.Agent(sm);
            createAgentFunc_withMemory = @(sm, memory) Cylinders.Agent.Agent(sm, memory);

            if(params_frame.visual_on)
                if(nargin == 10 || varargin{1} == 1)
                    clc;
                    close all;
                    handl_table = figure('Position', [1260 60 540 900]);
                end
                if(nargin == 10)
                    obj.road_axes = axes(handl_table, ...        
                        'Units', 'normalized', ...
                        'Position', [0 0 1 1] ...
                    );
                else
                    obj.road_axes = subplot(1, varargin{2}, varargin{1});
                end
            end
            
            for i=1:num_frames
                obj.frames{i} = Cylinders.Table.Table(obj.GetSubgrid(grid, n, i), params_frame, test_versions, createAgentFunc_withMemory, ...
                       @(sm) sm.RequiredVisibility(), obj.GetSubgrid(initial_memory, n, i));
            end
            
            obj.iteration = 0;
            % keep track of solved frames
            obj.problem_solved = false(num_frames, 1);
        end
        
        function [] = Tick(obj)
            if(mod(obj.iteration, obj.update_ui_frequency) == 0)
                frame_sizes = cellfun(@(frame) size(frame.GetGrid(), 1), obj.frames);
                Show.ShowFramedRoad(obj.road_axes, obj.GetRoad(), frame_sizes, obj.params);
            end

            obj.iteration = obj.iteration + 1;

            for i = 1:size(obj.frames, 1)
                obj.frames{i}.ProcessTimeStep();

                vehicles = obj.frames{i}.GetGrid() == obj.params.vehicle_exit;
                if (~any(vehicles(:, 1:end-1), 'all') && ~obj.problem_solved(i))
                    fprintf ('\n\nFinished Frame %d at %d (th) iteration\n', i, obj.iteration);
                    obj.problem_solved(i) = true;
                end 
            end
            
            if(mod(obj.iteration, obj.update_ui_frequency) == 0)
                pause(obj.params.pause_for);
            end
        end
        
        function [road] = GetRoad(obj)
            road = zeros(obj.params.n, obj.params.m);
            last_written = 0;
            for i = 1:size(obj.frames, 1)
                table = obj.frames{i}.GetGrid();
                road(last_written + (1:size(table, 1)), :) = table;
                last_written = last_written + size(table, 1);
            end
        end
        
    end
end

