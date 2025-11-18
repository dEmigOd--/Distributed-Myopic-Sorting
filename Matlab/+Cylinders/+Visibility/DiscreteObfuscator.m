classdef DiscreteObfuscator < Cylinders.Visibility.Ranger
    %DISCRETEOBFUSCATOR Ranger that should ensure things are in line of site
    
    properties (Access = private)
        underlyingRanger;
        lookupOrder;
        dependencies;
    end
    
    methods
        function obj = DiscreteObfuscator(underlyingRanger)
            obj = obj@Cylinders.Visibility.Ranger(underlyingRanger.visibility);
            obj.underlyingRanger = underlyingRanger;
            
            % setup lookup order and dependencies
            sideLength = 2 * underlyingRanger.visibility + 1;
            obj.lookupOrder = zeros(sideLength ^ 2 - 1, 1);
            obj.dependencies = cell(size(obj.lookupOrder));
            
            baseIndex = underlyingRanger.visibility + 1;
            
            directions = [...
                -1,  0; % north
                -1,  1; % north - east
                 0,  1; % east
                 1,  1; % south - east
                 1,  0; % south
                 1, -1; % south - west
                 0, -1; % west
                -1, -1; % north - west
                ];
                 
            % setup strict directions, with zero dependencies
            sizes = [sideLength, sideLength];
            obj.lookupOrder(1:size(directions, 1)) = sub2ind(sizes, baseIndex + directions(:, 1), baseIndex + directions(:, 2));
            
            % setup strict directions, with one dependency
            for distance = 2:underlyingRanger.visibility
                obj.lookupOrder((distance - 1) * size(directions, 1) + (1:size(directions, 1))) = ...
                    sub2ind(sizes, baseIndex + distance * directions(:, 1), baseIndex + distance * directions(:, 2));
                obj.dependencies((distance - 1)* size(directions, 1) + (1:size(directions, 1))) = ...
                    num2cell(sub2ind(sizes, baseIndex + (distance - 1) * directions(:, 1), baseIndex + (distance - 1) * directions(:, 2)), size(directions, 1));
            end
            
            current_base_index = size(directions, 1) * underlyingRanger.visibility;
            % how to move on the outer edge
            steps = directions([2:end, 1], :) - directions;
            prev_dependencies = [steps, steps]; % some are as is
            prev_dependencies(2:2:end, 1:2) = -steps(1:2:end, :); % x -1
            prev_dependencies(1:2:end, :) = prev_dependencies(2:2:end, :); % copy even to odd rows
            
            % setup strict directions, with one dependency
            for distance = 2:underlyingRanger.visibility
                for side_walk = 1:size(directions, 1)
                    row_base = baseIndex + directions(side_walk, 1) * distance;
                    column_base = baseIndex + directions(side_walk, 2) * distance;
                    obj.lookupOrder(current_base_index + (distance - 1) * (side_walk - 1) + (1:distance-1)) = ...
                        sub2ind(sizes, row_base + steps(side_walk,1) * (1:distance - 1), ...
                            column_base + steps(side_walk, 2) * (1:distance - 1));
                    for cl=1:distance-1
                        obj.dependencies(current_base_index + (distance - 1) * (side_walk - 1) + cl) = ...
                            num2cell(sub2ind(...
                                sizes, row_base + steps(side_walk, 1) * cl + prev_dependencies(side_walk, [1,3]), ...
                                column_base + steps(side_walk, 2) * cl + prev_dependencies(side_walk, [2,4])), 2);
                    end
                end
                current_base_index = current_base_index + 8 * (distance - 1);
            end
        end
        
        function neighborhood = ReadNeighborhood(this, table, row, column)
            % actually non obscured
            nonObscuredNeighborhood = this.underlyingRanger.ReadNeighborhood(table, row, column);
            neighborhood = nonObscuredNeighborhood;
            for agent = 1:numel(this.lookupOrder)
                visible = isempty(this.dependencies{agent});
                for dependency = 1:numel(this.dependencies{agent})
                    visible = visible || (neighborhood(this.dependencies{agent}(dependency)) == Cylinders.Visibility.Constants.Empty);
                end
                if ~visible
                    neighborhood(this.lookupOrder(agent)) = Cylinders.Visibility.Constants.Unspecified;
                end
            end
        end
    end
end

