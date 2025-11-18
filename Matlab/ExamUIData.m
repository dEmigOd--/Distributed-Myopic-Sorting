classdef ExamUIData
	%EXAMUIDATA class to hold picked in UI values for Exam
	
	properties
		AlgorithmNames;
		AlgorithmVersions;
        IsSortingAlgorithm;
        IsSingleAgentAlgorithm;
	end
	
	methods
		function obj = ExamUIData()
			obj.AlgorithmNames = {'Single Coverage. 1bit', 'Single Coverage. 2bit. A', ...
                'Single Coverage. 2bit. B', 'Single Coverage. 3bit. A', ...
                'Single Coverage. 3bit. B', 'Single Coverage. 5bit. V = 2', ...
                'Simulation of SC', ...
                'Multiple Coverage. 2bit. V = 2', 'Multiple Sorting. 3bit. m >= 3', ...
                'Multiple Sorting. 3bit. m = 2'};
            obj.AlgorithmVersions = [102, 104, 105, 106, 107, 108, 202, 1, 310, 319];
            obj.IsSortingAlgorithm = [0, 0, 0, 0, 0, 0, 0, 0, 1, 1];
            obj.IsSingleAgentAlgorithm = [1, 1, 1, 1, 1, 1, 0, 0, 0, 0];
            
            assert(all(size(obj.AlgorithmNames) == size(obj.AlgorithmVersions)), 'Some algorithms either have no name or version');
            assert(all(size(obj.AlgorithmNames) == size(obj.IsSortingAlgorithm)), 'Some algorithms lack sorting option');
            assert(all(size(obj.AlgorithmNames) == size(obj.IsSingleAgentAlgorithm)), 'Some algorithms lack single agent option');
		end
	end
end

