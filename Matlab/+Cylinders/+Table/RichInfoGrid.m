classdef RichInfoGrid < Cylinders.Table.RichAsyncInfoGrid
    %RICHINFOGRID hold more direct info about agents on the grid
    
    methods
        function obj = RichInfoGrid(grid, no_vehicle)
            occupied = grid ~= no_vehicle;
            types = grid(occupied);
            [locations_row, locations_col] = find(occupied);
            
            obj = obj@Cylinders.Table.RichAsyncInfoGrid(size(grid), types, [locations_row, locations_col]);
        end
        
    end
end

