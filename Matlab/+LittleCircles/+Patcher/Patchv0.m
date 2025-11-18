classdef Patchv0 < LittleCircles.Patcher.BasicPatcher
    %PATCHV0 no patching needed
    
    methods
		function [obj] = Patchv0(params)
			obj = obj@LittleCircles.Patcher.BasicPatcher(params);
        end
        
        function [visibility_range] = GetNeededVisibilityRange(~)
            visibility_range = 0;
        end
        
        function [updated_memory] = UpdateMemoryBeforeApplyingCoverageAlgorithm(~, ~, memory, ~)
            updated_memory = memory;
        end
        
        function [updated_memory] = UpdateMemoryAfterApplyingSortingAlgorithm(~, ~, memory, ~, ~)
            updated_memory = memory;
        end
        
        function [updated_memory] = UpdateMemoryUnconditionally(~, ~, memory, ~)
            updated_memory = memory;
        end            
    end    
end

