classdef StateMachineRotatePrinter < Print.VisibilityBasedPrinterBase
    %STATEMACHINEROTATEPRINTER print State Machine in -90 deg rotated
    % to save space and present a single table block
    
    properties
        stateMachine;
    end

    methods(Access = protected)
        function [] = Print3_Packages(this, printer)
            
            Print3_Packages@Print.VisibilityBasedPrinterBase(this, printer);
            
            printer.PrintLine('\usepackage{import}');
            printer.PrintLine('\usepackage{standalone}');
        end
    end
    
    methods(Access = private)
        function [valid_memories] = PrintTableParameters(this, printer, ignorable_states)
            max_states = max(cellfun(@(x) x.GetNumberOfStatesRequired(), this.stateMachine), [], 1);
            needed_bits = ceil(log2(max_states));
            
            params = Parameters.PrinterParameters();
            params.AddDoubleParameter('scalevalue', 1, Print.VisibilityBasedPrinterBase.STANDARD_PRECISION);
            params.AddDoubleParameter('partialopacity', 0.4, Print.VisibilityBasedPrinterBase.STANDARD_PRECISION);
            params.AddDoubleParameter('scaleneighborhoods', 0.8 * 3 / (2 * this.agent_visibility + 1), Print.VisibilityBasedPrinterBase.STANDARD_PRECISION);
            params.AddDoubleParameter('adjustdirectionlabel', 0.1, Print.VisibilityBasedPrinterBase.STANDARD_PRECISION);
            params.AddDoubleParameter('headeronescale', 0.5, Print.VisibilityBasedPrinterBase.DOUBLE_PRECISION);
            params.AddDoubleParameter('headertwoscale', 0.37, Print.VisibilityBasedPrinterBase.DOUBLE_PRECISION);

            [memories_cells, ~] = cellfun(@(x) x.GetActions(), this.stateMachine, 'UniformOutput', false);
            valid_memories = any(~ismember(cat(2, memories_cells{:}), ignorable_states), 2);

            params.AddIntParameter('numstates', sum(valid_memories));
            params.AddIntParameter('memwidth', needed_bits);
            
            this.Print3_ParametersGeneral(printer, params.GetParameters(), 'table parameters');
        end
        
        function [] = PrintSetNodeValueFunction(~, printer)
			printer.PrintLine('%% print a single node values at specific location');
            
			printer.BeginCommand('newcommand', '\SetNodeValue', '4');
                printer.BeginSection('scope', '', 'shift={(#1, #2)}');
                    printer.BeginCommand('foreach \pickedDirection[count=\i] in {\uparrow, \rightarrow, \downarrow, \leftarrow, \varnothing}', '', '');
                        printer.BeginlessSection('ifnum#4=\i', '', '');
                            printer.PrintLine('\node[above] at (0, 0) {$\padzeroes[\memwidth]{\binarynum{#3}}$};');
                            printer.PrintLine('\node[below] at (0, {\adjustdirectionlabel * mod(\i, 2)}) {$\pickedDirection$};');
                        printer.EndSection();
                        printer.PrintLine('\fi%');
                    printer.EndCommand();
                printer.EndSection();
            printer.EndCommand();
        end
        
        function [] = PrintStatesTable(this, printer, states_should_be_printed, ignorable_states)
            printer.BeginSection('tikzpicture', '', '');
                
                valid_memories = this.PrintTableParameters(printer, ignorable_states);
                printer.PrintEndLine();
                
                printer.BeginSection('scope', '', 'scale=\scalevalue');
                    printer.BeginSection('scope', '', 'opacity = \partialopacity, transparency group');
                    
                        total_num_of_readings = sum(states_should_be_printed, 1);
                        % draw table with a side column
                        printer.PrintLine(sprintf('\\draw (-1, 0) grid ++(\\numstates + 1, -%d);', total_num_of_readings));
                        % draw header for memory states
                        printer.PrintLine('\draw (0, 0) grid ++(\numstates, 1);');
                        % draw cell for header names
                        printer.PrintLine('\draw (0, 0)   -- ++(-1, 1);');
                    printer.EndSection();              
                    printer.PrintEndLine();                    
                    
                    printer.BeginSection('scope', '', 'shift={(0.5, 0.5)}');
                        valid_memory_index = cumsum(valid_memories) - valid_memories;
                        valid_memories_str = sprintf('%d/%d, ', [valid_memories, valid_memory_index]');
        				printer.BeginCommand(sprintf('foreach \\valid/\\where[count=\\i] in {%s} ', valid_memories_str(1:end-2)), '', '');
                            printer.BeginlessSection('ifnum\valid=1', '', '');
                                printer.PrintLine('\pgfmathtruncatemacro{\memory}{\i-1}');
                                printer.PrintLine('\node at (\where, 0) { $\padzeroes[\memwidth]{\binarynum{\memory}}$};');
                            printer.EndSection();
                            printer.PrintLine('\fi%');
                        printer.EndCommand();
                        printer.PrintEndLine();                    
                    
                        base_position = cumsum(states_should_be_printed);
                        base_position = [0; base_position(1: end-1)];
                        state_readings = sprintf('%d/%d, ', [states_should_be_printed, base_position]');
        				printer.BeginCommand(sprintf('foreach \\reads/\\base[count=\\state] in {%s}', state_readings(1:end-2)), '', '');
                            printer.BeginCommand('foreach \read in {1, ..., \reads}', '', '');
                                printer.PrintLine('\node at (-1, -\base-\read) {\scalebox{\scaleneighborhoods}{\subimport{./}{State_\state.Readings_\read}}};');
                            printer.EndCommand();
                        printer.EndCommand();
 
                        printer.PrintEndLine();                   
                        
                        printer.BeginSection('scope', '', 'shift={(-1, 0)}, rotate=-45, transform shape, font={\large}');
                            printer.PrintLine('\node[scale=\headeronescale, above] at (0, 0) {state};');
                            printer.PrintLine('\node[scale=\headertwoscale, below] at (0, 0) {neighborhood};');
                        printer.EndSection();
                        
                        printer.PrintEndLine();                   

                        baseRow = 0;
                        for stateId = 1:size(this.stateMachine, 1)
                            % write table values
                            [new_memories, actions] = this.stateMachine{stateId}.GetActions();

                            % row entries in actions correspond to different memory states
                            for column = 1:size(actions, 1) % this is a row MATLAB entry
                                for row = 1:size(actions, 2)
                                    if(~ismember(new_memories(column, row), ignorable_states))
                                        printer.PrintLine(sprintf('\\SetNodeValue{%d}{%d}{%d}{%d}', ...
                                            valid_memory_index(column, 1), -(baseRow + row), new_memories(column, row), 1 + actions(column, row)));
                                    end
                                end
                            end
                            baseRow = baseRow + size(actions, 2);
                        end
                        
                    printer.EndSection();
                    
                printer.EndSection();                
                
            printer.EndSection();
        end
        
        function [states_printed] = PrintWithDrawingsInAFolder(this, directory, filename, version, drop_do_not_care, ignorable_states)
            
            [result, ~, ~] = mkdir(directory, sprintf('Ver.%d', version));
            if(~result)
                fprintf('Unable to create directory\n');
                return;
            end
           
            work_directory = sprintf('%s/Ver.%d', directory, version);
            
            printer = Print.TabbedPrinter();
			states_printed = zeros(size(this.stateMachine, 1), 1);
            
            sensorReadingPrinter = Print.SensorReadingPrinter(this.RequiredVisibility());
            for stateId = 1:size(this.stateMachine, 1)
                handleable_states = this.stateMachine{stateId}.GetHandleableStates();
                states_printed(stateId) = size(handleable_states, 1);

                for states_in=1:size(handleable_states, 1)
                    sensorReadingPrinter.PrintSensorReadingFile(...
                        work_directory, handleable_states, stateId, this.stateMachine{stateId}, states_in, drop_do_not_care);
                end
            end

%% File Create            
            printer.OpenFile(work_directory, sprintf('%s%d', filename)); 

%% TEX content 
                this.Print3_Preamble(printer);
                printer.PrintEndLine();

                printer.BeginSection('document', '', '');
                    printer.PrintEndLine();

                    this.PrintSetNodeValueFunction(printer);
                    printer.PrintEndLine();
                    
                    this.PrintStatesTable(printer, states_printed, ignorable_states);
                printer.EndSection();
%% File Close
            printer.CloseFile();
        end
    end
    
    methods
        function obj = StateMachineRotatePrinter(stateMachine, visibility)
            obj=obj@Print.VisibilityBasedPrinterBase(visibility);
            obj.stateMachine = stateMachine;
        end
        
        function [states_printed] = Print(this, directory, filename, version, drop_do_not_care, ignorable_states)
            states_printed = this.PrintWithDrawingsInAFolder(directory, filename, version, drop_do_not_care, ignorable_states);
        end
    end
end

