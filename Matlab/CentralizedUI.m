function [ ] = CentralizedUI( uiData, params )
	%CENTRALIZEDUI UI for presenting visual interface for coverage/sorting algorithms 

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
    
    COLOR_EXIT = 1;
    COLOR_CONTINUE = -1;
    COLOR_EMPTY = 0;
    
    defaultColor = COLOR_EMPTY;
    manualColor = COLOR_EMPTY;
    speed = 1;
    %skip = 1;
    iteration = 0;
    
    state = 0;
    covered_state = 0;
    memory = 0;
    
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
   
    %% Create pop-up menu for bases
    popupAlgorithmToRun = uicontrol(controlPanel, ...
       'Style', 'popup',...
       'String', uiData.AlgorithmNames,...
       'Units', 'normalized', ...
       'Position', [controlXOffset + interControlXDistance 
                    controlYOffset + automaticValuesYOffset
                    controlWidth 
                    controlHeight],...
       'Callback', @AlgorithmPicked);     %#ok<NASGU>
	
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
    defaultColoring = uibuttongroup(controlPanel, ...
        'Units', 'normalized', ...
        'Position',[controlXOffset - interControlXDistance - controlWidth
                    controlYOffset - 6 * interControlYDistance 
                    controlWidth 
                    radioButtonGroupYSize], ...
        'Title', 'default coloring', ...
        'SelectionChangedFcn', @DefaultButtonGroupSelectionChange);
    defaultExit = uicontrol(defaultColoring, ...
        'Style', 'radiobutton', ...
        'Units', 'normalized', ...
        'Position',[controlXOffset - interControlXDistance - controlWidth
                    controlYOffset - 1.5 * interControlYDistance 
                    radioButtonXSize 
                    radioButtonGroupYSize], ...
        'Value', 0, ...
        'String', 'Exit'); %#ok<NASGU>
    defaultContinue = uicontrol(defaultColoring, ...
        'Style', 'radiobutton', ...
        'Units', 'normalized', ...
        'Position',[controlXOffset - interControlXDistance - controlWidth
                    controlYOffset - 7 * interControlYDistance 
                    radioButtonXSize 
                    radioButtonGroupYSize], ...
        'Value', 0, ...
        'String', 'Continue'); %#ok<NASGU>
    defaultEmpty = uicontrol(defaultColoring, ...
        'Style', 'radiobutton', ...
        'Units', 'normalized', ...
        'Position',[controlXOffset - interControlXDistance - controlWidth
                    controlYOffset - 12.5 * interControlYDistance 
                    radioButtonXSize 
                    radioButtonGroupYSize], ...
        'Value', 1, ...
        'String', 'Empty'); %#ok<NASGU>
       
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
        'Position',[controlXOffset - interControlXDistance - controlWidth
                    controlYOffset - 7 * interControlYDistance 
                    radioButtonXSize 
                    radioButtonGroupYSize], ...
        'Value', 0, ...
        'String', 'Continue'); %#ok<NASGU>
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
        'String', 8, ...
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
        'String', 6, ...
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

    %% add random initialization controls
    exitingNumber = uicontrol(controlPanel, ...
        'Style','edit',...
        'Units', 'normalized', ...
        'FontSize', 16, ...
        'String', 8, ...
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
        'String', 6, ...
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
    
    randomCheckbox = uicontrol(controlPanel, ...
        'Style', 'checkbox', ...
        'Units', 'normalized', ...
        'Position',[controlXOffset - interControlXDistance
                    slidersYOffset - interControlYDistance
                    controlWidth 
                    0.9 * controlHeight],...
        'Callback', @RandomInitToggled);
    randomCheckboxTxt = uicontrol(controlPanel, ...
        'Style','text',...
        'Units', 'normalized', ...
        'Position',[controlXOffset - interControlXDistance - controlWidth
                    slidersYOffset - 1.2 * interControlYDistance
                    controlWidth 
                    0.9 * controlHeight],...
        'String','Random Init'); %#ok<NASGU>

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
    
%     skipControl = uicontrol(controlPanel, ...
%         'Style','slider', ...
%         'Units', 'normalized', ...
%         'Position',[controlXOffset - interControlXDistance 
%                     slidersYOffset - interControlYDistance
%                     controlWidth + 2 * interControlXDistance
%                     controlHeight],...
%          'value',skip, ...
%          'min',1, ...
%          'max',4);
%     % Add a text uicontrol to label the bases pop-up control.
%     skipTxt = uicontrol(controlPanel, ...
%         'Style','text',...
%         'Units', 'normalized', ...
%         'Position',[controlXOffset - interControlXDistance - controlWidth
%                     slidersYOffset - 1.2 * interControlYDistance
%                     controlWidth 
%                     0.9 * controlHeight],...
%         'String','skip');

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
    
    %%      ----   FUNCTIONS   -----       %%
    %
    %     
    %
    %
    function [] = AlgorithmPicked( source, ~ )
		uiData.Algorithm = source.Value;
        columnSize.Enable = 'on';
        switch uiData.Algorithm
            case 1
                params.coverage_algo_version = 102;
            case 2
                params.coverage_algo_version = 8;
            case 3
                params.coverage_algo_version = 81;
            case 4
                params.coverage_algo_version = 1002;
            case 5
                params.m = 2;
                columnSize.String = params.m;
                columnSize.Enable = 'off';
            case 6
                params.coverage_algo_version = 81;
            case 7
                params.coverage_algo_version = 1004;
        end
        SetDefaultRandomInitValues(randomCheckbox.Value);
    end

    function [] = DefaultButtonGroupSelectionChange( ~, value)
        if(strcmp(value.NewValue.String, 'Exit'))
            defaultColor = COLOR_EXIT; 
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

    function [] = SetDefaultRandomInitValues(toSet)
        if(toSet)
            exitingNumber.Enable = 'on';
            emptyNumber.Enable = 'on';
            emptyNumber.String = 1;
        else
            exitingNumber.Enable = 'off';
            emptyNumber.Enable = 'off';
        end
        switch uiData.Algorithm
            case {1, 2, 3, 4, 7}
                exitingNumber.String = '';
            case {5, 6}
                exitingNumber.String = rowSize.String;
        end
    end

    function [] = RandomInitToggled(source, ~)
        SetDefaultRandomInitValues(source.Value);
    end

    function [] = SpeedChanged(source, ~)
        params.pause_for = 0.01 * source.Value;
    end

    function [] = RunPressed(~, ~)
        stopButton.Value = 0;
        if(StateIsValid())
            ContinuousRun();
        end
    end

    function [] = StepPressed(~, ~)
        if(StateIsValid())
            OneStep();
        end
    end

    function [] = ResetPressed(~, ~)
        stopButton.Value = 0;
        if(isempty(rowSize.String) || isempty(columnSize.String))
            disp('Error: Row and column should be set');
        else
            params.n = str2double(rowSize.String);
            params.m = str2double(columnSize.String);
            
            if(uiData.Algorithm == 6)
                if(params.n == 2)
                    params.sorting_algo_version = 5;
                    params.coverage_algo_version = 0;
                else
                    params.sorting_algo_version = uiData.SortingAlgorithmVersion;
                    params.coverage_algo_version = 81;
                end
            end
            availableRoomX = presentationPanel.Position(3) / params.m;
            availableRoomY = presentationPanel.Position(4) / params.n;
            actualAgentSize = min(availableRoomX, availableRoomY);
            roadAxes.Position = [1 - params.m * actualAgentSize 
                0 
                1
                params.n * actualAgentSize];
            roadAxes.OuterPosition = [0 0 1 1];
            roadAxes.Visible = 'on';

            if(randomCheckbox.Value)
                colorToSet = COLOR_CONTINUE;
            else
                colorToSet = defaultColor;
            end
            state = colorToSet * ones(params.n, params.m);
            if(randomCheckbox.Value)
                if(~isempty(exitingNumber.String))
                    state(randsample(numel(state), str2double(exitingNumber.String))) = COLOR_EXIT;
                end
                numAvailableIndexes = find(state ~= COLOR_EXIT);
                state(numAvailableIndexes(randsample(numel(numAvailableIndexes), str2double(emptyNumber.String)))) = COLOR_EMPTY;
            end
            covered_state = (state == COLOR_EMPTY);
            memory = zeros(params.n, params.m);
            iteration = 0;
            ShowRoad();
        end
    end

    function [] = RoadStateToggle(source, value)
        
        [ylim, xlim, ~] = size(source.CData);
        ysize = ylim / params.n;
        xsize = xlim / params.m;
        xindex = uint16(floor(value.IntersectionPoint(1) / xsize)) + 1;
        yindex = uint16(floor(value.IntersectionPoint(2) / ysize)) + 1;
        state(yindex, xindex) = manualColor;
        covered_state = (state == COLOR_EMPTY);
        ShowRoad();       
    end

    function [] = ShowRoad()
        Show.ShowRoad(roadAxes, state, params);
        roadAxes.Children(1).ButtonDownFcn = @RoadStateToggle;
    end

    function [exiting, continuing, empty] = DetectState()
        exiting = sum(sum(state == COLOR_EXIT));
        continuing = sum(sum(state == COLOR_CONTINUE));
        empty = sum(sum(state == COLOR_EMPTY));
    end

    function [valid] = StateIsValid()
        [exiting, continuing, empty] = DetectState();
        switch uiData.Algorithm
            case {1, 2, 3}
                valid = (((exiting > 0) + (continuing > 0) + (empty > 0)) == 2) && (empty == 1);
            case {4, 7}
                valid = (((exiting > 0) + (continuing > 0) + (empty > 0)) == 2) && (empty > 0);
            case 5
                valid = (empty > 0) && (params.m == 2);
            case 6
                valid = ((empty == 1) && (params.m > 2)) || ((empty >= 1) && (params.n == 2));
        end
        if(~valid)
            disp('State is not valid');
        end
    end

    function [stopped] = OneStep()
        iteration = iteration + 1;
        switch uiData.Algorithm
            case {1, 2, 3}
                [state, memory, collided, stopped] = Snake.SingleCoverageAlgorithm(state, memory, params, iteration);
            case {4, 7}
                [state, memory, collided, stopped] = Rain.MultipleCoverageAlgorithm(state, memory, params);
            case {5, 6}
                [state, memory, collided, stopped] = LittleCircles.ExecuteSortingAlgorithm(state, memory, params);
        end
        if(uiData.Algorithm <= 4 || uiData.Algorithm == 7)
            covered_state = covered_state | (state == COLOR_EMPTY);
            if(any(any(state == COLOR_EXIT)))
                covered_color = COLOR_CONTINUE;
            else
                covered_color = COLOR_EXIT;
            end
            state_to_show = state;
            state_to_show((state ~= COLOR_EMPTY) & covered_state) = covered_color;
            Show.ShowRoad(roadAxes, state_to_show, params);
        else
            Show.ShowRoad(roadAxes, state, params);
        end
        roadAxes.Children(1).ButtonDownFcn = @RoadStateToggle;
        if(stopped)
            fprintf('Algorithm stopped after %d iteration(s)\n', iteration);
        end
        if(collided)
            fprintf('Algorithm stopped due to collision after %d iteration(s)\n', iteration);
            stopped = true;
        end
    end

    function [] = ContinuousRun()
        while (~stopButton.Value)
            stopped = OneStep();
            if(stopped)
                break;
            end
            pause(params.pause_for);
        end
    end
end

