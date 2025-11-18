function [success, average_iterations] = TestSingleCoverageAlgorithm(state, params, nruns)
    sum_iteration = 0;
    success = true;
    c_params = params;
    for i=1:nruns
        [last_success, iterations] = RunCoverageAlgorithm(state, c_params);
        fprintf('Algo %d finished ', c_params.coverage_algo_version);
        if(nruns > 1)
            fprintf('(%d)', i);
        end
        fprintf(' (success : %d, iterations : %d\n', last_success, iterations);
        sum_iteration = sum_iteration + iterations;
        success = success && last_success;
    end
    
    average_iterations = sum_iteration / nruns;
end