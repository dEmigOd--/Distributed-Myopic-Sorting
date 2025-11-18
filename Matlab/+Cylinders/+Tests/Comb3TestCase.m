classdef Comb3TestCase  < Cylinders.Tests.BasicTestCase
    %Comb3TestCase empty spaces will be set like a comb-style on 3 rows only, and 12t+1 columns

    methods
        function obj = Comb3TestCase(~, m, ~, params)
            column_m = 12 * ceil(m / 12) + 1;
            obj = obj@Cylinders.Tests.BasicTestCase(3, column_m, ceil(m / 12) + ceil((column_m - 1) / 2) ,params);
        end
    end
    
    methods (Access = protected)
        function emptySpaces = SetEmptySpaces(this)
            zeroes = this.params.vehicle_exit * ones(this.n, this.m);
            zeroes(1, -3 + 12 * (1:floor(this.m / 12))) = this.params.no_vehicle;
            zeroes(3, 2 * (1:(this.m/2))) = this.params.no_vehicle;
            [I, J] = find(zeroes == this.params.no_vehicle);
            emptySpaces = [I, J];
        end
    end
end