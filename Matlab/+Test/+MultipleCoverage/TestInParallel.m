classdef TestInParallel < handle
    %TEST run tests for both +Cylinder version v_left and v_right in parallel
    
    properties
        n;
        m;
        
        params;
        
        debug_memory_on;
        debug_frequency;
        update_ui_frequency;
        
        table_left;
        table_right;
        
        ver_leftAxes;
        ver_rightAxes;
        
        iteration;
    end
    
    methods(Access = private)
        function goForIt = ShouldExecuteNow(this)
            goForIt = (mod(this.iteration, this.update_ui_frequency) == 0);
        end
        
        function [] = DebugMemory(this)
            if(this.debug_memory_on)
                if(this.ShouldExecuteNow())
                    this.table_right.DebugMemory();
                end
            end
        end
        
        function [] = ShowRoad(this)
            if(this.ShouldExecuteNow())
                Show.ShowRoad(this.ver_leftAxes, this.table_left.GetGrid(), this.params);
                Show.ShowRoad(this.ver_rightAxes, this.table_right.GetGrid(), this.params);
            end
        end
        
        function [] = PrintIteration(this)
            if(this.debug_memory_on)
                if(this.ShouldExecuteNow())
                    fprintf ('\n\nIteration %d\n', this.iteration);
                end
            end
        end
        
        function [] = Pause(this, ignorePause)
            if(~ignorePause || this.ShouldExecuteNow())
            	pause(this.params.pause_for);
            end
        end
        
        function [] = TestRunInParallel(this)
            grid_left = this.table_left.GetGrid();
            grid_right = this.table_right.GetGrid();
            
            if(any(grid_left + grid_right ~= 1, 'all'))
                fprintf('Algorithms are not synched\n');
            end
        end
    end
    
    methods(Access = protected)
        function agent = CreateAgentOnTheLeft(~, state_machine)
            agent = Cylinders.Agent.Agent(state_machine);
        end
        
        function agent = CreateAgentOnTheRight(~, state_machine)
            agent = Cylinders.Agent.Agent(state_machine);
        end
        
        function visibility = GetVisibilityForLeft(~, state_machine)
            visibility = state_machine.RequiredVisibility();
        end
        
        function visibility = GetVisibilityForRight(~, state_machine)
            visibility = state_machine.RequiredVisibility();
        end
        
        function [grid_left, grid_right] = CreateGrids(this, n, m, k, test_name)
            TestCase = Cylinders.Tests.(sprintf('%sTestCase', test_name))(n, m, k, this.params);
            grid_right = TestCase.CreateGrid();
            grid_left = grid_right;
        end
        
        function [ignorePause] = ProcessTimeStep(this)
            this.table_right.ProcessTimeStep();
            this.table_left.ProcessTimeStep();
            
            ignorePause = true;
        end        
    end
    
    methods
        function obj = TestInParallel(n, m, test_name, debug_memory_on, debug_frequency, update_ui_frequency, pause_between_frames, ...
                algorithm_version_left, algorithm_version_right, k)
            
            test_version_right = algorithm_version_right;
            test_version_left = algorithm_version_left;
            
            obj.n = n;
            obj.m = m;
            obj.debug_memory_on = debug_memory_on;
            obj.debug_frequency = debug_frequency;
            obj.update_ui_frequency = update_ui_frequency;
            
            if(strcmp(test_name, 'SpecificOmmisions'))
                kSpecificOmmisions_right = [n, m-1];
                grid_left = ones(n, m);
                grid_left(sub2ind([n, m], kSpecificOmmisions_right(:, 1), kSpecificOmmisions_right(:, 2))) = 0;
                [I, J] = ind2sub([n, m], find(grid_left));
                kSpecificOmmisions_left = [I, J];
                k = kSpecificOmmisions_left;
            end

            obj.params = Parameters.SimulationParameters(n, m, true);
            obj.params.pause_for = pause_between_frames;

            [grid_left, grid_right] = obj.CreateGrids(n, m, k, test_name);

            obj.table_right = Cylinders.Table.Table(grid_right, test_version_right, @(x) obj.CreateAgentOnTheRight(x), @(x) obj.GetVisibilityForRight(x));
            obj.table_left = Cylinders.Table.Table(grid_left, test_version_left, @(x) obj.CreateAgentOnTheLeft(x), @(x) obj.GetVisibilityForLeft(x));
            
            clc;
            close all;
            figure('Position', [720 60 1080 900]);
            obj.ver_leftAxes = subplot(1, 2, 1);
            obj.ver_rightAxes = subplot(1, 2, 2);    
            
            obj.iteration = 0;
        end
        
        function [] = RunTest(this)
            while(true)
                this.DebugMemory();

                this.ShowRoad();

                this.iteration = this.iteration + 1;
                
                this.PrintIteration();

                ignorePause = this.ProcessTimeStep();
                this.TestRunInParallel();
                
                this.Pause(ignorePause);
            end

        end
    end
end

