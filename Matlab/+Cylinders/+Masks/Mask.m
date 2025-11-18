classdef Mask < handle
    %MASK the object containing what to look for
    
    properties % (Access = private)
        entries;
        mask;
    end
    
    methods (Access = private, Static)
        function mask = EmptyMask(visibility)
            mask = Cylinders.Masks.GenericMasks.EmptyMask(visibility);
        end
    end
    
    methods
        function obj = Mask(visibility, entries)
            obj.entries = entries;
            % probably already obsolete
            obj.mask = Cylinders.Masks.Mask.EmptyMask(visibility);
            obj.mask(entries) = true;
        end
        
        function [mask] = GetMask(this)
            mask = this.mask;
        end
        
        function [readings] = GetReadings(this, neighborhood)
            readings = neighborhood(this.entries);
        end
    end
end

