classdef AsyncTable < Cylinders.Table.Table
    %ASYNCTABLE Execute Agent decisions "asynchronously"
    
    properties (Constant, Access = protected)
        changing_north = Parameters.SimulationParameters.north;
        changing_east = Parameters.SimulationParameters.east;
        changing_south = Parameters.SimulationParameters.south;
        changing_west = Parameters.SimulationParameters.west;
        moving_straight = Parameters.SimulationParameters.do_nothing;
                
        col_agent_type = 1;
        col_curr_action = 2;
        col_cur_row = 3;
        col_cur_col = 4;
        col_goal_row = 5;
        col_goal_col = 6;
        
        dummy_vehicle = Parameters.SimulationParameters.vehicle_exit;
    end
    
    properties (Access = protected)
        async_scheduler;
        internal_time;
        schedule;
        schedule_times;
        dummy_grid;
    end
    
    methods (Access = private)
        function time_duration = GetActionDuration(this, actions)
            time_duration = zeros(size(actions, 1), 1);
            time_duration(actions == this.moving_straight) = this.async_scheduler.GetDecisionDuration();
            time_duration(actions == this.changing_north) = this.async_scheduler.GetForwardMoveDuration();
            time_duration(actions == this.changing_east) = this.async_scheduler.GetSideMoveDuration();
            time_duration(actions == this.changing_south) = this.async_scheduler.GetForwardMoveDuration();
            time_duration(actions == this.changing_west) = this.async_scheduler.GetSideMoveDuration();
        end
        
        function time_duration = GetNextActionFinishTime(this, actions)
            time_duration = zeros(size(actions, 1), 1);
            time_duration(actions == this.moving_straight) = this.async_scheduler.GetDecisionTime();
            time_duration(actions == this.changing_north) = this.async_scheduler.GetForwardMoveDuration();
            time_duration(actions == this.changing_east) = this.async_scheduler.GetSideMoveDuration();
            time_duration(actions == this.changing_south) = this.async_scheduler.GetForwardMoveDuration();
            time_duration(actions == this.changing_west) = this.async_scheduler.GetSideMoveDuration();
        end
    end
    
    methods (Access = protected)
        function  [action, new_row, new_column] = DecideForAgent(this, agent_id)
            [action, new_row, new_column] = this.agents{agent_id}.Decide(this.dummy_grid);
            
            this.schedule(agent_id, this.col_curr_action) = action;
            this.schedule(agent_id, this.col_goal_row) = new_row;
            this.schedule(agent_id, this.col_goal_col) = new_column;
            
            this.dummy_grid(new_row, new_column) = this.dummy_vehicle;
            this.schedule_times(agent_id) = this.schedule_times(agent_id) + this.GetNextActionFinishTime(action);
        end
    end
    
    methods
        function obj = AsyncTable(grid, params, versions, funcCreateAgent, funcExtractVisibility, async_scheduler, initial_memory)
            obj = obj@Cylinders.Table.Table(grid, params, versions, funcCreateAgent, funcExtractVisibility, initial_memory);
            
            obj.async_scheduler = async_scheduler;
            obj.internal_time = -async_scheduler.GetDecisionDuration();
            
            [agent_rows, agent_cols] = find(grid ~= params.no_vehicle);
            obj.schedule = zeros(size(agent_rows, 1), obj.col_goal_col);
            obj.schedule(:, obj.col_agent_type) = grid(grid ~= params.no_vehicle);
            obj.schedule(:, obj.col_curr_action) = obj.moving_straight;
            obj.schedule(:, obj.col_cur_row) = agent_rows;
            obj.schedule(:, obj.col_cur_col) = agent_cols;
            obj.schedule(:, obj.col_goal_row) = agent_rows;
            obj.schedule(:, obj.col_goal_col) = agent_cols;
            
            obj.schedule_times = zeros(size(agent_rows, 1), 1);
            
            obj.dummy_grid = zeros(size(obj.grid));
            obj.dummy_grid(obj.grid ~= obj.params.no_vehicle) = obj.dummy_vehicle;
        end
        
        function grid = GetAsyncGrid(this)
            action_left_times = this.schedule_times(:) - this.internal_time;
            action_durations = this.GetActionDuration(this.schedule(:, this.col_curr_action));
            
            lambda = (action_durations - action_left_times) ./ action_durations;
            lambda(this.schedule(:, this.col_curr_action) == this.moving_straight) = 1;
            
            if((min(lambda) < 0) || (max(lambda) > 1))
                fprintf('Wrong point calculations\n');
            end
            
            grid = Cylinders.Table.RichAsyncInfoGrid(size(this.grid), ...
                this.schedule(:, this.col_agent_type), ...
                [this.schedule(:, this.col_goal_row) .* lambda + ...
                this.schedule(:, this.col_cur_row) .* (1 - lambda), ...
                this.schedule(:, this.col_goal_col) .* lambda + ...
                this.schedule(:, this.col_cur_col) .* (1 - lambda)]);
        end
        
        function [] = ProcessTimeStep(this)
            remaining_agent_ids = true(size(this.agents));
            
            % min(this.schedule_times(:));
            new_time = this.internal_time + ...
                this.async_scheduler.GetDecisionDuration();
            
            while(true)
                if(min(this.schedule_times(:)) > new_time)
                    break;
                end
                
                ids_to_act = this.schedule_times(:) == min(this.schedule_times(:));
                
                ids = (1:size(this.schedule, 1))';
                ids_to_act=ids(ids_to_act);
                
                for agent_id = 1:size(ids_to_act, 1)
                    next_agent_id_to_act = ids_to_act(agent_id);
                    if(this.schedule(next_agent_id_to_act, this.col_curr_action) ~= this.moving_straight)
                        % update grid
                        agent_type = this.grid(this.schedule(next_agent_id_to_act, this.col_cur_row), ...
                            this.schedule(next_agent_id_to_act, this.col_cur_col));
                        this.grid(this.schedule(next_agent_id_to_act, this.col_cur_row), ...
                            this.schedule(next_agent_id_to_act, this.col_cur_col)) = ...
                            this.params.no_vehicle;
                        this.grid(this.schedule(next_agent_id_to_act, this.col_goal_row), ...
                            this.schedule(next_agent_id_to_act, this.col_goal_col)) = agent_type;
                        this.dummy_grid(this.schedule(next_agent_id_to_act, this.col_cur_row), ...
                            this.schedule(next_agent_id_to_act, this.col_cur_col)) = ...
                            this.params.no_vehicle;

                        this.schedule(next_agent_id_to_act, this.col_cur_row) = ...
                            this.schedule(next_agent_id_to_act, this.col_goal_row);
                        this.schedule(next_agent_id_to_act, this.col_cur_col) = ...
                            this.schedule(next_agent_id_to_act, this.col_goal_col);
                        this.schedule(next_agent_id_to_act, this.col_curr_action) = this.moving_straight;
                        this.schedule_times(next_agent_id_to_act) = this.schedule_times(next_agent_id_to_act) + ...
                            this.async_scheduler.GetPostActionDecisionTime();
                    else
                        [action, new_row, new_column] = DecideForAgent(this, next_agent_id_to_act);

                        if(action == Cylinders.Visibility.Constants.Error)
                            fprintf('Wha-wha-wha-wha. Erroneous action\n');
                        end
                        if(~this.StillOnGrid(new_row, new_column))
                            if(action == Cylinders.Visibility.Constants.do_nothing)
                                fprintf('Vehicle did nothing, but disappeared\n');
                            else
                                prev_row = new_row + (action == this.changing_north) - (action == this.changing_south);
                                prev_column = new_column - (action == this.changing_east) + (action == this.changing_west);
                                remaining_agent_ids(next_agent_id_to_act) = false;
                                fprintf('Vehicle at (%d, %d) is exiting\n', prev_row, prev_column);
                            end
                        end
                    end
                    
                end
            end
            
            sum_new_agents = this.SumAgents(this.grid);
            if(sum_new_agents ~= sum(remaining_agent_ids > 0))
                fprintf('Wha-wha-wha-wha: agents are disappearing\n');
            end
            
            if(any(this.grid > 1, 'all'))
                for row = 1:size(new_grid, 1)
                    for column = 1:size(new_grid, 2)
                        fprintf('%3d ', this.grid(row, column));
                    end
                    fprintf('\n');
                end
                fprintf('\n\nWha-wha-wha-wha\n');
            end
            
            this.internal_time = new_time;
            this.agents = this.agents(remaining_agent_ids);
        end
        
    end
end

