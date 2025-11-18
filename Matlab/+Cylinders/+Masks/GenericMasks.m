classdef (Abstract) GenericMasks < handle
    %MASKS those are base class for masks for agents at different states
    
    properties
        visibility;
    end
    
    methods (Static)
        function mask = EmptyMask(visibility)
            mask = false(2 * visibility + 1);
        end        
    end
    
    methods
        mask = SensePosition(this);
        
        sensedPositionCount = PossiblePositions(this);
        
        function mask = MaskPosition(this, position)
            mask = this.(sprintf('MaskPosition%d', position))();
        end
    end
end
