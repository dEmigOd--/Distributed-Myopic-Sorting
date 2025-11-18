classdef State < Cylinders.StateMachine.AbstractState
    %STATE is the new row in StateMachine's table
    
    properties (Access = private)
        mask; % indexes into neighborhood of interest
        readings_lookup; % what is actually in the reading, i.e. north is agent, while south is empty, etc.
        actions; % how to change memory and what to do
    end
    
    methods (Access = private)
        % create lookup index
        function index = GetLookupIndex(this, readings)
            if(isempty(readings))
                index = 1;
                return;
            end
            powers = Cylinders.Visibility.Constants.Possibilities .^ (sum(this.mask.GetMask(), 'all') - 1:-1:0);            
            index = 1 + powers * readings';
        end
        % return index, that is a number in the base Possibilities
        function index = GetEntry(this, readings)
            try
                index = this.readings_lookup(this.GetLookupIndex(readings));
            catch
                display(readings);
            end
        end
    end
    
    methods
        function obj = State(mask, actions)
            obj.mask = mask;
            obj.readings_lookup = zeros(Cylinders.Visibility.Constants.Possibilities ^ size(actions{1, 1}{1, 1}, 2), 1);
            if(size(actions, 2) > 1)
                fprintf('Actions supplied are wrongly sized\n');
            end
            obj.actions = cell(size(actions, 1), 1);
            for i = 1:size(actions, 1)
                % debug_index = obj.GetLookupIndex(actions{i, 1}{1, 1});
                % debug_reading = actions{i, 1}{1, 1};
                obj.readings_lookup(obj.GetLookupIndex(actions{i, 1}{1, 1})) = i;
                obj.actions{i} = actions{i, 1}{1, 2};
            end
            if(numel(obj.readings_lookup) > 4096)
                fprintf('Cylinders.StateMachine.State.\tWay too many possible actions\n');
            end
        end
        
        function [new_memory_state, action] = GetAction(this, readings)
            index = this.GetEntry(this.mask.GetReadings(readings));
            [new_memory_state, action] = this.actions{index, 1}.GetAction();
        end
        
        function [active_internal_states] = GetNumberOfStatesRequired(~)
            active_internal_states = 1;
        end
        
        function [handleable_states] = GetHandleableStates(this)
            index = find(this.readings_lookup);
            handleable_states = zeros(size(index));
            handleable_states(this.readings_lookup(index)) = index;
        end
        
        function [neighbor_rows, neighbor_columns] = GetNeighborsToTrace(this)
            [neighbor_rows, neighbor_columns] = ind2sub(size(this.mask.mask), this.mask.entries);
        end
        
        function [new_memories, actions] = GetActions(this)
            [new_memories, actions] = cellfun(@(x) x.GetAction(), this.actions);
        end
    end
end

