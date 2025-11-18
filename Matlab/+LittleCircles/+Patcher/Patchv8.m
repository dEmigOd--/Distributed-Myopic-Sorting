classdef Patchv8 < LittleCircles.Patcher.BasicPatcher
    %PATCHV8 patching v8 coverage algorithm : unsupported
	
    methods
		function [obj] = Patchv8(params)
			obj = obj@LittleCircles.Patcher.BasicPatcher(params);
            error('Unsupported. Do not use v8 for sorting, use v81 instead');
        end
        
        function [visibility_range] = GetNeededVisibilityRange(~)
            visibility_range = 2;
        end
        
        function [updated_memory] = UpdateMemoryBeforeApplyingCoverageAlgorithm(this, state, memory, neighborhood)
        end
        
        function [updated_memory] = UpdateMemoryAfterApplyingSortingAlgorithm(this, state, memory, neighborhood, move_intentions)
        end
        
        function [updated_memory] = UpdateMemoryUnconditionally(this, state, memory, neighborhood)
        end            
    end    
end

