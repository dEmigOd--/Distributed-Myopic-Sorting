function [ ] = ExamCentralizedUI( uiData )
	%EXAMCENTRALIZEDUI UI for presenting visual interface for covering/sorting algorithms 
    % Final Exam

    %%      ----   UI Settings   -----       %%
    %
    %     
    %
    %
    panelXMargin = 0.01;
    panelYMargin = 0.05;
    panelControlXSize = 0.3;
    
    controlXOffset = 0.5;
    controlYOffset = 0.8;
    automaticValuesYOffset = 0.1;
    interControlXDistance = 0.05;
    interControlYDistance = 0.05;
    
    controlWidth = 0.3;
    controlHeight = 0.04;
    
    radioButtonGroupYSize = 0.14;
    radioButtonXSize = 0.8;

    slidersYOffset = 0.4;
    pushbuttonsYOffset = 0.2;
    
    %%      ----   Algorithm Parameters   -----       %%
    %
    %     
    %
    %
    n = 8; % number of rows
    m = 6; % number of columns
    k = n * m - 1; % number of empty spaces
    num_exiting = 1; % number of exiting vehicles
    
    %%      ----   Interesting Runner Settings   -----       %%
    %
    %     
    %
    %
    algorithm_version = 310;%319;
    demo_async = false;
    demo_move_forward_duration = 1;
    demo_move_sideward_duration = 1;
    demo_decision_duration = 2 * demo_move_forward_duration;
 
    %%      ----   Relevant Runner Settings   -----       %%
    %
    %     
    %
    %
    test_name = 'Random';
    recorder_visual_on = true;
    update_ui_frequency = 1;
    pause_between_frames = 0.01;
    max_iterations = 100000;
    stop_on_completion = false;


    params = Parameters.SimulationParameters(n, m, recorder_visual_on);
    params.pause_for = pause_between_frames;

    recorder = [];
    grid = [];
    table = [];

    %%      ----   Irrelevant Runner Settings   -----       %%
    %
    %     
    %
    %
   
    capture_video = false;
    frames_per_second = 24;
    continue_to_capture = true;
    for_at_least_that_much = 5; % seconds
    for_at_least_that_much = for_at_least_that_much * frames_per_second;
    
    debug_memory_on = false;
    debug_tempo_spatiality = false;
    debug_tempo_spatiality_scale = 0.1;
    debug_tempo_spatiality_iterations = 2000;
    debug_tempo_spatiality_skip_iterations = 2000;
    keep_track_of_last_visits = false;

    progress_recorders = [];

    %%      ----   Common Variables   -----       %%
    %
    %     
    %
    %
    
    COLOR_EXIT = Parameters.SimulationParameters.vehicle_exit;
    COLOR_CONTINUE = Parameters.SimulationParameters.vehicle_continue;
    COLOR_EMPTY = Parameters.SimulationParameters.no_vehicle;
    
    algorithm_id = 1;
    
    defaultColor = COLOR_EMPTY;
    manualColor = COLOR_EMPTY;
    speed = 100;

    %% controls
    mainForm = figure('units','normalized','outerposition',[0 0 1 1], 'WindowState', 'maximized');
    
    %% create panels
    controlPanel = uipanel(mainForm, ...
       'Units', 'normalized', ...
       'Position', [panelXMargin 
                    panelYMargin 
                    panelControlXSize - 2 * panelXMargin  
                    1 - 2 * panelYMargin]);
    presentationPanel = uipanel(mainForm, ...
       'Units', 'normalized', ...
       'Position', [panelControlXSize + panelXMargin 
                    panelYMargin 
                    (1 - panelControlXSize) - 2 * panelXMargin  
                    1 - 2 * panelYMargin]);
   
    %% Create pop-up menu for algorithms
    popupAlgorithmToRun = uicontrol(controlPanel, ...
       'Style', 'popup',...
       'String', uiData.AlgorithmNames,...
       'Units', 'normalized', ...
       'Position', [controlXOffset + interControlXDistance 
                    controlYOffset + automaticValuesYOffset
                    controlWidth 
                    controlHeight],...
       'Callback', @AlgorithmPicked);
	
    % Add a text uicontrol to label the bases pop-up control.
    txtBasis = uicontrol(controlPanel, ...
        'Style','text',...
        'Units', 'normalized', ...
        'Position',[controlXOffset - interControlXDistance - controlWidth
                    controlYOffset + automaticValuesYOffset
                    controlWidth 
                    0.9 * controlHeight],...
        'String','Algorithm Type'); %#ok<NASGU>

    %% add toggle button group for default coloring of vehicles
