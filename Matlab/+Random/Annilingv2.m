classdef Annilingv2
    %ANNILING Produce anniling probabilities, that do nto change
    
    properties
        an_params;
        
        exit_prob_map;
        cont_prob_map;
    end
    
    methods(Static)
        function [map] = GetMapWithWestDirection(base_east_probability, base_west_probability)
            side_probability = (1 - base_east_probability - base_west_probability) / 2;
            map = kron(ones(9, 1), [side_probability, base_east_probability, side_probability, base_west_probability]);
        end
        
        function [map] = GetMapWithEastDirection(base_east_probability, base_west_probability)
            side_probability = (1 - base_east_probability - base_west_probability) / 2;
            map = kron(ones(9, 1), [side_probability, base_east_probability, side_probability, base_west_probability]);
        end
    end
    
    methods
        function obj = Annilingv2(params)
            %ANNILING Construct an instance of this class
            obj.an_params = params.anniling_params;
            obj.exit_prob_map = Random.Annilingv2.GetMapWithEastDirection(obj.an_params.sort_exit_east_probability, ...
                obj.an_params.sort_exit_west_probability);
            obj.cont_prob_map = Random.Annilingv2.GetMapWithWestDirection(obj.an_params.sort_cont_east_probability, ...
                obj.an_params.sort_cont_west_probability);

            % pin exiting cars in the right-most column and continuing in the first one
            obj.exit_prob_map([1,4,8], 5) = obj.exit_prob_map([1,4,8], Parameters.SimulationParameters.west + 1);
            obj.exit_prob_map([1,4,8], Parameters.SimulationParameters.west + 1) = 0;
            obj.cont_prob_map([2,3,6], 5) = obj.cont_prob_map([2,3,6], Parameters.SimulationParameters.east + 1);
            obj.cont_prob_map([2,3,6], Parameters.SimulationParameters.east + 1) = 0;

            obj.exit_prob_map = obj.exit_prob_map ./kron(ones(1, size(obj.exit_prob_map, 2)), sum(obj.exit_prob_map, 2));
            obj.cont_prob_map = obj.cont_prob_map ./kron(ones(1, size(obj.cont_prob_map, 2)), sum(obj.cont_prob_map, 2));
        end
        
        function [this, result_exit_prob_map, result_cont_prob_map] = GetProbabilityMaps(this, ~)
            result_exit_prob_map = this.exit_prob_map;
            result_cont_prob_map = this.cont_prob_map;
        end
    end
end

