classdef Mask
    %MASK Common masks could be accessed
    
    properties (Access = public)
        m_column;
        m1_column;
        u_row;
        d_row;
    end
    
    methods
        function obj = Mask(params)
            sizes = [params.n, params.m];
            obj.m_column = false(sizes); obj.m_column(:, end) = true;
            obj.m1_column = false(sizes);
            if(params.n > 1)
                obj.m1_column(:, end - 1) = true;
            end
            obj.u_row = false(sizes); obj.u_row(1, :) = true;
            obj.d_row = false(sizes); obj.d_row(end, :) = true;
        end
        
    end
end

