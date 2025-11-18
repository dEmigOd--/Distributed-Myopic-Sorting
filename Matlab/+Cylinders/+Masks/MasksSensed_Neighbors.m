classdef MasksSensed_Neighbors < Cylinders.Masks.GenericMasks
    %MasksSensed_Neighbors Those are masks with sensing of radius 1 (L1) but applied to some neighbor of current cell
    
    properties (Access = private)
        positionMask;
    end
    
    properties %(Access = protected)
        stateMask;
    end    

    properties (Access = protected)
        north;
        east;
        south;
        west;
        
        north_north;
        east_east;
        south_south;
        west_west;
        
        west_north; % intentionally this name !
    end

    methods
        function obj = MasksSensed_Neighbors(visibility, row_offset, column_offset)
            if((abs(row_offset) + 1 > visibility) || (abs(column_offset) + 1 > visibility))
                error('Unable to create a position detecting mask : need to sense out of visibility range');
            end
            
            obj.visibility = visibility;
            
            sizeNeighborhood = 2  * visibility + 1;
            me = sizeNeighborhood * visibility + visibility + 1;
            neighbor = me + row_offset + column_offset * visibility ;
            
            obj.north = neighbor - 1;
            obj.east = neighbor + sizeNeighborhood;
            obj.south = neighbor + 1;
            obj.west = neighbor - sizeNeighborhood;
            
            % check no real meaning for visibility < 2 
            obj.north_north = obj.north - 1;
            obj.east_east = obj.east + sizeNeighborhood;
            obj.south_south = obj.south + 1;
            obj.west_west = obj.west - sizeNeighborhood;

            obj.west_north = obj.west - 1;
            
            obj.stateMask = cell(obj.PossiblePositions(), 1);
        end
        
        function sensedPositionCount = PossiblePositions(~)
            sensedPositionCount = 9;
        end
        
        function mask = GetSensorMask(this)
            if (isempty(this.positionMask))
                this.positionMask = ...
                    Cylinders.Masks.Mask( ...
                    this.visibility, ...
                    [
                        this.north, ...
                        this.east, ...
                        this.south, ...
                        this.west ...
                    ]);
            end
            mask = this.positionMask;
        end        
    end
end

