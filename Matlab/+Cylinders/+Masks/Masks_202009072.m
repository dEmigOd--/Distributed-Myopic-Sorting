classdef Masks_202009072 < Cylinders.Masks.MasksSensed_1
    %MASKS_202009072 those are masks for agents at different states, but with visibility = 1
    % For the Sorting algorithm ver = 308
    % This is the CONTINUING two-column road Sensor Mask
    
    methods (Static)
        function mask = EmptyMask(visibility)
            mask = Cylinders.Masks.GenericMasks.EmptyMask(visibility);
        end
        
        function visibility = RequiredVisibility()
            visibility = 1;
        end
    end
    
    methods
        function obj = Masks_202009072()
            obj = obj@Cylinders.Masks.MasksSensed_1(Cylinders.Masks.Masks_202009072.RequiredVisibility());
        end
        
        function mask = MaskPosition1(this)
            currentIndex = 1;
            if (isempty(this.stateMask{currentIndex}))
                this.stateMask{currentIndex} = ...
                    Cylinders.Masks.Mask( ...
                    this.visibility, ...
                    [
                        this.north, ...
                        this.west, ...
                    ]);
            end
            mask = this.stateMask{currentIndex};
        end
        
        function mask = MaskPosition2(this)
            currentIndex = 2;
            if (isempty(this.stateMask{currentIndex}))
                this.stateMask{currentIndex} = ...
                    Cylinders.Masks.Mask( ...
                    this.visibility, ...
                    [
                        this.north, ...
                    ]);
            end
            mask = this.stateMask{currentIndex};
        end
        
        function mask = MaskPosition3(this)
            currentIndex = 3;
            if (isempty(this.stateMask{currentIndex}))
                this.stateMask{currentIndex} = ...
                    Cylinders.Masks.Mask( ...
                    this.visibility, ...
                    [
                        this.south, ...
                    ]);
            end
            mask = this.stateMask{currentIndex};
        end
        
        function mask = MaskPosition4(this)
            currentIndex = 4;
            if (isempty(this.stateMask{currentIndex}))
                this.stateMask{currentIndex} = ...
                    Cylinders.Masks.Mask( ...
                    this.visibility, ...
                    [
                        this.south, ...
                        this.west, ...
                    ]);
            end
            mask = this.stateMask{currentIndex};
        end
        
        function mask = MaskPosition5(this)
            currentIndex = 5;
            if (isempty(this.stateMask{currentIndex}))
                this.stateMask{currentIndex} = ...
                    Cylinders.Masks.Mask( ...
                    this.visibility, ...
                    [
                    ]);
            end
            mask = this.stateMask{currentIndex};
        end
        
        function mask = MaskPosition6(this)
            currentIndex = 6;
            if (isempty(this.stateMask{currentIndex}))
                this.stateMask{currentIndex} = ...
                    Cylinders.Masks.Mask( ...
                    this.visibility, ...
                    [
                        this.north, ...
                        this.south, ...
                    ]);
            end
            mask = this.stateMask{currentIndex};
        end
        
        function mask = MaskPosition7(this)
            currentIndex = 7;
            if (isempty(this.stateMask{currentIndex}))
                this.stateMask{currentIndex} = ...
                    Cylinders.Masks.Mask( ...
                    this.visibility, ...
                    [
                    ]);
            end
            mask = this.stateMask{currentIndex};
        end
        
        function mask = MaskPosition8(this)
            currentIndex = 8;
            if (isempty(this.stateMask{currentIndex}))
                this.stateMask{currentIndex} = ...
                    Cylinders.Masks.Mask( ...
                    this.visibility, ...
                    [
                        this.north, ...
                        this.south, ...
                        this.west, ...
                    ]);
            end
            mask = this.stateMask{currentIndex};
        end
        
        function mask = MaskPosition9(this)
            currentIndex = 9;
            if (isempty(this.stateMask{currentIndex}))
                this.stateMask{currentIndex} = ...
                    Cylinders.Masks.Mask( ...
                    this.visibility, ...
                    [
                    ]);
            end
            mask = this.stateMask{currentIndex};
        end
    end
end

