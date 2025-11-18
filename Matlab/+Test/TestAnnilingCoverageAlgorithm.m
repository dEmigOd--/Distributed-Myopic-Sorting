function [success, average_iterations] = TestAnnilingCoverageAlgorithm(state, params)
%TESTANNILINGCOVERAGEALGORITHM Test anniling algorithm

    cparams = params;
    annilingParams = Parameters.AnnilingParameters;
    annilingParams.covg_north_probability = 0.25;
    annilingParams.covg_east_probability = 0.25;
    annilingParams.covg_south_probability = 0.25;
    annilingParams.covg_west_probability = 0.25;
    cparams.anniling_params = annilingParams;

    cparams.collision_solver = 'ALOHA';
    cparams.stop_on_coverage_complete = true;
    
    fprintf('Anniling started\n');
    [success, average_iterations] = Test.TestSingleCoverageAlgorithm(state, cparams, 100);
    fprintf('Anniling finished\n');
end

