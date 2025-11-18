classdef VisibilityBasedPrinterBase < handle
    %VISIBILITYBASEDPRINTERBASE Base calss to provide visibility specific methods
    
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
        % output precision constants
        NO_PRECISION = 0;
        STANDARD_PRECISION = 1;
        DOUBLE_PRECISION = 2;
    end
    
    properties
        agent_visibility;
    end
    
    % non-printing functions
    methods (Access = protected)
        function [visibility] = RequiredVisibility(this)
            visibility = this.agent_visibility;
        end
        
        function [indices] = CreateIndices(~, L1Visibility)
            indices = zeros(2 * L1Visibility + 1);
            % coordinates of the center
            base_row = L1Visibility + 1;
            base_column = L1Visibility + 1;
            % get row/column indices
            [RowInd, ColInd] = ind2sub(size(indices), 1:numel(indices));
            distance = abs(RowInd - base_row) + abs(ColInd - base_column);
            % add base index as a function of distance from center            
            indices(sub2ind(size(indices), RowInd, ColInd)) = ...
                1 + 2 * distance .* (distance - 1);
            % add counter clockwise additions on the base index due to distance from center
            indices(sub2ind(size(indices), RowInd, ColInd)) = ...
                indices(sub2ind(size(indices), RowInd, ColInd)) + ...
                (ColInd >= L1Visibility + 1) .* (RowInd - L1Visibility - 1 + distance) + ...
                (ColInd < L1Visibility + 1) .* (3 * distance + L1Visibility + 1 - RowInd);
            indices(base_row, base_column) = 0;
            indices(indices > 2 * L1Visibility * (L1Visibility + 1) + 1) = 0;
        end
        
        % borders assume diamond-shaped cell readings !!
        % north-east-south-west
        function [borders_on] = GetBorders(~)
            borders_on = [
                    0, 1, 1, 0;
                    0, 0, 1, 1;
                    1, 0, 0, 1;
                    1, 1, 0, 0;
                    0, 0, 1, 0;
                    0, 0, 0, 1;
                    1, 0, 0, 0;
                    0, 1, 0, 0;
                    0, 0, 0, 0;
                ];
        end        
    end
    
    % printing helper function
    methods (Access = protected)
        function [] = Print3_ParametersGeneral(~, printer, parameterBag, commentHeader)
            if(nargin > 3)
                printer.PrintLine(sprintf('%% %s', commentHeader));
            end
            for i=1:size(parameterBag, 1)
                switch(parameterBag{i}{1, 1})
                    case Parameters.PrinterParameters.INT
                        printer.PrintLine(sprintf('\\pgfmathtruncatemacro{\\%s}{%d}%%', parameterBag{i}{1, 2:3}));
                	case Parameters.PrinterParameters.DOUBLE
                        doubleStr = sprintf('\\\\pgfmathsetmacro{\\\\%%s}{%%.%df}%%%%', parameterBag{i}{1, 4});
                        printer.PrintLine(sprintf(doubleStr, parameterBag{i}{1, 2:3}));
                    case Parameters.PrinterParameters.INT_STR
                        printer.PrintLine(sprintf('\\pgfmathtruncatemacro{\\%s}{%s}%%', parameterBag{i}{1, 2:3}));
                    case Parameters.PrinterParameters.DOUBLE_STR
                        printer.PrintLine(sprintf('\\pgfmathsetmacro{\\%s}{%s}%%', parameterBag{i}{1, 2:3}));
                end
            end
        end
        
        function [] = Print3_DirectionValues(~, printer)
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
        end
        
        function [] = Print3_Packages(~, printer)
            printer.PrintLine('\usepackage{amsmath, amssymb}');
            printer.PrintLine('\usepackage{fmtcount}% http://ctan.org/pkg/fmtcount');
            printer.PrintLine('\usetikzlibrary{calc, patterns}');
        end
    end
    
    % print functions
    methods (Access = protected)
        function [] = Print3_Preamble(this, printer)
            printer.PrintLine('\documentclass[tikz]{standalone}');

            printer.PrintEndLine();
           
            this.Print3_Packages(printer);
            
            printer.PrintEndLine();
			
			comment_line(1:40) = '%';
			printer.PrintLine(comment_line);
            printer.PrintLine('%');
            printer.PrintLine('% note, ');
            printer.PrintLine('%	0 - is an empty space; left uncolored');
            printer.PrintLine('%	1 - is an other agent; filled with black');
            printer.PrintLine('%	2 - is an edge; cross-hatched');
            printer.PrintLine('%	3 - is a do not care location');
            printer.PrintLine('%');
			printer.PrintLine(comment_line);
        end
        
        function [] = Print3_ModelParameters(this, printer, needed_bits)
            params = Parameters.PrinterParameters();
            params.AddIntParameter('memory', needed_bits);
            params.AddIntParameter('visibility', this.RequiredVisibility());
            params.AddIntParameter('maxtablelength', 8);
            
            this.Print3_ParametersGeneral(printer, params.GetParameters(), 'model parameters');
        end
        
        function [] = Print3_GetNeighborhoodSizesShort(~, printer)
			printer.PrintLine('% calculate the sizes of the neighborhood');
			printer.BeginCommand('newcommand', '\GetNeighborhoodSizes', '1');
				printer.PrintLine('\xdef\toleft{0}');
				printer.PrintLine('\xdef\todown{0}');
			
				printer.PrintEndLine();

				printer.PrintLine('\pgfmathtruncatemacro{\tableSize}{2 * \visibility + 1}');
				printer.BeginCommand('foreach \columnoffset/\rowoffset[count=\i] in #1 ', '', '');
					printer.BeginlessSection('ifnum\columnoffset<\toleft%', '', '');
						printer.PrintLine('\xdef\toleft{\columnoffset}%');
					printer.EndSection();
					printer.PrintLine('\fi%');
					printer.BeginlessSection('ifnum\rowoffset<\todown%', '', '');
						printer.PrintLine('\xdef\todown{\rowoffset}%');
					printer.EndSection();
					printer.PrintLine('\fi%');
					
					printer.PrintLine('\coordinate (anchor_\i) at (\columnoffset, \rowoffset);');
				printer.EndCommand();
			
				printer.PrintEndLine();

				printer.PrintLine('\xdef\xbase{\toleft}');
				printer.PrintLine('\xdef\ybase{\todown}');
			
				printer.PrintEndLine();

			printer.EndCommand();
        end
        
        function [] = Print3_DrawNeighborhoodFunction(~, printer)
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
								printer.BeginlessSection('ifnum\value=1%', '', '');
									printer.PrintLine('\fill[black!50] (0, 0) rectangle (1, 1);');
								printer.EndSection();
								printer.PrintLine('\fi%');
								printer.BeginlessSection('ifnum\value=2%', '', '');
									printer.BeginSection('scope', '', 'opacity=\opacityfactor, blend group=normal');
    									printer.PrintLine('\draw[pattern=north west lines, draw = none] (0, 0) rectangle (1, 1);');
									printer.EndSection();
								printer.EndSection();
								printer.PrintLine('\fi%');
								printer.BeginlessSection('ifnum\value=3%', '', '');
									printer.BeginSection('scope', '', 'opacity=\opacityfactor');
                                        printer.PrintLine('\node[transform shape] at (0.5, 0.5) {\Large $\mathbf{X}$};');
									printer.EndSection();
								printer.EndSection();
								printer.PrintLine('\fi%');
								printer.PrintLine('\draw (0, 0) rectangle (1, 1);');
							printer.EndSection();
						printer.EndCommand();
					printer.EndSection();
				printer.EndSection();
			printer.EndCommand();
        end
        
        function [] = Print3_TableLocalParameters(this, printer)
            localParameters = Parameters.PrinterParameters();
            
            localParameters.AddIntParameterFromString('currentstate', '#1');
            localParameters.AddIntParameterFromString('tablenum', 'ceil((\currentstate + 1) / \maxtablelength)');
            localParameters.AddIntParameterFromString('columnnum', 'mod(\currentstate, \maxtablelength)');
            
            this.Print3_ParametersGeneral(printer, localParameters.GetParameters(), 'local parameters');
        end
        
        function [] = Print3_DrawAtIndexFunction(this, printer)
			printer.PrintLine('%% set column and table num');
			printer.BeginCommand('newcommand', '\DrawAtIndex', '1');
            
                this.Print3_TableLocalParameters(printer);
				
				printer.PrintEndLine();

				printer.PrintLine('\pgfmathsetmacro{\startoffset}{(1 - \xsize * \scalefactor) / 2}');
				printer.BeginSection('scope', '', 'shift={($(left_upper_corner_\tablenum) + (\columnnum + \startoffset, 0)$)}');
					printer.PrintLine('\DrawNeighborhood{\neighbors}');
				printer.EndSection();
			printer.EndCommand();	
        end

        function [] = Print3_SetTableValuesFunction(this, printer)
			printer.PrintLine('% put values into the table');
			printer.BeginCommand('newcommand', '\SetTableValues', '4');
            
                this.Print3_TableLocalParameters(printer);
				
				printer.PrintEndLine();

                this.Print3_DirectionValues(printer);

                printer.BeginSection('scope', '', 'shift={($(left_upper_corner_\tablenum) + (\columnnum, -#2)$)}');
					printer.PrintLine('\node at (\tiklabelxoffset, \tiklabelyoffset) {\small $\padzeroes[\memory]{\binarynum{#3}}\pickedDirection$};');
				printer.EndSection();
			printer.EndCommand();
        end
        
        function [] = Print3_SetOnlyTableValuesFunction(this, printer)
			printer.PrintLine('% put values into the table');
			printer.BeginCommand('newcommand', '\SetTableValues', '4');
				
				printer.PrintEndLine();

                this.Print3_DirectionValues(printer);

                printer.BeginSection('scope', '', 'shift={(0, -#2)}');
					printer.PrintLine('\node at (\tiklabelxoffset, \tiklabelyoffset) {$\padzeroes[\memory]{\binarynum{#3}}\pickedDirection$};');
				printer.EndSection();
			printer.EndCommand();
        end
        
        function [] = Print3_CommonDrawingParametersFunction(this, printer)
            params = Parameters.PrinterParameters();
            params.AddDoubleParameter('scalefactor', 0.3, Print.VisibilityBasedPrinterBase.STANDARD_PRECISION);
            params.AddDoubleParameter('opacityfactor', 0.7, Print.VisibilityBasedPrinterBase.STANDARD_PRECISION);
            params.AddDoubleParameter('tiklabelxoffset', 0.5, Print.VisibilityBasedPrinterBase.STANDARD_PRECISION);
            params.AddDoubleParameter('tiklabelyoffset', 0.5, Print.VisibilityBasedPrinterBase.STANDARD_PRECISION);
            
            this.Print3_ParametersGeneral(printer, params.GetParameters(), 'drawing parameters');
        end
        
        function [] = Print3_DrawingParametersFunction(this, printer)
            this.Print3_CommonDrawingParametersFunction(printer);

            params = Parameters.PrinterParameters();
            params.AddDoubleParameter('lengthlabelline',	0.8, Print.VisibilityBasedPrinterBase.STANDARD_PRECISION);
            params.AddDoubleParameter('labelxoffset',       0.5, Print.VisibilityBasedPrinterBase.STANDARD_PRECISION);
            params.AddDoubleParameter('labelyoffset',       0.1, Print.VisibilityBasedPrinterBase.STANDARD_PRECISION);
            params.AddDoubleParameter('mintablespace',      0.7, Print.VisibilityBasedPrinterBase.STANDARD_PRECISION);
            params.AddDoubleParameter('cellsize',             1, Print.VisibilityBasedPrinterBase.NO_PRECISION);
            
            this.Print3_ParametersGeneral(printer, params.GetParameters());
        end
        
        function [] = Print3_CommonVariablesFunction(this, printer, number_of_states)
            params = Parameters.PrinterParameters();
            params.AddIntParameter('numberofstates', number_of_states);
            params.AddIntParameterFromString('tableheight', '2^(\memory)');
            params.AddIntParameterFromString('numberoftables', 'ceil(\numberofstates / \maxtablelength)');
            
            this.Print3_ParametersGeneral(printer, params.GetParameters(), 'common code');
        end
        
        
        % function to tweak, if neighborhoods should be different
        function [rows, columns] = Print2_CalculateSensorFunction(this, printer, stateId, state)
            neighbor_amount = 2 * this.RequiredVisibility() * (this.RequiredVisibility() + 1);
            neigh_hit = zeros(neighbor_amount, 1);
            % here comes border cells
            borders_on = this.GetBorders();
            
            lookUpIndices = this.CreateIndices(this.RequiredVisibility());

            [rows, columns] = state.GetNeighborsToTrace();
            neighb_indexes = lookUpIndices(sub2ind(size(lookUpIndices), rows, columns))';
            neigh_hit(neighb_indexes) = 1;
            
            border_ids = find(borders_on(stateId, :)');
            neighb_indexes = [neighb_indexes; border_ids];
            neigh_hit(border_ids) = 1;
            donotcare_ids = find(neigh_hit == 0);
            neighb_indexes = [neighb_indexes; donotcare_ids];
            
            % building neighbor string
            % neigh_coordinates = [0,1; 1,0; 0,-1; -1,0];
            possible_indices = 1:numel(lookUpIndices);
            % extract locations of important cells
            [rs, cs] = ind2sub(size(lookUpIndices), possible_indices(lookUpIndices > 0));
            % adjust, so that an Agent is at (0, 0)
            neigh_coordinates = [cs; rs]' - (this.RequiredVisibility() + 1);
            % change rows sign, since on image it is upside down
            neigh_coordinates(:, 2) =  -neigh_coordinates(:, 2);
            % add sortable column of actual cell numbers
            unsorted_indices = lookUpIndices(possible_indices(lookUpIndices > 0))';
            neigh_coordinates = [neigh_coordinates, unsorted_indices];
            neigh_coordinates = sortrows(neigh_coordinates, 3);
            % print out the result
            neighbors_str = sprintf('%d/%d, ', neigh_coordinates(neighb_indexes, 1:2)');
            neighbors_str = string(extractBetween(neighbors_str, 1, strlength(neighbors_str) - 2));
            
			printer.PrintLine(strcat('\newcommand{\neighborsCoordinates}{', neighbors_str, '}'));
			printer.PrintLine('\newcommand{\neighbors}{}');
			printer.PrintLine('\GetNeighborhoodSizes{\neighborsCoordinates}');
        end
        
        function [] = Print2_GetNeighborhoodSizesFunction(~, printer)
			printer.PrintLine('% calculate the sizes of the neighborhood');
			printer.BeginCommand('newcommand', '\GetNeighborhoodSizes', '1');
				printer.PrintLine('\xdef\toleft{0}');
				printer.PrintLine('\xdef\toright{0}');
				printer.PrintLine('\xdef\toup{0}');
				printer.PrintLine('\xdef\todown{0}');
			
				printer.PrintEndLine();

				printer.PrintLine('\pgfmathtruncatemacro{\tableSize}{2 * \visibility + 1}');
				printer.BeginCommand('foreach \columnoffset/\rowoffset[count=\i] in #1 ', '', '');
					printer.BeginlessSection('ifnum\columnoffset<\toleft%', '', '');
						printer.PrintLine('\xdef\toleft{\columnoffset}%');
					printer.EndSection();
					printer.PrintLine('\fi%');
					printer.BeginlessSection('ifnum\columnoffset>\toright%', '', '');
						printer.PrintLine('\xdef\toright{\columnoffset}%');
					printer.EndSection();
					printer.PrintLine('\fi%');
					printer.BeginlessSection('ifnum\rowoffset<\todown%', '', '');
						printer.PrintLine('\xdef\todown{\rowoffset}%');
					printer.EndSection();
					printer.PrintLine('\fi%');
					printer.BeginlessSection('ifnum\rowoffset>\toup%', '', '');
						printer.PrintLine('\xdef\toup{\rowoffset}%');
					printer.EndSection();
					printer.PrintLine('\fi%');
					
					printer.PrintLine('\coordinate (anchor_\i) at (\columnoffset, \rowoffset);');
				printer.EndCommand();
			
				printer.PrintEndLine();

				printer.PrintLine('\xdef\xbase{\toleft}');
				printer.PrintLine('\xdef\ybase{\todown}');
				printer.PrintLine('\pgfmathtruncatemacro{\pxsize}{\toright - \toleft + 1}');
				printer.PrintLine('\xdef\xsize{\pxsize}');
				printer.PrintLine('\pgfmathtruncatemacro{\pysize}{\toup - \todown + 1}');
				printer.PrintLine('\xdef\ysize{\pysize}');
			
				printer.PrintEndLine();

			printer.EndCommand();
        end
        
        function [readings] = GetSensorReadings(this, handleable_states, rows, stateId, states_in)
            readings = this.ANYTHING * ones(2 * this.RequiredVisibility() * (this.RequiredVisibility() + 1), 1);
            
            specific_reading = handleable_states(states_in) - 1;
            for reading=1:size(rows, 2)
                readings(size(rows, 2) - reading + 1) = mod(specific_reading, Cylinders.Visibility.Constants.Possibilities);
                specific_reading = floor(specific_reading / Cylinders.Visibility.Constants.Possibilities);
            end
            borders_on = this.GetBorders();
            border_ids = find(borders_on(stateId, :)');
            % borders are pushed after actual important readings
            readings(size(rows, 2) + (1:size(border_ids, 1)), 1) = this.BORDER;
        end
        
        function [] = Print2_WriteReadingCommon(this, printer, handleable_states, rows, stateId, states_in, drop_do_not_care)
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
        
        function [] = Print2_WriteOnlyReading(this, printer, handleable_states, rows, stateId, states_in, drop_do_not_care)
            this.Print2_WriteReadingCommon(printer, handleable_states, rows, stateId, states_in, drop_do_not_care);
            printer.PrintLine('\DrawNeighborhood{\neighbors}');
        end
    end
    
    methods
        function obj = VisibilityBasedPrinterBase(visibility)
            obj.agent_visibility = visibility;
        end        
    end
end

