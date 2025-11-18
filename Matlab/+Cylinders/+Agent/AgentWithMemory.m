classdef (Abstract) AgentWithMemory < Cylinders.Agent.BasicAgent
    %AgentWithMemory actual agent with memory
    
    properties (Access = protected)
        memory;
    end
    
    methods
        function obj = AgentWithMemory(initial_memory)
            obj = obj@Cylinders.Agent.BasicAgent();
            
            obj.memory = initial_memory;
        end
        
        function memory = DebugMemory(this)
            memory = this.memory;
        end
    end
end

