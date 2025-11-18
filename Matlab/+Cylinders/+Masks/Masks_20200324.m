classdef Masks_20200324 < Cylinders.Masks.MasksSensed_1
    %MASKS those are masks for agents at different states
    
    methods (Static)
        function mask = EmptyMask(visibility)
            mask = Cylinders.Masks.GenericMasks.EmptyMask(visibility);
        end
        
        function visibility = RequiredVisibility()
            visibility = 2;
        end
    end
    
    methods
        function obj = Masks_20200324()
            obj = obj@Cylinders.Masks.MasksSensed_1(Cylinders.Masks.Masks_20200324.RequiredVisibility());
        end
        
        function mask = MaskPosition1(this)
            if(this.visibility < 2)
                fprintf('Need visibility of at least 2 to work\n');
            end
            currentIndex = 1;
            if (isempty(this.stateMask{currentIndex}))
                this.stateMask{currentIndex} = ...
                    Cylinders.Masks.Mask( ...
                    this.visibility, ...
                    [
                        this.west_north, ...
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
            if(this.visibility < 2)
                fprintf('Need visibility of at least 2 to work\n');
            end
            currentIndex = 5;
            if (isempty(this.stateMask{currentIndex}))
                this.stateMask{currentIndex} = ...
                    Cylinders.Masks.Mask( ...
                    this.visibility, ...
                    [
                        this.west_north, ...
                        this.west, ...
                        this.north_north, ...
                        this.north, ...
                    ]);
            end
            mask = this.stateMask{currentIndex};
        end
        
        function mask = MaskPosition6(this)
            mask = this.MaskPosition2();
        end
        
        function mask = MaskPosition7(this)
            mask = this.MaskPosition3();
        end
        
        function mask = MaskPosition8(this)
            mask = this.MaskPosition4();
        end
        
        function mask = MaskPosition9(this)
            if(this.visibility < 2)
                fprintf('Need visibility of at least 2 to work\n');
            end
            currentIndex = 9;
            if (isempty(this.stateMask{currentIndex}))
                this.stateMask{currentIndex} = ...
                    Cylinders.Masks.Mask( ...
                    this.visibility, ...
                    [
                        this.north_north, ...
                        this.north, ...
                        this.south, ...
                        this.south_south ...
                    ]);
            end
            mask = this.stateMask{currentIndex};
        end
    end
end

