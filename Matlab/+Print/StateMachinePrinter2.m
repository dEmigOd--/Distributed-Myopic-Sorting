classdef StateMachinePrinter2 < Print.VisibilityBasedPrinterBase
    % STATEMACHINEPRINTER2 The standard State Machine printer with separate tables per 
    % single grid location
    
    properties
        stateMachine;
    end

    % print functions
    methods (Access = private)
        function [] = Print2_DrawNeighborhoodFunction(~, printer)
			printer.PrintLine('\newcommand*{\ExtractCoordinate}[1]{\path[overlay] (#1); \pgfgetlastxy{\XCoord}{\YCoord}}%');
			
			printer.PrintEndLine();

			printer.PrintLine('% draw this neighborhood');
			printer.BeginCommand('newcommand', '\DrawNeighborhood', '1');
				printer.BeginSection('scope', '', 'scale=\scalefactor');	
					printer.BeginSection('scope', '', 'shift={(-\xbase, -\ybase)}');	
						printer.PrintLine('\draw[fill=black] (0.5, 0.5) circle (3pt);');
						printer.PrintLine('\draw (0, 0) rectangle (1,1);');
					
					printer.PrintEndLine();

						printer.BeginCommand('foreach \value[count=\i] in #1 ', '', '');
							printer.PrintLine('\ExtractCoordinate{anchor_\i}');
							printer.BeginSection('scope', '', 'shift={(\XCoord, \YCoord)}');
								printer.BeginlessSection('ifnum\value=0%', '', '');
									printer.PrintLine('\draw (0, 0) rectangle (1, 1);');
								printer.EndSection();
								printer.PrintLine('\fi%');
								printer.BeginlessSection('ifnum\value=1%', '', '');
									printer.PrintLine('\draw[fill=black!50] (0, 0) rectangle (1, 1);');
								printer.EndSection();
								printer.PrintLine('\fi%');
								printer.BeginlessSection('ifnum\value=2%', '', '');
									printer.BeginSection('scope', '', 'opacity=\opacityfactor, blend group=normal');
    									printer.PrintLine('\draw[pattern=north west lines, draw = none] (0, 0) rectangle (1, 1);');
									printer.EndSection();
   									printer.PrintLine('\draw (0, 0) rectangle (1, 1);');
								printer.EndSection();
								printer.PrintLine('\fi%');
								printer.BeginlessSection('ifnum\value=3%', '', '');
									printer.BeginSection('scope', '', 'opacity=\opacityfactor');
                                        printer.PrintLine('\clip (0, 0) rectangle (1, 1);');
                                        printer.PrintLine('\node[transform shape] at (0.5, 0.5) {\Large $\mathbf{X}$};');
									printer.EndSection();
									printer.PrintLine('\draw (0, 0) rectangle (1, 1);');
								printer.EndSection();
								printer.PrintLine('\fi%');
							printer.EndSection();
						printer.EndCommand();
					printer.EndSection();
				printer.EndSection();
			printer.EndCommand();
        end
        
        function [] = Print2_DrawAtIndexFunction(~, printer)
			printer.PrintLine('%% set column and table num');
			printer.BeginCommand('newcommand', '\DrawAtIndex', '1');
				printer.PrintLine('\pgfmathtruncatemacro{\currentstate}{#1}');
				printer.PrintLine('\pgfmathtruncatemacro{\tablenum}{ceil((\currentstate + 1) / \maxtablelength)}');
				printer.PrintLine('\pgfmathtruncatemacro{\columnnum}{mod(\currentstate, \maxtablelength)}');
				
				printer.PrintEndLine();

				printer.PrintLine('\pgfmathsetmacro{\startoffset}{(1 - \xsize * \scalefactor) / 2}');
				printer.BeginSection('scope', '', 'shift={($(left_upper_corner_\tablenum) + (\columnnum + \startoffset, 0)$)}');
					printer.PrintLine('\DrawNeighborhood{\neighbors}');
				printer.EndSection();
			printer.EndCommand();	
        end
        
        function [] = Print2_SetTableValuesFunction(~, printer)
			printer.PrintLine('% put values into the table');
			printer.BeginCommand('newcommand', '\SetTableValues', '4');
				printer.PrintLine('\pgfmathtruncatemacro{\currentstate}{#1}');
				printer.PrintLine('\pgfmathtruncatemacro{\tablenum}{ceil((\currentstate + 1) / \maxtablelength)}');
				printer.PrintLine('\pgfmathtruncatemacro{\columnnum}{mod(\currentstate, \maxtablelength)}');
				
				printer.PrintEndLine();

				printer.PrintLine('\xdef\pickedDirection{\text{,}}');
				printer.BeginlessSection('ifnum#4=0%', '', '');
					printer.PrintLine('\xdef\pickedDirection{\pickedDirection\text{N}}%');
				printer.EndSection();
				printer.PrintLine('\fi%');
				printer.BeginlessSection('ifnum#4=1%', '', '');
					printer.PrintLine('\xdef\pickedDirection{\pickedDirection\text{E}}%');
				printer.EndSection();
				printer.PrintLine('\fi%');
				printer.BeginlessSection('ifnum#4=2%', '', '');
					printer.PrintLine('\xdef\pickedDirection{\pickedDirection\text{S}}%');
				printer.EndSection();
				printer.PrintLine('\fi%');
				printer.BeginlessSection('ifnum#4=3%', '', '');
					printer.PrintLine('\xdef\pickedDirection{\pickedDirection\text{W}}%');
				printer.EndSection();
				printer.PrintLine('\fi%');
				printer.BeginlessSection('ifnum#4=4%', '', '');
					printer.PrintLine('\xdef\pickedDirection{\pickedDirection\varnothing}%');
				printer.EndSection();
				printer.PrintLine('\fi%');
				printer.BeginSection('scope', '', 'shift={($(left_upper_corner_\tablenum) + (\columnnum, -#2)$)}');
					printer.PrintLine('\node at (\tiklabelxoffset, \tiklabelyoffset) {\small $\padzeroes[\memory]{\binarynum{#3}}\pickedDirection$};');
				printer.EndSection();
			printer.EndCommand();
        end
        
        function [] = Print2_SetOnlyTableValuesFunction(~, printer)
			printer.PrintLine('% put values into the table');
			printer.BeginCommand('newcommand', '\SetTableValues', '4');
				
				printer.PrintEndLine();

				printer.PrintLine('\xdef\pickedDirection{\text{,}}');
				printer.BeginlessSection('ifnum#4=0%', '', '');
					printer.PrintLine('\xdef\pickedDirection{\pickedDirection\text{N}}%');
				printer.EndSection();
				printer.PrintLine('\fi%');
				printer.BeginlessSection('ifnum#4=1%', '', '');
					printer.PrintLine('\xdef\pickedDirection{\pickedDirection\text{E}}%');
				printer.EndSection();
				printer.PrintLine('\fi%');
				printer.BeginlessSection('ifnum#4=2%', '', '');
					printer.PrintLine('\xdef\pickedDirection{\pickedDirection\text{S}}%');
				printer.EndSection();
				printer.PrintLine('\fi%');
				printer.BeginlessSection('ifnum#4=3%', '', '');
					printer.PrintLine('\xdef\pickedDirection{\pickedDirection\text{W}}%');
				printer.EndSection();
				printer.PrintLine('\fi%');
				printer.BeginlessSection('ifnum#4=4%', '', '');
					printer.PrintLine('\xdef\pickedDirection{\pickedDirection\varnothing}%');
				printer.EndSection();
				printer.PrintLine('\fi%');
				printer.BeginSection('scope', '', 'shift={(0, -#2)}');
					printer.PrintLine('\node at (\tiklabelxoffset, \tiklabelyoffset) {$\padzeroes[\memory]{\binarynum{#3}}\pickedDirection$};');
				printer.EndSection();
			printer.EndCommand();
        end
        
        function [] = Print4_CommonDrawingParametersFunction(~, printer)
			printer.PrintLine('% drawing parameters');
			printer.PrintLine('\pgfmathsetmacro{\scalefactor}{0.3}%');
			printer.PrintLine('\pgfmathsetmacro{\opacityfactor}{0.7}%');
			printer.PrintLine('\pgfmathsetmacro{\tiklabelxoffset}{0.5}%');
			printer.PrintLine('\pgfmathsetmacro{\tiklabelyoffset}{0.5}%');
        end
        
        function [] = Print4_DrawingParametersFunction(this, printer)
            this.Print2_CommonDrawingParametersFunction(printer);
			printer.PrintLine('\pgfmathsetmacro{\lengthlabelline}{0.8}');
			printer.PrintLine('\pgfmathsetmacro{\labelxoffset}{0.5}');
			printer.PrintLine('\pgfmathsetmacro{\labelyoffset}{0.1}');
			printer.PrintLine('\pgfmathsetmacro{\mintablespace}{0.7}');
			printer.PrintLine('\pgfmathsetmacro{\cellsize}{1}');
        end
        
        function [] = Print4_CommonVariablesFunction(~, printer, number_of_states)
			printer.PrintLine('% common code');
			printer.PrintLine('\pgfmathtruncatemacro{\tableheight}{2^(\memory)}%');
			printer.PrintLine(sprintf('\\pgfmathtruncatemacro{\\numberofstates}{%d}%%', number_of_states));
			printer.PrintLine('\pgfmathtruncatemacro{\numberoftables}{ceil(\numberofstates / \maxtablelength)}%');
        end
        
        function [] = Print2_DrawTables(~, printer)
			printer.PrintLine('% draw all the tables');
			printer.BeginCommand('foreach \tablenum in {1, ..., \numberoftables}', '', '');
				printer.PrintLine('\pgfmathtruncatemacro{\tablelength}{ifthenelse(\tablenum < \numberoftables, \maxtablelength, \numberofstates - (\numberoftables - 1) * \maxtablelength)}%');
				printer.PrintLine('\pgfmathsetmacro{\yoffset}{-(\tablenum - 1) * (\tableheight + \mintablespace + \scalefactor * \ysize)}%');
				
				printer.PrintEndLine();

				printer.BeginSection('scope', '', 'yshift=\yoffset cm');
					printer.PrintLine('\coordinate (left_upper_corner_\tablenum) at (0, \tableheight);');
					printer.PrintLine('\draw (0, 0) grid (\tablelength, \tableheight);');
					printer.BeginSection('scope', '', 'shift={(left_upper_corner_\tablenum)}');
						printer.PrintLine('\draw (0, 0) -- ++(135:\lengthlabelline);');
						printer.PrintLine('\node[rotate=-45,scale=0.5] at ($(135:\labelxoffset)+(45:\labelyoffset)$) {input};');
						printer.PrintLine('\node[rotate=-45,scale=0.5] at ($(135:\labelxoffset)+(180+45:\labelyoffset)$) {memory};');
					printer.EndSection();
					printer.BeginCommand('foreach \state in { 1, ..., \tableheight}', '', '');
						printer.PrintLine('\pgfmathtruncatemacro{\memorystate}{\state-1}');
						printer.PrintLine('\node (memory_\tablenum_\state) at (-1 + \tiklabelxoffset, \tableheight - \state + \tiklabelyoffset) {$\padzeroes[\memory]{\binarynum{\memorystate}}$};');
					printer.EndCommand();
				printer.EndSection();
			printer.EndCommand();
        end
        
        function [] = Print4_WriteReadingCommon(this, printer, handleable_states, rows, stateId, states_in, drop_do_not_care)
            readings = this.GetSensorReadings(handleable_states, rows, stateId, states_in);

            % we can only drop DO NOT CARE outside of visible rectangles
            if(drop_do_not_care)
                % we drop everything outside border indices
                borders_on = this.GetBorders();
                border_ids = find(borders_on(stateId, :)');
                readings = readings(1:size(rows, 2) + size(border_ids, 1));
            end
            
            neighbors_str = sprintf('%d, ', readings);
            neighbors_str = string(extractBetween(neighbors_str, 1, strlength(neighbors_str) - 2));
            printer.PrintLine(strcat('\renewcommand{\neighbors}{', neighbors_str, '}'));
        end
        
        function [] = Print4_WriteOnlyReading(this, printer, handleable_states, rows, stateId, states_in, drop_do_not_care)
            this.Print2_WriteReadingCommon(printer, handleable_states, rows, stateId, states_in, drop_do_not_care);
            printer.PrintLine('\DrawNeighborhood{\neighbors}');
        end
        
        function [] = Print2_WriteReading(this, printer, handleable_states, rows, stateId, states_in, drop_do_not_care)
            this.Print2_WriteReadingCommon(printer, handleable_states, rows, stateId, states_in, drop_do_not_care);
            printer.PrintLine(sprintf('\\DrawAtIndex{%d}', states_in - 1));
        end
		
		function [] = PrintDirectionFile(this, work_directory, stateId, column, needed_bits, new_memories, actions)
            directions_printer = Print.TabbedPrinter();

            directions_printer.OpenFile(work_directory, sprintf('State_%d.Readings_%d.Decisions', stateId, column)); 
			this.Print3_Preamble(directions_printer);

			directions_printer.PrintEndLine();

			directions_printer.BeginSection('document', '', '');

				directions_printer.PrintEndLine();

				this.Print3_ModelParameters(directions_printer, needed_bits);
				directions_printer.PrintEndLine();

				this.Print3_CommonDrawingParametersFunction(directions_printer);
				directions_printer.PrintEndLine();

				this.Print2_SetOnlyTableValuesFunction(directions_printer);                
				directions_printer.PrintEndLine();

				directions_printer.BeginSection('tikzpicture', '', '');

					directions_printer.PrintEndLine();

				for row = 1:size(actions, 1)
					directions_printer.PrintLine(sprintf('\\SetTableValues{%d}{%d}{%d}{%d}\n', column - 1, row, new_memories(row, column), actions(row, column)));
				end
					
					directions_printer.PrintEndLine();

				directions_printer.EndSection();
			directions_printer.EndSection();

			directions_printer.CloseFile();
		end
    end
    
    methods
        function obj = StateMachinePrinter2(stateMachine, visibility)
            obj = obj@Print.VisibilityBasedPrinterBase(visibility);
            obj.stateMachine = stateMachine;
        end
        
        function [states_printed] = PrintWithDrawingsInAFolder(this, directory, filename, version, drop_do_not_care)
            
            [result, ~, ~] = mkdir(directory, sprintf('Ver.%d', version));
            if(~result)
                fprintf('Unable to create directory\n');
                return;
            end
           
            work_directory = sprintf('%s/Ver.%d', directory, version);
            
            max_states = max(cellfun(@(x) x.GetNumberOfStatesRequired(), this.stateMachine), [], 1);
            needed_bits = ceil(log2(max_states));
            
            printer = Print.TabbedPrinter();
			states_printed = zeros(size(this.stateMachine, 1), 1);
            
            for stateId = 1:size(this.stateMachine, 1)
                handleable_states = this.stateMachine{stateId}.GetHandleableStates();
                states_printed(stateId) = size(handleable_states, 1);

                if(~isempty(handleable_states))
                    printer.OpenFile(work_directory, sprintf('%s%d', filename, stateId)); 

%% TEX content 
                    this.Print3_Preamble(printer);
                    printer.PrintEndLine();

                    printer.BeginSection('document', '', '');
                        printer.PrintEndLine();

                        this.Print3_ModelParameters(printer, needed_bits);
                        printer.PrintEndLine();

                        this.Print2_GetNeighborhoodSizesFunction(printer);               
                        printer.PrintEndLine();

                        this.Print2_DrawNeighborhoodFunction(printer);             
                        printer.PrintEndLine();

                        this.Print3_DrawAtIndexFunction(printer);                
                        printer.PrintEndLine();

                        this.Print3_SetTableValuesFunction(printer);                
                        printer.PrintEndLine();

                        this.Print3_DrawingParametersFunction(printer);
                        printer.PrintEndLine();

                        printer.BeginSection('tikzpicture', '', '');

                            this.Print3_CommonVariablesFunction(printer, size(handleable_states, 1));
                            printer.PrintEndLine();

                            [rows, ~] = this.Print2_CalculateSensorFunction(printer, stateId, this.stateMachine{stateId});
                            printer.PrintEndLine();

                            printer.BeginSection('scope', '', 'scale=\cellsize');
                                this.Print2_DrawTables(printer);
                                printer.PrintEndLine();
                                
                                sensorReadingPrinter = Print.SensorReadingPrinter(this.RequiredVisibility());
                                
                                for states_in=1:size(handleable_states, 1)
                                    this.Print2_WriteReading(printer, handleable_states, rows, stateId, states_in, drop_do_not_care);
                                    sensorReadingPrinter.PrintSensorReadingFile(...
                                        work_directory, handleable_states, stateId, this.stateMachine{stateId}, states_in, drop_do_not_care);
                                end
%% Continuation

                                printer.PrintEndLine();

                                % write table values
                                [new_memories, actions] = this.stateMachine{stateId}.GetActions();

                                for row = 1:size(actions, 1)
                                    for column = 1:size(actions, 2)
                                        printer.PrintLine(sprintf('\\SetTableValues{%d}{%d}{%d}{%d}', column - 1, row, new_memories(row, column), actions(row, column)));
                                    end
                                end

%% Standalone Decisions
                    for column = 1:size(actions, 2)
                        this.PrintDirectionFile(work_directory, stateId, column, needed_bits, new_memories, actions);
                    end

                                printer.PrintEndLine();
                            printer.EndSection();
                        printer.EndSection();
                    printer.EndSection();

%%
                    printer.CloseFile();
                end
            end
        end
        
        function [states_printed] = Print(this, directory, filename, version, drop_do_not_care)
            states_printed = this.PrintWithDrawingsInAFolder(directory, filename, version, drop_do_not_care);
        end
        
    end
end

