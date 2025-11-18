classdef (Abstract) Ranger < handle
    %RANGER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        visibility;
    end
    
    properties (Access = protected)
        VisibilityMap;
        remapIndexes;
    end
    
    methods (Access = protected)
        function obj = Ranger(visibility)
            obj.visibility = visibility;
        end
        
        function [] = UpdateIndexes(obj)
            length = 2 * obj.visibility + 1;
            remapMap = reshape(1:numel(obj.VisibilityMap), length, length);
            obj.remapIndexes = remapMap(obj.VisibilityMap);
        end
    end
    
    methods
        neighborhood = ReadNeighborhood(this, table, row, column);
	end
end

