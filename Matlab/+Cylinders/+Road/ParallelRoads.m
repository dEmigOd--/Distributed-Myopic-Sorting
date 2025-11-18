classdef ParallelRoads < Cylinders.Road.Road
    %PARALLELROADS few roads in parallel
    
    properties
        roads;
    end
    
    methods
        function obj = ParallelRoads(ns, ms, num_frames, ks, num_exiting, test_versions, ...
                test_name, visual_on, draw_frame, update_ui_frequency, pause_between_frames, collapse_once_in_a_while ...
            )
            obj = obj@Cylinders.Road.Road(2, 3, 1, 1, 0, test_versions(1), ...
                test_name, false, false, update_ui_frequency, pause_between_frames);
            
            num_parallel_roads = size(num_frames, 1);
            obj.roads = cell(num_parallel_roads, 1);
            
            same_road = false;
            if(size(ns, 1) == 1)
                same_road = true;
                max_frames = max(num_frames);
                if(any((max_frames ./ num_frames(:, 1)) ~= floor(max_frames ./ num_frames(:, 1))))
                    error('Unable to depict uneven roads or not enough data provided');
                end
                
                ns = ns .* floor(max_frames ./ num_frames(:, 1));
            end
            
            if(size(ms, 1) ~= size(ns, 1))
                ms = ms(1) * ones(size(ns));
            end
            if(size(test_versions, 1) ~= size(ns, 1))
                test_versions = test_versions(1) * ones(size(ns));
            end
            
            DO_NOT_PAUSE = 0;
            if(same_road)
                [grid, initial_memory] = Cylinders.Road.FramedRoad.CreateGrid(ns(1), ms(1), num_frames(1), ks(1, :)', num_exiting(1, :)', test_name);
                for i=1:num_parallel_roads
                    obj.roads{i} = Cylinders.Road.CollapsableBasicFrameRoad(ns(i), ms(i), num_frames(i), grid, initial_memory, test_versions(i), ...
                        visual_on, draw_frame, update_ui_frequency, DO_NOT_PAUSE, collapse_once_in_a_while(i), ...
                        i, num_parallel_roads);
                end
            else
                for i=1:num_parallel_roads
                    obj.roads{i} = Cylinders.Road.CollapsableFrameRoad(ns(i), ms(i), num_frames(i), ks(i, :)', num_exiting(i, :)', test_versions(i), ...
                        test_name, visual_on, draw_frame, update_ui_frequency, DO_NOT_PAUSE, collapse_once_in_a_while(i), ...
                        i, num_parallel_roads);
                end
            end
        end
        
        function [] = Tick(obj)
            hold on;
            cellfun(@(road) road.Tick(), obj.roads);
            hold off;
            
            obj.iteration = obj.iteration + 1;

            if(mod(obj.iteration, obj.update_ui_frequency) == 0)
                pause(obj.params.pause_for);
            end
        end
    end
end

