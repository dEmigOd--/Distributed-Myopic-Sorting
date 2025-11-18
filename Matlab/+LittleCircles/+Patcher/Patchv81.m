classdef Patchv81 < LittleCircles.Patcher.BasicPatcher
    %PATCHV81 patching v8 coverage algorithm (updated for sorting, i.e. no errors on empty space to the west of not-done agents
    
	properties (Access = private)
        masks;
        
        north;
        west;
        
        n;
	end
	
    methods
		function [obj] = Patchv81(params)
			obj = obj@LittleCircles.Patcher.BasicPatcher(params);
			
            obj.masks = Utility.Mask(params);
            % input direction
            obj.north = params.north + 1; obj.west = params.west + 1;
            obj.n = params.n;
        end
        
        function [visibility_range] = GetNeededVisibilityRange(~)
            visibility_range = 2;
        end
        
        function [updated_memory] = UpdateMemoryBeforeApplyingCoverageAlgorithm(this, state, memory, neighborhood)
			EMPTY = this.EMPTY;
			VEXIT = this.VEXIT;
			m1_column = this.masks.m1_column;
			m_column = this.masks.m_column;
            
			updated_memory = memory;
            % patch m1 agent above the empty space
			updated_memory(m1_column & (neighborhood(:, :, 3) == EMPTY)) = 3;
            
			% patch 1 in the right bottom corner
			updated_memory(m_column & (state == VEXIT)) = 3;
            updated_memory(m_column & (state ~= VEXIT) & (memory == 3) & (neighborhood(:, :, 3) == EMPTY)) = 2;
        end
        
        function [updated_memory] = UpdateMemoryAfterApplyingSortingAlgorithm(this, state, memory, neighborhood, move_intentions)
 			EMPTY = this.EMPTY;
			VEXIT = this.VEXIT;
            u_row = this.masks.u_row;
            d_row = this.masks.d_row;
            m1_column = this.masks.m1_column;
            
            % index offsets
            offset = [-1; this.n; 1; -this.n];	
            
            updated_memory = memory;
            
            % we are near some one and moving it
            % set memory for moving into first or last row to 1
            updated_memory(neighborhood(:, :, 2) == EMPTY & ~(u_row | d_row) & ~move_intentions) = 2;
            updated_memory(neighborhood(:, :, 2) == EMPTY & (u_row | d_row) & ~move_intentions) = 1;
            %updated_memory(state == EMPTY & ~(u_row | d_row | m1_column)) = 2;
            updated_memory(state == EMPTY & ~(u_row | d_row)) = 2;
            updated_memory(state == EMPTY & (u_row | d_row)) = 1;

%             for direction = this.north:this.west
%     			move_intent = (neighborhood(:, :, direction) == EMPTY) & move_intentions;
%                 updated_memory(find(move_intent & (state == VEXIT)) + offset(direction)) = 3;
%             end		
        end
        
        function [updated_memory] = UpdateMemoryUnconditionally(this, state, memory, neighborhood)
			EMPTY = this.EMPTY;
            u_row = this.masks.u_row;
            d_row = this.masks.d_row;
            m_column = this.masks.m_column;
           
            updated_memory = memory;
            
            % detect cells without neighboring empty cells and re-ignite them
            no_empty_cell_neighbor = ones(size(updated_memory));
            % if someone moves into the empty space - it was a neighbor of one
            no_empty_cell_neighbor(state == EMPTY) = 0;
            for direction = this.north:this.west
                no_empty_cell_neighbor = no_empty_cell_neighbor & (neighborhood(:, :, direction) ~= EMPTY);
            end
            updated_memory((updated_memory == 3) & no_empty_cell_neighbor & ~m_column & ~(u_row | d_row)) = 2;
            updated_memory((updated_memory >= 2) & no_empty_cell_neighbor & ~m_column & (u_row | d_row)) = 1;
        end            
    end    
end

