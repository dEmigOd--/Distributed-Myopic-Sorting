classdef Action < handle
    %ACTION How to change memory and what to do
    
    properties (Constant)
        north = Cylinders.Visibility.Constants.north;
        east = Cylinders.Visibility.Constants.east;
        south = Cylinders.Visibility.Constants.south;
        west = Cylinders.Visibility.Constants.west;
        do_nothing = Cylinders.Visibility.Constants.do_nothing;
		Error = Cylinders.Visibility.Constants.Error;
		Stop = Cylinders.Visibility.Constants.Stop;
        Unspecified = Cylinders.Visibility.Constants.Unspecified;
    end
    
    properties
        new_memory;
        action;
    end
    
    methods
        function obj = Action(new_memory, action)
            obj.new_memory = new_memory;
            obj.action = action;
        end
        
        function [new_memory, action] = GetAction(this)
            new_memory = this.new_memory;
            action = this.action;
        end
        
        function action = GetCopy(this)
            action = Cylinders.StateMachine.Action(this.new_memory, this.action);
        end
    end
end

