classdef UIData
	%UIDATA class to hold picked in UI values
	
	properties
		AlgorithmNames;
		Algorithm;
        SortingAlgorithmVersion;
	end
	
	methods
		function obj = UIData()
			obj.AlgorithmNames = {'1bit Coverage', '2bit Coverage.v8', '2bit Coverage.v81', '2bit Multi Coverage', '4bit 2column Sorting', ...
                '2bit Visibility=3 Sorting', '3bit Multi Coverage'};
		end
	end
	
end