%     defaultColoring = uibuttongroup(controlPanel, ...
%         'Units', 'normalized', ...
%         'Position',[controlXOffset - interControlXDistance - controlWidth
%                     controlYOffset - 6 * interControlYDistance 
%                     controlWidth 
%                     radioButtonGroupYSize], ...
%         'Title', 'default coloring', ...
%         'SelectionChangedFcn', @DefaultButtonGroupSelectionChange);
%     defaultExit = uicontrol(defaultColoring, ...
%         'Style', 'radiobutton', ...
%         'Units', 'normalized', ...
%         'Position',[controlXOffset - interControlXDistance - controlWidth
%                     controlYOffset - 1.5 * interControlYDistance 
%                     radioButtonXSize 
%                     radioButtonGroupYSize], ...
%         'Value', 0, ...
%         'String', 'Exit'); %#ok<NASGU>
%     defaultContinue = uicontrol(defaultColoring, ...
%         'Style', 'radiobutton', ...
%         'Units', 'normalized', ...
%         'Position',[controlXOffset - interControlXDistance - controlWidth
%                     controlYOffset - 7 * interControlYDistance 
%                     radioButtonXSize 
%                     radioButtonGroupYSize], ...
%         'Value', 0, ...
%         'String', 'Continue'); %#ok<NASGU>
%     defaultEmpty = uicontrol(defaultColoring, ...
%         'Style', 'radiobutton', ...
%         'Units', 'normalized', ...
%         'Position',[controlXOffset - interControlXDistance - controlWidth
%                     controlYOffset - 12.5 * interControlYDistance 
%                     radioButtonXSize 
%                     radioButtonGroupYSize], ...
%         'Value', 1, ...
%         'String', 'Empty'); %#ok<NASGU>
       
    %% add toggle button group for manual coloring of vehicles
    manualColoring = uibuttongroup(controlPanel, ...
        'Units', 'normalized', ...
        'Position',[controlXOffset
                    controlYOffset - 6 * interControlYDistance 
                    controlWidth 
                    radioButtonGroupYSize], ...
       'Title', 'manual coloring', ...
       'SelectionChangedFcn', @ManualButtonGroupSelectionChange);
    manualExit = uicontrol(manualColoring, ...
        'Style', 'radiobutton', ...
        'Units', 'normalized', ...
        'Position',[controlXOffset - interControlXDistance - controlWidth
                    controlYOffset - 1.5 * interControlYDistance 
                    radioButtonXSize 
                    radioButtonGroupYSize], ...
        'Value', 0, ...
        'String', 'Exit'); %#ok<NASGU>
    manualContinue = uicontrol(manualColoring, ...
        'Style', 'radiobutton', ...
        'Units', 'normalized', ...
        'Enable', 'off', ...
        'Position',[controlXOffset - interControlXDistance - controlWidth
                    controlYOffset - 7 * interControlYDistance 
                    radioButtonXSize 
                    radioButtonGroupYSize], ...
        'Value', 0, ...
        'String', 'Continue');
    manualEmpty = uicontrol(manualColoring, ...
        'Style', 'radiobutton', ...
        'Units', 'normalized', ...
        'Position',[controlXOffset - interControlXDistance - controlWidth
                    controlYOffset - 12.5 * interControlYDistance 
                    radioButtonXSize 
                    radioButtonGroupYSize], ...
        'Value', 1, ...
        'String', 'Empty'); %#ok<NASGU>
    
    %% add Row/Column Size controls
    rowSize = uicontrol(controlPanel, ...
        'Style','edit',...
        'Units', 'normalized', ...
        'FontSize', 16, ...
        'String', n, ...
        'Callback', @ResetPressed, ...
        'Position',[controlXOffset + interControlXDistance
                    controlYOffset - interControlYDistance + automaticValuesYOffset
                    controlWidth 
                    0.9 * controlHeight]);
    rowSizeText = uicontrol(controlPanel, ...
        'Style','text',...
        'Units', 'normalized', ...
        'Position',[controlXOffset - interControlXDistance - controlWidth
                    controlYOffset - 1.2 * interControlYDistance + automaticValuesYOffset
                    controlWidth 
                    0.9 * controlHeight],...
        'String','Num Rows'); %#ok<NASGU>
    
    columnSize = uicontrol(controlPanel, ...
        'Style','edit',...
        'Units', 'normalized', ...
        'FontSize', 16, ...
        'String', m, ...
        'Callback', @ResetPressed, ...
        'Position',[controlXOffset + interControlXDistance
                    controlYOffset - 2 * interControlYDistance + automaticValuesYOffset
                    controlWidth 
                    0.9 * controlHeight]);
    columnSizeText = uicontrol(controlPanel, ...
        'Style','text',...
        'Units', 'normalized', ...
        'Position',[controlXOffset - interControlXDistance - controlWidth
                    controlYOffset - 2.2 * interControlYDistance + automaticValuesYOffset
                    controlWidth 
                    0.9 * controlHeight],...
        'String','Num Columns'); %#ok<NASGU>

    %% add exiting and empty properties controls
    exitingNumber = uicontrol(controlPanel, ...
        'Style','edit',...
        'Units', 'normalized', ...
        'FontSize', 16, ...
        'String', num_exiting, ...
        'Position',[controlXOffset + interControlXDistance
                    controlYOffset - 3 * interControlYDistance + automaticValuesYOffset
                    controlWidth 
                    0.9 * controlHeight]);
    
    exitingNumberText = uicontrol(controlPanel, ...
        'Style','text',...
        'Units', 'normalized', ...
        'Position',[controlXOffset - interControlXDistance - controlWidth
                    controlYOffset - 3.2 * interControlYDistance + automaticValuesYOffset
                    controlWidth 
                    0.9 * controlHeight],...
        'String','Num exiting'); %#ok<NASGU>
    
    emptyNumber = uicontrol(controlPanel, ...
        'Style','edit',...
        'Units', 'normalized', ...
        'FontSize', 16, ...
        'String', k, ...
        'Position',[controlXOffset + interControlXDistance
                    controlYOffset - 4 * interControlYDistance + automaticValuesYOffset
                    controlWidth 
                    0.9 * controlHeight]);
    emptyNumberText = uicontrol(controlPanel, ...
        'Style','text',...
        'Units', 'normalized', ...
        'Position',[controlXOffset - interControlXDistance - controlWidth
                    controlYOffset - 4.2 * interControlYDistance + automaticValuesYOffset
                    controlWidth 
                    0.9 * controlHeight],...
        'String','Num empty'); %#ok<NASGU>
    
    %% add async settings controls
   asyncCheckbox = uicontrol(controlPanel, ...
        'Style', 'checkbox', ...
        'Units', 'normalized', ...
        'Position',[controlXOffset - interControlXDistance
                    slidersYOffset - interControlYDistance
                    controlWidth 
                    0.9 * controlHeight],...
        'Callback', @AsyncInitToggled); %#ok<NASGU>
    asyncCheckboxTxt = uicontrol(controlPanel, ...
        'Style','text',...
        'Units', 'normalized', ...
        'Position',[controlXOffset - interControlXDistance - controlWidth
                    slidersYOffset - 1.2 * interControlYDistance
                    controlWidth 
                    0.9 * controlHeight],...
        'String','Try async'); %#ok<NASGU>

    %% add sliders
    speedControl = uicontrol(controlPanel, ...
        'Style','slider', ...
        'Units', 'normalized', ...
        'Position',[controlXOffset - interControlXDistance 
                    slidersYOffset 
                    controlWidth + 2 * interControlXDistance
                    controlHeight],...
        'value',speed, ...
        'min',1, ...
        'max',100, ...
        'Callback', @SpeedChanged); %#ok<NASGU>
    % Add a text uicontrol to label the bases pop-up control.
    speedTxt = uicontrol(controlPanel, ...
        'Style','text',...
        'Units', 'normalized', ...
        'Position',[controlXOffset - interControlXDistance - controlWidth
                    slidersYOffset - 0.2 * interControlYDistance
                    controlWidth 
                    0.9 * controlHeight],...
        'String','speed'); %#ok<NASGU>
    
    %% add command buttons
    runButton = uicontrol(controlPanel, ...
        'Style','pushbutton', ...
        'Units', 'normalized', ...
        'Position',[controlXOffset - interControlXDistance - controlWidth
                    pushbuttonsYOffset
                    controlWidth
                    controlHeight],...
        'String','Run', ...
        'Callback', @RunPressed); %#ok<NASGU>
    stepButton = uicontrol(controlPanel, ...
        'Style','pushbutton', ...
        'Units', 'normalized', ...
        'Position',[controlXOffset + interControlXDistance
                    pushbuttonsYOffset
                    controlWidth
                    controlHeight],...
        'String','Step', ...
        'Callback', @StepPressed); %#ok<NASGU>
    stopButton = uicontrol(controlPanel, ...
        'Style','togglebutton', ...
        'Units', 'normalized', ...
        'Position',[controlXOffset - interControlXDistance - controlWidth
                    pushbuttonsYOffset - interControlYDistance
                    controlWidth
                    controlHeight],...
        'String','Stop');
    resetButton = uicontrol(controlPanel, ...
        'Style','pushbutton', ...
        'Units', 'normalized', ...        
        'Position',[controlXOffset + interControlXDistance
                    pushbuttonsYOffset - interControlYDistance
                    controlWidth
                    controlHeight],...
        'String','Reset', ...
        'Callback', @ResetPressed); %#ok<NASGU>
    
    %% add axis for imshow
    roadAxes = axes(presentationPanel, ...        
        'Visible', 'off', ...
        'Units', 'normalized', ...
        'Position', [0 0 1 1], ...
        'ButtonDownFcn', @RoadStateToggle ...
    );
    
    %% Initiate Run
    ResetPressed(0, 0);
    
    %%      ----   FUNCTIONS   -----       %%
    %
    %     
    %
    %
    function [] = AlgorithmPicked( source, ~ )
        algorithm_id = source.Value;
		SyncAlgorithm();
        
        columnSize.Enable = 'on';
        if(algorithm_version == 319)
            params.m = 2;
            columnSize.String = params.m;
            columnSize.Enable = 'off';
        end
        
        if(~uiData.IsSortingAlgorithm(algorithm_id))
            manualContinue.Enable = 'off';
        else
            manualContinue.Enable = 'on';
        end
        SetDefaultInitValues();
        ResetPressed(0, 0);
    end

    function [] = DefaultButtonGroupSelectionChange( ~, value) %#ok<DEFNU>
        if(strcmp(value.NewValue.String, 'Exit'))
            defaultColor = COLOR_EXIT;  %#ok<SETNU>
        else
            if(strcmp(value.NewValue.String, 'Continue'))
                defaultColor = COLOR_CONTINUE;
            else
                defaultColor = COLOR_EMPTY;
            end
        end
    end

    function [] = ManualButtonGroupSelectionChange( ~, value)
        if(strcmp(value.NewValue.String, 'Exit'))
            manualColor = COLOR_EXIT; 
        else
            if(strcmp(value.NewValue.String, 'Continue'))
                manualColor = COLOR_CONTINUE;
            else
                manualColor = COLOR_EMPTY;
            end
        end
    end

    function [] = EnsureValidValues()
        if(k < 1)
            disp('Num of empty slots should be at least 1');
        end
        if ~uiData.IsSortingAlgorithm(algorithm_id)
            if uiData.IsSingleAgentAlgorithm(algorithm_id)
                if(num_exiting ~= 1)
                    disp('This is a single agent algorithm');
                end
            end
        end
        if(k + num_exiting > params.m * params.n)
            disp('Not enough cells on the grid');
        end
    end

    function [] = SetDefaultInitValues()
        if uiData.IsSortingAlgorithm(algorithm_id)
            if uiData.AlgorithmVersions(algorithm_id) == 310
                num_exiting = uint32(str2double(rowSize.String)) - 1;
                k = min(k, params.m * params.n - num_exiting);
            end
        else
            if uiData.IsSingleAgentAlgorithm(algorithm_id)
                num_exiting = 1;
                k = params.m * params.n - num_exiting;
            else
                k = 1;
                num_exiting = params.m * params.n - k;
            end
        end
        
        exitingNumber.String = num_exiting;
        emptyNumber.String = k;
    end

    function [] = AsyncInitToggled(source, ~)
         demo_async = source.Value;
         ResetPressed(0, 0);
    end

    function [] = SpeedChanged(source, ~)
        params.pause_for = 0.01 * (1 + source.Max - source.Value);
    end

    function [] = SyncAlgorithm()
		algorithm_version = uiData.AlgorithmVersions(algorithm_id);
    end

    function [] = AdjustAlgorithmVersion()
		SyncAlgorithm();

        if(algorithm_version == 310 && params.m == 2)
            algorithm_id = find(uiData.AlgorithmVersions == 319);
            algorithm_version = 319;
            popupAlgorithmToRun.Value = algorithm_id;
        end
    end

    function [] = CreateAgents()
        use_initial_memory = false;

        AdjustAlgorithmVersion();
        if (uiData.IsSortingAlgorithm(algorithm_id))
            test_versions = 10 * algorithm_version + [1;2];
        else
            test_versions = algorithm_version;
        end

        createAgentFunc_withoutMemory = @(sm) Cylinders.Agent.Agent(sm);
        createAgentFunc_withMemory = @(sm, memory) Cylinders.Agent.Agent(sm, memory);

        if(demo_async)
            async_scheduler = Cylinders.Table.Async_Scheduler(demo_decision_duration, ...
                demo_move_forward_duration, demo_move_sideward_duration);
            table = Cylinders.Table.AsyncTable(grid, params, test_versions, createAgentFunc_withMemory, ...
                @(sm) sm.RequiredVisibility(), async_scheduler, zeros(size(grid)));
        else
            if(use_initial_memory)
                table = Cylinders.Table.Table(grid, params, test_versions, createAgentFunc_withMemory, @(sm) sm.RequiredVisibility(), initial_memory); %#ok<UNRCH>
            else
                table = Cylinders.Table.Table(grid, params, test_versions, createAgentFunc_withoutMemory, @(sm) sm.RequiredVisibility());
            end
        end

        recorder = Recorder.Recorder(params, keep_track_of_last_visits, debug_tempo_spatiality, capture_video, ...
                        frames_per_second, debug_memory_on, update_ui_frequency, continue_to_capture, ...
                        for_at_least_that_much, debug_tempo_spatiality_iterations, debug_tempo_spatiality_skip_iterations, ...
                        debug_tempo_spatiality_scale, max_iterations, stop_on_completion, ...
                        progress_recorders, roadAxes);

        recorder.PreRun(table);
        recorder.PreStep(table);
        % since a child is changed
        roadAxes.Children(1).ButtonDownFcn = @RoadStateToggle;
    end

    function [] = CreateRoad()
        TestCase = Cylinders.Tests.(sprintf('%sTestCase', test_name))(params.n, params.m, k, params);
        grid = params.vehicle_continue * TestCase.CreateGrid(); 

        num_agents = sum(grid ~= params.no_vehicle, 'all');
        where_agents = find(grid);
        grid(where_agents(randsample(num_agents, num_exiting))) = params.vehicle_exit;

        CreateAgents();
    end

    function [] = RunPressed(~, ~)
        stopButton.Value = 0;
        ContinuousRun();
    end

    function [] = StepPressed(~, ~)
        OneStep();
    end

    function [] = ValidateParameters()
        EnsureValidValues();
        
        table_size = params.n * params.m;
        k = max(1, min(k, table_size));
        emptyNumber.String = k;
        
        num_exiting = max(0, min(num_exiting, params.n * params.m - k));
        exitingNumber.String = num_exiting;
    end

    function [] = ResetPressed(~, ~)
        stopButton.Value = 0;
        if(isempty(rowSize.String) || isempty(columnSize.String))
            disp('Error: Row and column should be set');
        else
            params.n = str2double(rowSize.String);
            params.m = str2double(columnSize.String);
            k = str2double(emptyNumber.String);
            num_exiting = str2double(exitingNumber.String);
            ValidateParameters();
            
            availableRoomX = presentationPanel.Position(3) / params.m;
            availableRoomY = presentationPanel.Position(4) / params.n;
            actualAgentSize = min(availableRoomX, availableRoomY);
            roadAxes.Position = [1 - params.m * actualAgentSize 
                0 
                1
                params.n * actualAgentSize];
            roadAxes.OuterPosition = [0 0 1 1];
            roadAxes.Visible = 'on';

            CreateRoad();
        end
    end

    function [adjusted_color] = GetColor()
        adjusted_color = manualColor;
        if ~uiData.IsSortingAlgorithm(algorithm_id)
            if manualColor ~= COLOR_EMPTY
                adjusted_color = COLOR_EXIT;
            end
        end
    end

    function [] = UpdateAgentTypesManually(color, added_value)
        if(color ~= COLOR_EMPTY && added_value < 0)
            if(color == COLOR_EXIT)
                num_exiting = num_exiting - 1;
            end
            k = k + 1;
        end
        if(added_value > 0)
            if(color == COLOR_EXIT)
                num_exiting = num_exiting + 1;
            end
            if(color ~= COLOR_EMPTY)
                k = k - 1;
            end
        end
        emptyNumber.String = k;
        exitingNumber.String = num_exiting;
    end

    function [] = RoadStateToggle(source, value)
        
        [ylim, xlim, ~] = size(source.CData);
        ysize = ylim / params.n;
        xsize = xlim / params.m;
        xindex = uint16(floor(value.IntersectionPoint(1) / xsize)) + 1;
        yindex = uint16(floor(value.IntersectionPoint(2) / ysize)) + 1;
        
        previous_color = grid(yindex, xindex);
        UpdateAgentTypesManually(previous_color, -1);
        
        new_color = GetColor();
        grid(yindex, xindex) = new_color;
        UpdateAgentTypesManually(new_color, 1);
        
        CreateAgents();
    end

    function [stopped] = OneStep()
        stopped = ~recorder.ShouldContinue();
        
        if(~stopped)
            recorder.PreStep(table);

            table.ProcessTimeStep();

            recorder.PostStep(table);
        end  
    end

    function [] = ContinuousRun()
        while (~stopButton.Value)
            stopped = OneStep();
            if(stopped)
                recorder.PostRun(table);
                break;
            end
            pause(params.pause_for);
        end
    end
end

