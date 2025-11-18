classdef SpecificOmmisionsTestCase < Cylinders.Tests.BasicTestCase
    %SPECIFICOMMISIONSTESTCASE sets desired empty spaces
    
    properties
        presetEmptySpaces;
    end
    
    methods
        function obj = SpecificOmmisionsTestCase(n, m, emptySpaces, params)
            obj = obj@Cylinders.Tests.BasicTestCase(n, m, size(emptySpaces, 1), params);
            obj.presetEmptySpaces = emptySpaces;
        end        
    end
    
    methods (Access = protected)
        function emptySpaces = SetEmptySpaces(this)
            emptySpaces = this.presetEmptySpaces;
        end
    end
end

