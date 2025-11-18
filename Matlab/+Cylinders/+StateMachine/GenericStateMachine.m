classdef (Abstract) GenericStateMachine < handle
    %GENERICSTATEMACHINE The Cellular Automata State Machine class
    
    properties (Access = protected, Constant)
        % Item constants
        EMPTY = 0;
        VEHICLE = 1;
        BORDER = 2;
        ANYTHING = 3;
        % Direction constants
        NORTH = 0;
        EAST = 1;
        SOUTH = 2;
        WEST = 3;
        NO_DIRECTION = 4;
        ERROR = 5;
    end
    
    properties (Access = protected)
        positionDetector;
        stateMachine;
    end
    
    methods (Access = protected, Static)
        function stateMachine = CreateStateMachine(masks, state_index, column_list)
            row_list = cell(size(column_list{1,1}{1, 2}, 2), 1);
            for memory_state = 1:size(row_list, 1)
                meaningful_states = cell(size(column_list, 2), 1);
                for state = 1:size(meaningful_states, 1)
                    action_list = column_list{1, state}{1, 2};
                    % disp(state);
                    % disp(memory_state);
                    meaningful_states{state} = {column_list{1, state}{1, 1}, action_list{memory_state}};
                end
                row_list{memory_state} = Cylinders.StateMachine.State(masks.MaskPosition(state_index), meaningful_states);
            end
            
            stateMachine = Cylinders.StateMachine.MultiRowState(row_list);
        end
    end
    
    methods (Access = protected)
        [] = InitStateMachines(obj);
        
        function obj = GenericStateMachine()         
            obj.InitStateMachines();
        end
        
        function [masks] = InitCommonRecords(this)
            masks = Cylinders.Masks.(sprintf("Masks_%d", this.MasksVersion))();
            if(this.RequiredVisibility() < masks.visibility)
                fprintf('This StateMachine version requires at least %d visibility, but only %d supplied\n', masks.visibility, this.RequiredVisibility());
            end
            this.positionDetector = Cylinders.Visibility.PositionDetector(masks.GetSensorMask());
            
            this.stateMachine = cell(masks.PossiblePositions(), 1);
        end
        
        function [position_on_grid] = DetectPosition(this, neighborhood)
            position_on_grid = this.positionDetector.DetectPosition(neighborhood);
        end
    end
    
    methods
        function [new_memory_state, action] = ProcessTimeStep(this, neighborhood, memory_state)
            position_on_grid = this.DetectPosition(neighborhood);
            %disp(position_on_grid);
            [new_memory_state, action] = this.stateMachine{position_on_grid}.GetAction(neighborhood, memory_state);
        end
        
        function doesSupport = SupportsArbitraryInitialState(~)
            doesSupport = false;
        end

        function [ignorable_states] = GetIgnorableStates(~)
            ignorable_states = [];
        end
        
        function [visibility] = RequiredVisibility(this)
            visibility = Cylinders.Masks.(sprintf('Masks_%d', this.MasksVersion)).RequiredVisibility();
        end
        
        function [] = Print_AllAtOnce(this, directory, filename)
            printer = Print.StateMachinePrinter1(this.stateMachine, this.RequiredVisibility());
            printer.Print(directory, filename);
        end
        
        function [states_printed] = Print(this, directory, filename, version, drop_do_not_care)
            printer = Print.StateMachinePrinter2(this.stateMachine, this.RequiredVisibility());
            states_printed = printer.Print(directory, filename, version, drop_do_not_care);
        end
        
        function [states_printed] = PrintInOneTable(this, directory, filename, version, drop_do_not_care)
            printer = Print.StateMachineRotatePrinter(this.stateMachine, this.RequiredVisibility());
            states_printed = printer.Print(directory, filename, version, drop_do_not_care, this.GetIgnorableStates());
        end
        
        function [] = ExportData(this, directory, version, sub_version)
            [result, ~, ~] = mkdir(directory, sprintf('Ver.%d', version));
            if(~result)
                fprintf('Unable to create directory\n');
                return;
            end
           
            work_directory = sprintf('%s/Ver.%d', directory, version);
            file = fopen(sprintf('%s/vehicle.%d.csv', work_directory, sub_version), 'w+'); 
            
            lookUpIndices = this.CreateIndices(this.RequiredVisibility());
            for stateId = 1:size(this.stateMachine, 1)
                fprintf(file, '%d\n', stateId);
                % a number of possible neighbors is 2 * r * (r + 1), where r - is an L1 radius
                neighbor_amount = 2 * this.RequiredVisibility() * (this.RequiredVisibility() + 1);
                neigh_hit = zeros(neighbor_amount, 1);
                % here comes border cells
                borders_on = this.GetBorders();

                [rows, columns] = this.stateMachine{stateId}.GetNeighborsToTrace();
                % index calculation is not anymore hardcoded for Visibility 1
                % a nice idea is to go around diamond in L1 at distance V from the center and increase indices
                neighb_indexes = lookUpIndices(sub2ind(size(lookUpIndices), rows, columns))';
                neigh_hit(neighb_indexes) = 1;

                % get border ids
                border_ids = find(borders_on(stateId, :)');
                neighb_indexes = [neighb_indexes; border_ids]; %#ok<AGROW>
                neigh_hit(border_ids) = 1;
                % get do not care ids
                donotcare_ids = find(neigh_hit == 0);
                neighb_indexes = [neighb_indexes; donotcare_ids]; %#ok<AGROW>

                handleable_states = this.stateMachine{stateId}.GetHandleableStates();
                fprintf(file, '%d\n', size(handleable_states, 1));
                for states_in=1:size(handleable_states, 1)
                    neighbors = this.ANYTHING * ones(size(neighb_indexes));
                    neighbors(neighb_indexes) = this.GetSensorReadings(handleable_states, rows, stateId, states_in);
                    neighbors_str = sprintf('%d, ', neighbors);
                    neighbors_str = string(extractBetween(neighbors_str, 1, strlength(neighbors_str) - 2));
                    fprintf(file, '%s\n', neighbors_str);
                end
    			[new_memories, actions] = this.stateMachine{stateId}.GetActions();
                fprintf(file, '%d\n', size(actions, 1));
                if(size(actions, 1) > 0)
                    fprintf(file, '%d, %d\n', [floor(new_memories(:) / (2 ^ this.TimerBits)), actions(:)]');
                end
            end
            
            fclose(file);
        end
        
    end
end

