classdef TestPrimalDualInParallel < Test.MultipleCoverage.TestInParallel
    %TestPrimalDualInParallel run tests for Primal Cylinder version and a simulated Dual
    
    methods(Access = protected)
        function agent = CreateAgentOnTheLeft(~, state_machine)
            agent = Cylinders.Agent.Agent(state_machine);
        end
        
        function agent = CreateAgentOnTheRight(~, state_machine)
            agent = Cylinders.Agent.DualAgent(state_machine);
        end
        
        function visibility = GetVisibilityForRight(~, state_machine)
            visibility = state_machine.RequiredVisibility() + 1;
        end
        
        function [grid_left, grid_right] = CreateGrids(this, n, m, k, test_name)
            TestCase = Cylinders.Tests.(sprintf('%sTestCase', test_name))(n, m, k, this.params);
            grid_right = TestCase.CreateGrid();
            grid_left = 1 - grid_right;
        end
        
        function [ignorePause] = ProcessTimeStep(this)
            prevGrid = this.table_right.GetGrid();
            this.table_right.ProcessTimeStep();
            currGrid = this.table_right.GetGrid();
            
            if(any(prevGrid ~= currGrid, 'all'))
                this.table_left.ProcessTimeStep();
            end
            
            ignorePause = true;
        end        
    end
    
    methods
        function obj = TestPrimalDualInParallel(n, m, test_name, debug_memory_on, debug_frequency, update_ui_frequency, pause_between_frames, ...
                algorithm_version_left, algorithm_version_right, k)
            
            obj=obj@Test.MultipleCoverage.TestInParallel(n, m, test_name, debug_memory_on, debug_frequency, update_ui_frequency, pause_between_frames, ...
                algorithm_version_left, algorithm_version_right, k);
        end
    end
end

