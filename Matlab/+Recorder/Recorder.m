classdef Recorder < Recorder.BaseRecorder
    %RECORDER incorporate all the recording made on the poor simulations
    
    properties
        params;
        max_iterations;
        iteration;
        
        keep_track_of_last_visits;
        debug_tempo_spatiality;
        capture_video;
        frames_per_second;
        debug_memory_on;
        update_ui_frequency;
        continue_to_capture;
        for_at_least_that_much;
        debug_tempo_spatiality_iterations;
        debug_tempo_spatiality_skip_iterations;
        debug_tempo_spatiality_scale;
        stop_on_completion;
        
        roadAxes;
        visitsAxes;
        
        ts_grid;
        capturedVideo;
        
        last_visited;
        count_visited;
        problem_solved;
        
        subrecorders;
    end
    
    methods
        function obj = Recorder(params, keep_track_of_last_visits, debug_tempo_spatiality, capture_video, ...
                frames_per_second, debug_memory_on, update_ui_frequency, continue_to_capture, ...
                for_at_least_that_much, debug_tempo_spatiality_iterations, debug_tempo_spatiality_skip_iterations, ...
                debug_tempo_spatiality_scale, max_iterations, stop_on_completion, ...
                otherrecorders, exisitingRoadAxes)
            obj.params = params;
            
            obj.max_iterations = max_iterations;
            
            obj.keep_track_of_last_visits = keep_track_of_last_visits;
            obj.debug_tempo_spatiality = debug_tempo_spatiality;
            obj.capture_video = capture_video;
            obj.frames_per_second = frames_per_second;
            obj.debug_memory_on = debug_memory_on;
            obj.update_ui_frequency = update_ui_frequency;
            obj.continue_to_capture = continue_to_capture;
            obj.for_at_least_that_much = for_at_least_that_much;
            obj.debug_tempo_spatiality_iterations = debug_tempo_spatiality_iterations;
            obj.debug_tempo_spatiality_skip_iterations = debug_tempo_spatiality_skip_iterations;
            obj.debug_tempo_spatiality_scale = debug_tempo_spatiality_scale;
            obj.stop_on_completion = stop_on_completion;
            
            obj.subrecorders = otherrecorders;
            
            if(nargin > 15)
                obj.roadAxes = exisitingRoadAxes;
            end
        end
        
        function [continueToRun] = ShouldContinue(obj)
            continueToRun = obj.iteration < obj.max_iterations;
        end
        
        function [problem_solved] = ProblemSolved(obj)
            problem_solved = obj.problem_solved;
        end
        
        function [] = PreRun(obj, table)
            % Create and tune objects BEFORE the simulation starts
            if(obj.params.visual_on)
                if(obj.keep_track_of_last_visits)
                    handl_table = figure('Position', [720 60 1080 900]);  %#ok<NASGU>
                    obj.roadAxes = subplot(1, 2, 1);
                    obj.visitsAxes = subplot(1, 2, 2);    
                else
                    if(isempty(obj.roadAxes))
                        parent_handle = figure('Position', [1260 60 540 900]);
                        obj.roadAxes = axes(parent_handle, ...        
                            'Units', 'normalized', ...
                            'Position', [0 0 1 1] ...
                    );
                    end
                end
            end

            if(obj.debug_tempo_spatiality)
                obj.ts_grid = zeros(size(table.GetGrid(), 1), size(table.GetGrid(), 2), obj.debug_tempo_spatiality_iterations);
            end

            obj.iteration = 0;
            % keep track of empty cell last visits
            obj.last_visited = zeros(size(table.GetGrid()));
            obj.count_visited = zeros(size(table.GetGrid()));
            obj.problem_solved = false;

            if (obj.capture_video)
                obj.capturedVideo = VideoWriter(fullfile('.', 'Video', ...
                    strcat('Capture.', strrep(sprintf('%s', datetime(now,'ConvertFrom','datenum')), ':', '-'), '.avi')));
                obj.capturedVideo.FrameRate = obj.frames_per_second;
                open(obj.capturedVideo);
            end 

            for i = 1:size(obj.subrecorders, 1)
                obj.subrecorders(i).PreRun(table);
            end
        end
        
        function [] = PostRun(obj, table)
            % Create and tune objects AFTER the simulation ends
            for i = 1:size(obj.subrecorders, 1)
                obj.subrecorders(i).PostRun(table);
            end
        end
        
        function [] = PreStep(obj, table)
            % Process data BEFORE Algorithm step is executed
            %% old part without simple recorders
            if(obj.debug_memory_on)
                if(mod(obj.iteration, obj.update_ui_frequency) == 0)
                    table.DebugMemory();
                end
            end

            if(obj.params.visual_on && mod(obj.iteration, obj.update_ui_frequency) == 0)
                Show.ShowRoad(obj.roadAxes, table.GetAsyncGrid(), obj.params);
                if(obj.capture_video)
                    writeVideo(obj.capturedVideo, getframe(obj.roadAxes));
                    if(obj.problem_solved)
                        if (obj.continue_to_capture && obj.for_at_least_that_much > 0)
                            obj.for_at_least_that_much = obj.for_at_least_that_much - 1;
                            if(obj.for_at_least_that_much == 0)
                                obj.continue_to_capture = 0;
                            end
                        else
                            close(obj.capturedVideo);
                            obj.capture_video = false;
                        end
                    end
                end
            end

            if(obj.keep_track_of_last_visits)
                obj.last_visited(table.GetGrid() == obj.params.no_vehicle) = obj.iteration;
                obj.count_visited(table.GetGrid() == obj.params.no_vehicle) = obj.count_visited(table.GetGrid() == obj.params.no_vehicle) + 1;
                if(obj.params.visual_on && mod(obj.iteration, obj.update_ui_frequency) == 0)
                    Show.ShowMultiColoredRoad(obj.visitsAxes, obj.iteration - obj.last_visited, obj.params);
                    if(debug_frequency)
                        disp(obj.count_visited / obj.iteration);
                    end
                end
            end

            %% can't say why iteration is increased here
            if(obj.debug_memory_on)
                if(mod(obj.iteration + 1, obj.update_ui_frequency) == 0)
                    fprintf ('\n\nIteration %d\n', obj.iteration + 1);
                end
            end

            if(obj.debug_tempo_spatiality)
                if(obj.iteration + 1 > obj.debug_tempo_spatiality_skip_iterations)
                    obj.ts_grid(:, :, obj.iteration + 1 - obj.debug_tempo_spatiality_skip_iterations) = table.GetGrid();

                    if(obj.debug_tempo_spatiality_iterations == obj.iteration + 1 - obj.debug_tempo_spatiality_skip_iterations)
                        obj.debug_tempo_spatiality = false;
                        printer = Cylinders.Debug.TempoSpatialPrinter(obj.debug_tempo_spatiality_scale);
                        printer.Print(obj.ts_grid(2:end, 2:end-1, :), '.\\+Cylinders\\TempoSpatial\Column');
                    end
                end
            end
            
            %% new part with recorders
            
            %%
            for i = 1:size(obj.subrecorders, 1)
                obj.subrecorders(i).PreStep(table);
            end
            obj.iteration = obj.iteration + 1;
        end
        
        function [] = PostStep(obj, table)
            % Process data AFTER Algorithm step is executed
            vehicles = table.GetGrid() == obj.params.vehicle_exit;
            if (((sum(vehicles(:, 1:end-1), 'all') == 0) || ...
                (sum(vehicles(:, end), 'all') == size(table.GetGrid(), 1))) && ~obj.problem_solved)
                if(obj.params.visual_on)
                    fprintf ('\n\nFinished at %d (th) iteration\n', obj.iteration);
                end
                obj.problem_solved = true;
                if(obj.stop_on_completion)
                    obj.max_iterations = obj.iteration + 1;
                end
            end 

            if(obj.params.visual_on && mod(obj.iteration, obj.update_ui_frequency) == 0)
                pause(obj.params.pause_for);
            end
            
            for i = 1:size(obj.subrecorders, 1)
                obj.subrecorders(i).PostStep(table);
            end
        end
    end
end

