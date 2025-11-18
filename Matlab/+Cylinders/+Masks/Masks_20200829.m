classdef Masks_20200829 < Cylinders.Masks.MasksSensed_1
    %MASKS_20200829 those are masks for agents at different states, but with visibility = 1
    % For the Sorting algorithm ver = 301
    % This is an EXITING vehicles Sensor Mask
    % maybe need to fix Position 6, so to move East from it
    
    methods (Static)
        function mask = EmptyMask(visibility)
            mask = Cylinders.Masks.GenericMasks.EmptyMask(visibility);
        end
        
        function visibility = RequiredVisibility()
            visibility = 1;
        end
    end
    
    methods
        function obj = Masks_20200829()
            obj = obj@Cylinders.Masks.MasksSensed_1(Cylinders.Masks.Masks_20200829.RequiredVisibility());
        end
        
        function mask = MaskPosition1(this)
            currentIndex = 1;
            if (isempty(this.stateMask{currentIndex}))
                this.stateMask{currentIndex} = ...
                    Cylinders.Masks.Mask( ...
                    this.visibility, ...
                    [
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
                        this.east, ...
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
                        this.west, ...
                        this.north, ...
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
                        this.east, ...
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
                        this.east, ...
                        this.south, ...
                    ]);
            end
            mask = this.stateMask{currentIndex};
        end
        
        function mask = MaskPosition8(this)
            mask = this.MaskPosition4();
        end
        
        function mask = MaskPosition9(this)
            currentIndex = 9;
            if (isempty(this.stateMask{currentIndex}))
                this.stateMask{currentIndex} = ...
                    Cylinders.Masks.Mask( ...
                    this.visibility, ...
                    [
                        this.north, ...
                        this.east, ...
                        this.south, ...
                    ]);
            end
            mask = this.stateMask{currentIndex};
        end
    end
end

