classdef Road < Cylinders.Road.FramedRoad
    %ROAD will present a multi-frame road created in class
    
    methods
        function obj = Road(n, m, num_frames, ks, num_exiting, test_version, ...
            test_name, visual_on, draw_frame, update_ui_frequency, pause_between_frames, varargin)
            
            [grid, initial_memory] = Cylinders.Road.FramedRoad.CreateGrid(n, m, num_frames, ks, num_exiting, test_name);
            obj = obj@Cylinders.Road.FramedRoad(...
                n, m, num_frames, grid, initial_memory, test_version, ...                
                    visual_on, draw_frame, update_ui_frequency, pause_between_frames, varargin{:});
        end
    end
end

