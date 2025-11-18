classdef BasicAgent < handle
    %AGENT interface
    
    properties (Access = private)
        token;
    end
    
    methods
        action = Decide(this, neighborhood);
        
        memory = DebugMemory(this);
    end
    
    methods
        function obj = BasicAgent()
            obj.token = false;
        end
        
        function token = GetToken(this)
            token = this.token;
        end
        
        function [] = SetToken(this)
            this.token = true;
        end
        function [] = UnsetToken(this)
            this.token = false;
        end
    end
end

