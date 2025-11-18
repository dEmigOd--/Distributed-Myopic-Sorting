classdef Annilingv1
    %ANNILING Produce anniling probabilities
    
    properties
        an_params;
        
        exit_prob_map;
        cont_prob_map;
    end
    
    methods(Static)
        function [map] = GetMapWithWestDirection(base_east_probability, base_west_probability, round)
            curr_east_probability = exp(-round) * base_east_probability;
            side_probability = (1 - base_east_probability - base_west_probability) / 2;
            curr_west_probability = 1 - 2 * side_probability - curr_east_probability;
            map = kron(ones(9, 1), [side_probability, curr_east_probability, side_probability, curr_west_probability, 0]);
        end
        
        function [map] = GetMapWithEastDirection(base_east_probability, base_west_probability, round)
            curr_west_probability = exp(-round) * base_west_probability;
            side_probability = (1 - base_east_probability - base_west_probability) / 2;
            curr_east_probability = 1 - 2 * side_probability - curr_west_probability;
            map = kron(ones(9, 1), [side_probability, curr_east_probability, side_probability, curr_west_probability, 0]);
        end
    end
    
    methods
        function obj = Annilingv1(params)
            %ANNILING Construct an instance of this class
            obj.an_params = params.anniling_params;
        end
        
        function [this, result_exit_prob_map, result_cont_prob_map] = GetProbabilityMaps(this, iteration)
            rnd = log(iteration) / log(this.an_params.sort_change_frequency);
            if(abs(round(rnd) - rnd) < 1e-8)
                this.exit_prob_map = Random.Annilingv1.GetMapWithEastDirection(this.an_params.sort_exit_east_probability, ...
                    this.an_params.sort_exit_west_probability, rnd);
                this.cont_prob_map = Random.Annilingv1.GetMapWithWestDirection(this.an_params.sort_cont_east_probability, ...
                    this.an_params.sort_cont_west_probability, rnd);
                
                available_directions = (Utility.Helper.GetAvailableDirections())';
                this.exit_prob_map(~available_directions) = 0;
                this.cont_prob_map(~available_directions) = 0;
                
                % pin exiting cars in the right-most column and continuing in the first one
                this.exit_prob_map([1,4,8], 5) = this.exit_prob_map([1,4,8], Parameters.SimulationParameters.west + 1);
                this.exit_prob_map([1,4,8], Parameters.SimulationParameters.west + 1) = 0;
                this.cont_prob_map([2,3,6], 5) = this.cont_prob_map([2,3,6], Parameters.SimulationParameters.east + 1);
                this.cont_prob_map([2,3,6], Parameters.SimulationParameters.east + 1) = 0;
                
                this.exit_prob_map = this.exit_prob_map ./kron(ones(1, size(this.exit_prob_map, 2)), sum(this.exit_prob_map, 2));
                this.cont_prob_map = this.cont_prob_map ./kron(ones(1, size(this.cont_prob_map, 2)), sum(this.cont_prob_map, 2));
            end
            
            result_exit_prob_map = this.exit_prob_map;
            result_cont_prob_map = this.cont_prob_map;
        end
    end
end

