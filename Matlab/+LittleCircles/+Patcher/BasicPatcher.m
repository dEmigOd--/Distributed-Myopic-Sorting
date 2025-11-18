classdef (Abstract) BasicPatcher
    %BASICPATCHER the class would provide a framework to patch internal states of the agents
    %to enable coverage algorithm usages, that do not stuck in the wrong states, due to second and further
    %visits
    
	properties (Access = protected)
		VCONTINUE;
		VEXIT;
		EMPTY;
    end
    
    methods
		function [obj] = BasicPatcher(params)
			obj.VCONTINUE = params.vehicle_continue;
			obj.VEXIT = params.vehicle_exit;
			obj.EMPTY = params.no_vehicle;
        end
        
        [visibility_range] = GetNeededVisibilityRange(this);
 		[updated_memory] = UpdateMemoryBeforeApplyingCoverageAlgorithm(this, state, memory, neighborhood);		
 		[updated_memory] = UpdateMemoryAfterApplyingSortingAlgorithm(this, state, memory, neighborhood);		
 		[updated_memory] = UpdateMemoryUnconditionally(this, state, memory, neighborhood);		
    end
end

