classdef TotallyRandomTestCase< Cylinders.Tests.RandomTestCase
    %RANDOMTESTCASE empty spaces will be set randomly

    methods
        function obj = TotallyRandomTestCase(goal_n, goal_m, ~, params)
            n = 1 + randi(goal_n - 1, 1);
            m = 1 + randi(goal_m - 1, 1);
            k = randi(n * m - 1, 1);
            obj = obj@Cylinders.Tests.RandomTestCase(n, m, k ,params);
        end
    end
end
