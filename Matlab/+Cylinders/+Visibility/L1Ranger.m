classdef L1Ranger < Cylinders.Visibility.Ranger
    %L1RANGER The class allows to  get the readings in L1 settings with x cells visibility
    
    methods
        function obj = L1Ranger(visibility)
            obj = obj@Cylinders.Visibility.Ranger(visibility);
            length = 2 * visibility + 1;

            mapIndexes = kron(ones(1, length), (1:length)' - (visibility + 1));
            obj.VisibilityMap = (abs(mapIndexes) + abs(mapIndexes') <= visibility);
            
            obj.UpdateIndexes();
        end
        
        function neighborhood = ReadNeighborhood(this, table, row, column)
            % create appropriate surrounding
            larger_table = Cylinders.Visibility.Constants.Wall * ones(size(table) + 2 * this.visibility);
            larger_table(this.visibility + 1:this.visibility + size(table,1), this.visibility + 1:this.visibility + size(table,2)) = abs(table);
            
            % read L1 neighborhood of given visibility
            me = zeros(size(larger_table));
            me(row + this.visibility, column + this.visibility) = 1;
            
            neighborhood = Cylinders.Visibility.Constants.Unspecified * ones(2 * this.visibility + 1);
            neighborhood(this.remapIndexes) = larger_table(conv2(me, this.VisibilityMap, 'same') > 0);
        end
    end
end

