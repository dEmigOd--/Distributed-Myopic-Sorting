classdef RichAsyncInfoGrid < handle
    %RICHASYNCINFOGRID object constructed with exact agent locations
    
    properties
        sizes;
        agent_info;
    end
    
    methods
        function obj = RichAsyncInfoGrid(sizes, agent_types, agent_exact_locations)
            assert(size(agent_types, 1) == size(agent_exact_locations, 1));
            assert(sizes(1) * sizes(2) >= size(agent_types, 1));
            
            obj.sizes = sizes;

            obj.agent_info = zeros(size(agent_types, 1), 3);
            obj.agent_info(:, 1) = agent_types;
            obj.agent_info(:, 2:3) = agent_exact_locations;
        end
        
        function [] = transpose(obj)
            obj.sizes = obj.sizes';
            obj.agent_info(:, 2:3) = obj.agent_info(:, [3, 2]);
        end
    end
end

