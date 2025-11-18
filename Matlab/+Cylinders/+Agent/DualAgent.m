classdef DualAgent < Cylinders.Agent.AgentWithMemory
    %DUALAGENT The actual dual agent, that takes a state machine of primal agent [visibility = 1]
    % but only single primal agent, simulate it locally according to the time it appears near
    
    properties(Constant)
        Initialized = 1;
        EmptyAtCycleStart = 2;
        EmptyAppeared = 3;
        ShouldExecute = 4;
        Timer = 5;
        EmptyMoveTimer = 6;
        Total = Cylinders.Agent.DualAgent.EmptyMoveTimer;
        
        none = Cylinders.Visibility.Constants.north - 1;

        no = 0;
        yes = 1;
    end
    
    properties (Access = private)
        prime_state_machine;
        timer_reset_at;
        
        neighborhood_required_visibility;
    end
    
    methods (Access = private)
        function where_empty = WhereIsEmptySpace(this, neighborhood)
            persistent directions;
            persistent direction_indices;
            
            if(isempty(directions))
                directions = [...
                        Cylinders.Visibility.Constants.north;
                        Cylinders.Visibility.Constants.east;
                        Cylinders.Visibility.Constants.south;
                        Cylinders.Visibility.Constants.west;                    
                    ];
            end
            if(isempty(direction_indices))
                me = 2 * this.neighborhood_required_visibility * (this.neighborhood_required_visibility + 1) + 1;
                direction_indices = [...
                        me - 1;
                        me + (2 * this.neighborhood_required_visibility + 1);
                        me + 1;
                        me - (2 * this.neighborhood_required_visibility + 1);                    
                    ];
            end
            
            if(~any(neighborhood(direction_indices) == Cylinders.Visibility.Constants.Empty, 'all'))
                where_empty = Cylinders.Agent.DualAgent.none;
            else
                where_empty = directions' * (neighborhood(direction_indices) == Cylinders.Visibility.Constants.Empty);
            end
        end
        
        function [should_move, at_time] = ShouldIMoveIntoEmptySpace(this, neighborhood, where_empty)
            persistent offsets;
            if(isempty(offsets))
                offsets = [-1,0; 0,1; 1,0; 0,-1];
            end
            me_x = this.neighborhood_required_visibility + 1;
            me_y = me_x;
            
            empty_space_neighborhood = neighborhood((me_x + offsets(where_empty + 1, 1) - 1):(me_x + offsets(where_empty + 1, 1) + 1), ...
                (me_y + offsets(where_empty + 1, 2) - 1):(me_y + offsets(where_empty + 1, 2) + 1));
            % problematic not to adjust actually invisible corners            
            empty_space_neighborhood(empty_space_neighborhood == Cylinders.Visibility.Constants.Agent) = Cylinders.Visibility.Constants.Empty;
            empty_space_neighborhood([1,3,7,9]) = Cylinders.Visibility.Constants.Unspecified;
            empty_space_neighborhood(2,2) = Cylinders.Visibility.Constants.Agent;
            
            %disp(this.memory(Cylinders.Agent.DualAgent.Timer) - 1);
            [at_time, action] = this.prime_state_machine.ProcessTimeStep(empty_space_neighborhood, this.memory(Cylinders.Agent.DualAgent.Timer) - 1);
            
            % this could be problematic in case do-nothing returned
            if(action == Cylinders.Visibility.Constants.do_nothing)
                error('Unable currently to handle do_nothing actions'); % just set new time on actual action
            end
            
            should_move = abs(action - where_empty) == 2; % i.e. moves into me            
        end
    end
    
    methods
        function obj = DualAgent(prime_state_machine)
            if(prime_state_machine.RequiredVisibility() ~= 1)
                error('This specific Dual Algorithm supports only visibility = 1 Primal Algorithms');
            end
            
            initial_memory = zeros(Cylinders.Agent.DualAgent.Total, 1);
            initial_memory(Cylinders.Agent.DualAgent.Initialized) = Cylinders.Agent.DualAgent.no;
            initial_memory(Cylinders.Agent.DualAgent.EmptyAtCycleStart) = Cylinders.Agent.DualAgent.no;
            initial_memory(Cylinders.Agent.DualAgent.EmptyAppeared) = Cylinders.Agent.DualAgent.no;
            initial_memory(Cylinders.Agent.DualAgent.ShouldExecute) = Cylinders.Agent.DualAgent.no;
            initial_memory(Cylinders.Agent.DualAgent.Timer) = 0;
            initial_memory(Cylinders.Agent.DualAgent.EmptyMoveTimer) = 0;
            
            obj = obj@Cylinders.Agent.AgentWithMemory(initial_memory);
            
            % possibly one more
            obj.timer_reset_at = 2 ^ (prime_state_machine.ValueBits + prime_state_machine.TimerBits) + 1;
            obj.prime_state_machine = prime_state_machine;
            
            obj.neighborhood_required_visibility = 2;
        end
        
        function action = Decide(this, neighborhood)
            where_empty = this.WhereIsEmptySpace(neighborhood);
            % need to execute and the time is right
            if((this.memory(Cylinders.Agent.DualAgent.ShouldExecute) == Cylinders.Agent.DualAgent.yes) && ...
                (this.memory(Cylinders.Agent.DualAgent.EmptyAtCycleStart) == Cylinders.Agent.DualAgent.yes) && ...
                (this.memory(Cylinders.Agent.DualAgent.Timer) == this.memory(Cylinders.Agent.DualAgent.EmptyMoveTimer)))
                this.memory(Cylinders.Agent.DualAgent.ShouldExecute) = Cylinders.Agent.DualAgent.no;
                this.memory(Cylinders.Agent.DualAgent.EmptyAtCycleStart) = Cylinders.Agent.DualAgent.no;
                action = where_empty;
            else
                action = Cylinders.Visibility.Constants.do_nothing;
                
                if(this.memory(Cylinders.Agent.DualAgent.Initialized) == Cylinders.Agent.DualAgent.no)
                    this.memory(Cylinders.Agent.DualAgent.Initialized) = Cylinders.Agent.DualAgent.yes;
                else
                    if(where_empty ~= Cylinders.Agent.DualAgent.none && this.memory(Cylinders.Agent.DualAgent.EmptyAppeared) == Cylinders.Agent.DualAgent.no) && ...
                            (this.memory(Cylinders.Agent.DualAgent.EmptyAtCycleStart) == Cylinders.Agent.DualAgent.no)
                        % arrived at previous time step
                        this.memory(Cylinders.Agent.DualAgent.EmptyAppeared) = Cylinders.Agent.DualAgent.yes;
                        [should_move, at_time] = this.ShouldIMoveIntoEmptySpace(neighborhood, where_empty);
                        
                        if(should_move)
                            this.memory(Cylinders.Agent.DualAgent.ShouldExecute) = Cylinders.Agent.DualAgent.yes;
                            this.memory(Cylinders.Agent.DualAgent.EmptyMoveTimer) = at_time;
                        end
                    end
                end
            end
            
            this.memory(Cylinders.Agent.DualAgent.Timer) = this.memory(Cylinders.Agent.DualAgent.Timer) + 1;
            if(this.memory(Cylinders.Agent.DualAgent.Timer) == this.timer_reset_at)
                this.memory(Cylinders.Agent.DualAgent.Timer) = 0;
                if(where_empty ~= Cylinders.Agent.DualAgent.none)
                    this.memory(Cylinders.Agent.DualAgent.EmptyAtCycleStart) = Cylinders.Agent.DualAgent.yes;
                else
                    this.memory(Cylinders.Agent.DualAgent.EmptyAtCycleStart) = Cylinders.Agent.DualAgent.no;
                end
                this.memory(Cylinders.Agent.DualAgent.EmptyAppeared) = Cylinders.Agent.DualAgent.no;
            end
        end
    end
end

