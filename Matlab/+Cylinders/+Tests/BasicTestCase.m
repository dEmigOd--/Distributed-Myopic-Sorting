classdef BasicTestCase < handle
    %BASICTESTCASE Create An initial grid with agents
    % to test algorithms
    
    properties (Access = protected)
        n;
        m;
        k;
        params;
    end
    
    methods (Access = protected)
        emptySpaces = SetEmptySpaces(this);
    end
    
    methods
        function obj = BasicTestCase(n, m, k, params)
            obj.n = n;
            obj.m = m;
            obj.k = k;
            obj.params = params;
        end
        
        function grid = CreateGrid(this)
            % set all to be agents
            grid = this.params.vehicle_exit * ones(this.n ,this.m);
            % get empty places
            emptySpaces = this.SetEmptySpaces();
            % 'remove' agents from empty places
            grid(sub2ind(size(grid), emptySpaces(:, 1), emptySpaces(:, 2))) = this.params.no_vehicle;
        end
    end
end

