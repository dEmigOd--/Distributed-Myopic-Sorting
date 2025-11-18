classdef FrameTestCase < Cylinders.Tests.BasicTestCase
    %FrameTestCase empty spaces will be set on the frame

    methods
        function obj = FrameTestCase(n, m, k, params)
            obj = obj@Cylinders.Tests.BasicTestCase(n, m, k ,params);
        end
    end
    
    methods (Access = protected)
        function emptySpaces = SetEmptySpaces(this)
            zeroes = zeros(this.n, this.m);
            zeroes([1,end], :) = this.params.vehicle_exit;
            zeroes(:, [1, end]) = this.params.vehicle_exit;
            [I, J] = find(zeroes == this.params.no_vehicle);
            emptySpaces = [I, J];
        end
    end
end


