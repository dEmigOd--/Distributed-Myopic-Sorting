classdef MasksSensed_1 < Cylinders.Masks.MasksSensed_Neighbors
    %MASKSSENSED_1 Those are masks with sensing of radius 1 (L1)
    
    methods
        function obj = MasksSensed_1(visibility)
            obj = obj@Cylinders.Masks.MasksSensed_Neighbors(visibility, 0, 0);
        end
    end
end

