classdef Table < Cylinders.Table.AbstractTable
    %TABLE implementation of the table for covering algorithm
    
    properties (Constant)
        Continue_Index = 2;
        Exit_Index = 1;
    end
    
    properties (Access = protected)
        agents;
        grid;
        visibility;
        params;
    end

    properties (Access = private)
        debug_tracker;
    end
    
    methods (Access = protected)
        function [onGrid] = StillOnGrid(this, new_row, new_column)
            onGrid = (new_row > 0) && (new_column > 0) && (new_row <= this.params.n) && (new_column <= this.params.m);
        end
        
        function next_id = CreateAgent(obj, actual_agent, ranger, row, column, current_id)
            obj.agents{current_id} = Cylinders.Agent.AgentWrapper(actual_agent, ranger, row, column);
            obj.debug_tracker(current_id, :) = [row, column];
            next_id = current_id + 1;
        end
        
        function  [action, new_row, new_column] = DecideForAgent(this, agent_id)
            [action, new_row, new_column] = this.agents{agent_id}.Decide(this.grid);
            this.debug_tracker(agent_id, :) = [new_row, new_column];
        end

        function [total] = SumAgents(this, grid)
            total = sum(grid ~= this.params.no_vehicle, 'all');
        end        
    end
    
    methods
        function obj = Table(grid, params, versions, funcCreateAgent, funcExtractVisibility, initial_memory)
            obj.grid = grid;
            obj.params = params;
            
            if(min(size(grid), [], 'all') < 2)
                name = class(obj);
                fprintf('%s: The algorithm only works on at least 2x3 grids\n', name);
            end
            
            state_machine_exit = Cylinders.StateMachine.StateMachineCreator().CreateStateMachine(versions(Cylinders.Table.Table.Exit_Index));
            if(size(versions, 1) < 2)
                state_machine_continue = state_machine_exit;
            else
                state_machine_continue = Cylinders.StateMachine.StateMachineCreator().CreateStateMachine(versions(Cylinders.Table.Table.Continue_Index));
            end
            
            obj.visibility = max(funcExtractVisibility(state_machine_continue), funcExtractVisibility(state_machine_exit));
            l1_ranger = Cylinders.Visibility.L1Ranger(obj.visibility);
            ranger = Cylinders.Visibility.DiscreteObfuscator(l1_ranger);
            
            obj.agents = cell(obj.SumAgents(grid), 1);
            obj.debug_tracker = zeros(obj.SumAgents(grid), 2);
            current = 1;
            
            for column = 1: size(grid, 2)
                for row = 1:size(grid, 1)
                    if(grid(row, column) == params.no_vehicle)
                        continue;
                    end
                    if(grid(row, column) == params.vehicle_continue)
                        state_machine = state_machine_continue;
                    else
                        state_machine = state_machine_exit;
                    end
                    
                    if(nargin < 6)
                        next_id = obj.CreateAgent(funcCreateAgent(state_machine), ranger, row, column, current);
                    else
                        next_id = obj.CreateAgent(funcCreateAgent(state_machine, initial_memory(row, column)), ranger, row, column, current);
                    end
                    
                    if(grid(row, column) == params.vehicle_exit)
                        obj.agents{current}.SetToken();
                    end
                    current = next_id;
                end
            end
        end
        
        function grid = GetGrid(this)
            grid = this.grid;
        end
        
        function grid = GetAsyncGrid(this)
            grid = Cylinders.Table.RichInfoGrid(this.grid, this.params.no_vehicle);
        end
        
        function [] = ProcessTimeStep(this)
            new_grid = zeros(size(this.grid));
            remaining_agent_ids = true(size(this.agents));
            
            for agent_id = 1:size(this.agents)
                [action, new_row, new_column] = DecideForAgent(this, agent_id);
                
                if(action == Cylinders.Visibility.Constants.Error)
                    fprintf('Wha-wha-wha-wha. Erroneous action\n');
                end
                if(~this.StillOnGrid(new_row, new_column))
                    if(action == Cylinders.Visibility.Constants.do_nothing)
                        fprintf('Vehicle did nothing, but disappeared\n');
                    else
                        prev_row = new_row + (action == Cylinders.Visibility.Constants.go_north) - (action == Cylinders.Visibility.Constants.go_south);
                        prev_column = new_column - (action == Cylinders.Visibility.Constants.go_east) + (action == Cylinders.Visibility.Constants.go_west);
                        remaining_agent_ids(agent_id) = false;
                        fprintf('Vehicle at (%d, %d) is exiting\n', prev_row, prev_column);
                    end
                else
                    new_grid(new_row, new_column) = new_grid(new_row, new_column) + ...
                        (this.params.vehicle_continue + 2 * this.agents{agent_id}.GetToken() * this.params.vehicle_exit);
                end
            end
            
            sum_new_agents = this.SumAgents(new_grid);
            if(sum_new_agents ~= sum(remaining_agent_ids > 0))
                fprintf('Wha-wha-wha-wha: agents are disappearing\n');
            end
            
            if(any(new_grid > 1, 'all'))
                for row = 1:size(new_grid, 1)
                    for column = 1:size(new_grid, 2)
                        fprintf('%3d ', new_grid(row, column));
                    end
                    fprintf('\n');
                end
                fprintf('\n\nWha-wha-wha-wha\n');
            end
            
            this.grid = new_grid;
            this.agents = this.agents(remaining_agent_ids);
        end
        
        function [memory] = GetMemory(this)
            memory = zeros(size(this.grid));
            for agent_id = 1:size(this.agents, 1)
                [mem, row, column] = this.agents{agent_id}.DebugMemory();
                memory(row, column) = mem;
            end
        end
        
        function [] = DebugMemory(this)
            memory = this.GetMemory();
            
            for row = 1:size(this.grid, 1)
                for column = 1:size(this.grid, 2)
                    if(this.grid(row, column))
                        fprintf('%s ', dec2bin(memory(row, column), 4));
                    else
                        fprintf(' NaN ');
                    end
                end
                fprintf('\n');
            end
        end
        
        function [location] = GetTrackingInfo(this)
            location = this.debug_tracker;
        end
    end
end

