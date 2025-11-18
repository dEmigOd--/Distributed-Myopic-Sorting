classdef MaskedRanger < Cylinders.Visibility.Ranger
    %MASKEDRANGER visibility range is masked to have only partial view
    
    properties (Access = private)
        underlyingRanger;
        mask;
    end
    
    methods
        function obj = MaskedRanger(underlyingRanger, mask)
            obj = obj@Cylinders.Visibility.Ranger(underlyingRanger.visibility);
            obj.underlyingRanger = underlyingRanger;
            obj.mask = mask;
            
            expectedSize = 2 * obj.visibility + 1;
            if((size(mask, 1) ~= expectedSize) || (size(mask, 2) ~= expectedSize))
                fprintf('ERROR: wrong-sized mask supplied. Expected a %dx%d matrix, but got %dx%d matrix\n', ...
                    expectedSize, expectedSize, size(mask, 1), size(mask, 2));
            end
        end
        
        function neighborhood = ReadNeighborhood(this, table, row, column)
            neighborhood = this.underlyingRanger.ReadNeighborhood(table, row, column);
            neighborhood(this.mask) = Cylinders.Visibility.Constants.Unspecified;
        end
    end
end

