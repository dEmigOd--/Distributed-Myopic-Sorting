classdef CollapsableBasicFrameRoad < Cylinders.Road.FramedRoad
    %CollapsableBasicFrameRoad Frames will collapse with time
    % could be initialized by road and memory
    
    properties
        collapse_once_in_a_while;
    end
    
    methods(Access = private)
        function [grid, memory] = GetFrame(obj, i)
            grid = obj.frames{i}.GetGrid();
            memory = obj.frames{i}.GetMemory();
        end
        
        function [c_matrix] = Concat(~, mat1, mat2)
            if(size(mat1, 2) ~= size(mat2, 2))
                error('Num of lanes should be the same');
            end
            c_matrix = zeros(size(mat1, 1) + size(mat2, 1), size(mat1, 2));
            c_matrix(1:size(mat1, 1), :) = mat1;
            c_matrix(1+size(mat1, 1):end, :) = mat2;
        end
    end
    
    methods
        function obj = CollapsableBasicFrameRoad(n, m, num_frames, grid, initial_memory, test_version, ...
            visual_on, draw_frame, update_ui_frequency, pause_between_frames, collapse_once_in_a_while, ...
            varargin)
        
            obj = obj@Cylinders.Road.FramedRoad(...
                n, m, num_frames, grid, initial_memory, test_version, ...                
                    visual_on, draw_frame, update_ui_frequency, pause_between_frames, varargin{:});
        
            obj.collapse_once_in_a_while = collapse_once_in_a_while;
        end
        
        function [] = Tick(obj)
            createAgentFunc_withMemory = @(sm, memory) Cylinders.Agent.Agent(sm, memory);
            
            % re-define frames
            if((obj.iteration > 0) && (mod(obj.iteration, obj.collapse_once_in_a_while) == 0))
                test_versions = 10 * obj.test_version + [1;2];

                num_of_new_frames = floor(size(obj.frames, 1) / 2);
                if(num_of_new_frames > 0)
                    fprintf('\nRabalancing frames: iteration %d\n', obj.iteration);
                    
                    new_frames = cell(num_of_new_frames, 1);

                    for i = 1:num_of_new_frames
                        [grid1, memory1] = obj.GetFrame(2 * i - 1);
                        [grid2, memory2] = obj.GetFrame(2 * i);

                        grid = obj.Concat(grid1, grid2);
                        memory = obj.Concat(memory1, memory2);

                        % handle last pair-less single frame
                        if((mod(size(obj.frames, 1), 2) == 1) && (2 * (i + 1) > size(obj.frames, 1)))
                            [grid3, memory3] = obj.GetFrame(2 * i + 1);
                            grid = obj.Concat(grid, grid3);
                            memory = obj.Concat(memory, memory3);
                        end
                        params_frame = Parameters.SimulationParameters(size(grid, 1), obj.params.m, obj.params.visual_on);
                        new_frames{i} = Cylinders.Table.Table(grid, params_frame, test_versions, createAgentFunc_withMemory, ...
                        	@(sm) sm.RequiredVisibility(), memory);
                    end
                    
                    obj.frames = new_frames;
                    obj.problem_solved = false(num_of_new_frames, 1);
                    %obj.collapse_once_in_a_while = 2 * obj.collapse_once_in_a_while;
                end
            end
        
            Tick@Cylinders.Road.FramedRoad(obj);
        end
    end
end

