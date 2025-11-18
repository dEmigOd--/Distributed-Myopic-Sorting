function [success, average_iterations] = TestDetermenisticCoverageAlgorithm(state, params)
%TESTDETERMENISTICCOVERAGEALGORITHM Test algorithm set in params on specific state

    [success, average_iterations] = Test.TestSingleCoverageAlgorithm(state, params, 1);
end

