classdef CollapsableFrameRoad < Cylinders.Road.CollapsableBasicFrameRoad
    %COLLAPSABLEFRAMEROAD Frames will collapse with time
    
    methods
        function obj = CollapsableFrameRoad(n, m, num_frames, ks, num_exiting, test_version, ...
            test_name, visual_on, draw_frame, update_ui_frequency, pause_between_frames, collapse_once_in_a_while, ...
            varargin)
        
            [grid, initial_memory] = Cylinders.Road.FramedRoad.CreateGrid(n, m, num_frames, ks, num_exiting, test_name);
        
            obj = obj@Cylinders.Road.CollapsableBasicFrameRoad(n, m, num_frames, grid, initial_memory, test_version, ...
                visual_on, draw_frame, update_ui_frequency, pause_between_frames, collapse_once_in_a_while, ...
                varargin{:});
        
            obj.collapse_once_in_a_while = collapse_once_in_a_while;
        end
    end
end

