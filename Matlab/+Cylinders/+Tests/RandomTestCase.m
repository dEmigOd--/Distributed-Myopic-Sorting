classdef RandomTestCase < Cylinders.Tests.BasicTestCase
    %RANDOMTESTCASE empty spaces will be set randomly

    methods
        function obj = RandomTestCase(n, m, k, params)
            obj = obj@Cylinders.Tests.BasicTestCase(n, m, k ,params);
        end
    end
    
    methods (Access = protected)
        function emptySpaces = SetEmptySpaces(this)
            [I, J] = ind2sub([this.n, this.m], randperm(this.n * this.m, this.k));
            emptySpaces = [I', J'];
        end
    end
end

