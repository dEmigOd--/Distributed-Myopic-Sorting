classdef Agent < Cylinders.Agent.AgentWithMemory
    %AGENT actual agent
    
    properties (Access = private)
        state_machine;
    end
    
    methods (Access = private, Static)
        function initial_memory = GetInitialMemory(arbitrary, valueBits, timerBits)
            initial_memory = 0;
            if arbitrary
                initial_memory = randi([0, 2 ^ valueBits - 1]) * 2 ^ timerBits;
            end
        end
    end
    
    methods
        function obj = Agent(state_machine, initial_memory)
            if(nargin < 2)
                initial_memory = Cylinders.Agent.Agent.GetInitialMemory(state_machine.SupportsArbitraryInitialState(), ...
                    state_machine.ValueBits, state_machine.TimerBits);
            end
            obj = obj@Cylinders.Agent.AgentWithMemory(initial_memory);
            
            obj.state_machine = state_machine;
        end
        
        function action = Decide(this, neighborhood)
            [new_memory, action] = this.state_machine.ProcessTimeStep(neighborhood, this.memory);
            this.memory = new_memory;
        end
    end
end

