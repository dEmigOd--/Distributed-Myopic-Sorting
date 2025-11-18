classdef StateMachinePrinter1
    % STATEMACHINEPRINTER2 The obsolete State Machine printer with separate tables per 
    % single grid location
    
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
    
    properties
        stateMachine;
        agent_visibility;
    end
    
    methods
        function obj = StateMachinePrinter1(stateMachine, visibility)
            obj.stateMachine = stateMachine;
            obj.agent_visibility = visibility;
        end
        
        function [] = Print(this, directory, filename)
            max_states = max(cellfun(@(x) x.GetNumberOfStatesRequired(), this.stateMachine), [], 1);
            needed_bits = ceil(log2(max_states));
            
            for stateId = 1:size(this.stateMachine, 1)
                file = fopen(sprintf('%s/%s%d.tex', directory, filename, stateId), 'w+'); 
                
                handleable_states = this.stateMachine{stateId}.GetHandleableStates();

%% TEX content                
fprintf(file, '\\documentclass[tikz, border=0.5]{standalone}\n');

fprintf(file, '\n');

fprintf(file, '\\usepackage{tikz}\n');
fprintf(file, '\\usepackage{amsmath}\n');
fprintf(file, '\\usepackage{amssymb}\n');
fprintf(file, '\\usepackage{fmtcount}%% http://ctan.org/pkg/fmtcount\n');
fprintf(file, '\\usetikzlibrary{calc, patterns, intersections}\n');

fprintf(file, '\n');

for i = 1:40
    fprintf(file, '%%');
end
fprintf(file, '\n');
fprintf(file, '%% note, \n');
fprintf(file, '%%	0 - is an empty space; left uncolored\n');
fprintf(file, '%%	1 - is an other agent; filled with black\n');
fprintf(file, '%%	2 - is an edge; cross-hatched\n');
fprintf(file, '%%	3 - is a do not care location; partially opacititated\n');
for i = 1:40
    fprintf(file, '%%');
end
fprintf(file, '\n');

fprintf(file, '\n');

fprintf(file, '\\begin{document}\n');
	
fprintf(file, '\n');

fprintf(file, '%% model parameters\n');
fprintf(file, '\\pgfmathtruncatemacro{\\memory}{%d}\n', needed_bits);
fprintf(file, '\\pgfmathtruncatemacro{\\visibility}{%d}\n', this.RequiredVisibility());
fprintf(file, '\\pgfmathsetmacro{\\maxtablelength}{8}\n');

fprintf(file, '\n');

	fprintf(file, '\t\\newcommand*{\\ExtractCoordinate}[1]{\\path[overlay] (#1); \\pgfgetlastxy{\\XCoord}{\\YCoord}}%%\n');
	
fprintf(file, '\n');

	fprintf(file, '\t%% calculate the sizes of the neighborhood\n');
	fprintf(file, '\t\\newcommand{\\GetNeighborhoodSizes}[1]{%%\n');
		fprintf(file, '\t\t\\xdef\\toleft{0}\n');
		fprintf(file, '\t\t\\xdef\\toright{0}\n');
		fprintf(file, '\t\t\\xdef\\toup{0}\n');
		fprintf(file, '\t\t\\xdef\\todown{0}\n');
		
fprintf(file, '\n');

		fprintf(file, '\t\t\\pgfmathtruncatemacro{\\tableSize}{2 * \\visibility + 1}\n');
		fprintf(file, '\t\t\\foreach \\columnoffset/\\rowoffset[count=\\i] in #1 {%%\n');
			fprintf(file, '\t\t\t\\ifnum\\columnoffset<\\toleft%%\n');
				fprintf(file, '\t\t\t\t\\xdef\\toleft{\\columnoffset}%%\n');
			fprintf(file, '\t\t\t\\fi%%\n');
			fprintf(file, '\t\t\t\\ifnum\\columnoffset>\\toright%%\n');
				fprintf(file, '\t\t\t\t\\xdef\\toright{\\columnoffset}%%\n');
			fprintf(file, '\t\t\t\\fi%%\n');
			fprintf(file, '\t\t\t\\ifnum\\rowoffset<\\todown%%\n');
				fprintf(file, '\t\t\t\t\\xdef\\todown{\\rowoffset}%%\n');
			fprintf(file, '\t\t\t\\fi%%\n');
			fprintf(file, '\t\t\t\\ifnum\\rowoffset>\\toup%%\n');
				fprintf(file, '\t\t\t\t\\xdef\\toup{\\rowoffset}%%\n');
			fprintf(file, '\t\t\t\\fi%%\n');
			
			fprintf(file, '\t\t\t\\coordinate (anchor_\\i) at (\\columnoffset, \\rowoffset);\n');
		fprintf(file, '\t\t}\n');
		
fprintf(file, '\n');

		fprintf(file, '\t\t\\xdef\\xbase{\\toleft}\n');
		fprintf(file, '\t\t\\xdef\\ybase{\\todown}\n');
		fprintf(file, '\t\t\\pgfmathtruncatemacro{\\pxsize}{\\toright - \\toleft + 1}\n');
		fprintf(file, '\t\t\\xdef\\xsize{\\pxsize}\n');
		fprintf(file, '\t\t\\pgfmathtruncatemacro{\\pysize}{\\toup - \\todown + 1}\n');
		fprintf(file, '\t\t\\xdef\\ysize{\\pysize}\n');
		
fprintf(file, '\n');

	fprintf(file, '\t}\n');	
	
fprintf(file, '\n');

	fprintf(file, '\t%% draw this neighborhood\n');
	fprintf(file, '\t\\newcommand{\\DrawNeighborhood}[1]{%%\n');
		fprintf(file, '\t\t\\begin{scope}[shift={(-\\xbase, -\\ybase)}]\n');	
			fprintf(file, '\t\t\t\\draw[fill=black] (0.5, + 0.5) circle (3pt);\n');
			fprintf(file, '\t\t\t\\draw (0, 0) rectangle (1,1);\n');
			
fprintf(file, '\n');

			fprintf(file, '\t\t\t\\foreach \\value[count=\\i] in #1 {%%\n');
				fprintf(file, '\t\t\t\t\\ExtractCoordinate{anchor_\\i}\n');
				fprintf(file, '\t\t\t\t\\begin{scope}[shift={(\\XCoord, \\YCoord)}]\n');
					fprintf(file, '\t\t\t\t\t\\ifnum\\value=0%%\n');
						fprintf(file, '\t\t\t\t\t\t\\draw (0, 0) rectangle (1, 1);\n');
					fprintf(file, '\t\t\t\t\t\\fi%%\n');
					fprintf(file, '\t\t\t\t\t\\ifnum\\value=1%%\n');
						fprintf(file, '\t\t\t\t\t\t\\draw[fill=black!80] (0, 0) rectangle (1, 1);\n');
					fprintf(file, '\t\t\t\t\t\\fi%%\n');
					fprintf(file, '\t\t\t\t\t\\ifnum\\value=2%%\n');
						fprintf(file, '\t\t\t\t\t\t\\draw[pattern=north west lines] (0, 0) rectangle (1, 1);\n');
					fprintf(file, '\t\t\t\t\t\\fi%%\n');
					fprintf(file, '\t\t\t\t\t\\ifnum\\value=3%%\n');
						fprintf(file, '\t\t\t\t\t\t\\draw[fill=black!10] (0, 0) rectangle (1, 1);\n');
						fprintf(file, '\t\t\t\t\t\t\\node at (0.5, 0.5) {\\bf ?};\n');
					fprintf(file, '\t\t\t\t\t\\fi%%\n');
				fprintf(file, '\t\t\t\t\\end{scope}\n');
			fprintf(file, '\t\t\t}\n');
		fprintf(file, '\t\t\\end{scope}\n');
	fprintf(file, '\t}\n');

fprintf(file, '\n');

	fprintf(file, '\t%% set column and table num\n');
	fprintf(file, '\t\\newcommand{\\DrawAtIndex}[1]{%%\n');
		fprintf(file, '\t\t\\pgfmathtruncatemacro{\\currentstate}{#1}\n');
		fprintf(file, '\t\t\\pgfmathtruncatemacro{\\tablenum}{ceil((\\currentstate + 1) / \\maxtablelength)}\n');
		fprintf(file, '\t\t\\pgfmathtruncatemacro{\\columnnum}{mod(\\currentstate, \\maxtablelength)}\n');
        
        fprintf(file, '\n');

		fprintf(file, '\t\t\\pgfmathsetmacro{\\startoffset}{(1 - \\xsize * \\scalefactor) / 2}\n');
		fprintf(file, '\t\t\\begin{scope}[shift={($(left_upper_corner_\\tablenum) + (\\columnnum + \\startoffset, 0)$)}, scale=\\scalefactor]\n');
			fprintf(file, '\t\t\t\\DrawNeighborhood{\\neighbors}\n');
		fprintf(file, '\t\t\\end{scope}\n');
	fprintf(file, '\t}\n');
	
fprintf(file, '\n');

	fprintf(file, '\t%% put values into the table\n');
	fprintf(file, '\t\\newcommand{\\SetTableValues}[4]{\n');
		fprintf(file, '\t\t\\pgfmathtruncatemacro{\\currentstate}{#1}\n');
		fprintf(file, '\t\t\\pgfmathtruncatemacro{\\tablenum}{ceil((\\currentstate + 1) / \\maxtablelength)}\n');
		fprintf(file, '\t\t\\pgfmathtruncatemacro{\\columnnum}{mod(\\currentstate, \\maxtablelength)}\n');
		
fprintf(file, '\n');

		fprintf(file, '\t\t\\xdef\\pickedDirection{\\text{,}}\n');
		fprintf(file, '\t\t\\ifnum#4=0%%\n');
			fprintf(file, '\t\t\t\\xdef\\pickedDirection{\\pickedDirection\\text{N}}%%\n');
		fprintf(file, '\t\t\\fi%%\n');
		fprintf(file, '\t\t\\ifnum#4=1%%\n');
			fprintf(file, '\t\t\t\\xdef\\pickedDirection{\\pickedDirection\\text{E}}%%\n');
		fprintf(file, '\t\t\\fi%%\n');
		fprintf(file, '\t\t\\ifnum#4=2%%\n');
			fprintf(file, '\t\t\t\\xdef\\pickedDirection{\\pickedDirection\\text{S}}%%\n');
		fprintf(file, '\t\t\\fi%%\n');
		fprintf(file, '\t\t\\ifnum#4=3%%\n');
			fprintf(file, '\t\t\t\\xdef\\pickedDirection{\\pickedDirection\\text{W}}%%\n');
		fprintf(file, '\t\t\\fi%%\n');
		fprintf(file, '\t\t\\ifnum#4=4%%\n');
			fprintf(file, '\t\t\t\\xdef\\pickedDirection{\\pickedDirection\\varnothing}%%\n');
		fprintf(file, '\t\t\\fi%%\n');
		fprintf(file, '\t\t\\begin{scope}[shift={($(left_upper_corner_\\tablenum) + (\\columnnum, -#2)$)}]\n');
			fprintf(file, '\t\t\t\\node at (\\tiklabelxoffset, \\tiklabelyoffset) {$\\padzeroes[\\memory]{\\binarynum{#3}}\\pickedDirection$};\n');
		fprintf(file, '\t\t\\end{scope}\n');
	fprintf(file, '\t}\n');
	
fprintf(file, '\n');

	fprintf(file, '\t%% drawing parameters\n');
	fprintf(file, '\t\\pgfmathsetmacro{\\lengthlabelline}{0.8}\n');
	fprintf(file, '\t\\pgfmathsetmacro{\\labelxoffset}{0.5}\n');
	fprintf(file, '\t\\pgfmathsetmacro{\\labelyoffset}{0.1}\n');
	fprintf(file, '\t\\pgfmathsetmacro{\\tiklabelxoffset}{0.5}\n');
	fprintf(file, '\t\\pgfmathsetmacro{\\tiklabelyoffset}{0.5}\n');
	fprintf(file, '\t\\pgfmathsetmacro{\\mintablespace}{0.7}\n');
	fprintf(file, '\t\\pgfmathsetmacro{\\cellsize}{1}\n');
	fprintf(file, '\t\\pgfmathsetmacro{\\scalefactor}{0.4}\n');
	
fprintf(file, '\n');

	fprintf(file, '\t\\begin{tikzpicture}\n');
		fprintf(file, '\t\t%% common code\n');
		fprintf(file, '\t\t\\pgfmathtruncatemacro{\\tableheight}{2^(\\memory)}\n');
		fprintf(file, '\t\t\\pgfmathtruncatemacro{\\numberofstates}{%d}\n', size(handleable_states, 1));
		fprintf(file, '\t\t\\pgfmathtruncatemacro{\\numberoftables}{ceil(\\numberofstates / \\maxtablelength)}\n');
		
fprintf(file, '\n');
        [rows, columns] = this.stateMachine{stateId}.GetNeighborsToTrace();
		fprintf(file, '\t\t\\newcommand{\\neighborsCoordinates}{');
        fprintf(file, '%d/%d', columns(1) - this.RequiredVisibility() - 1, this.RequiredVisibility() + 1 - rows(1));
        if(size(rows, 2) > 1)
            fprintf(file, ', %d/%d', [columns(2:end) - this.RequiredVisibility() - 1; this.RequiredVisibility() + 1 - rows(2:end)]);
        end
        fprintf(file, '}\n');
		fprintf(file, '\t\t\\newcommand{\\neighbors}{}\n');
		fprintf(file, '\t\t\\GetNeighborhoodSizes{\\neighborsCoordinates}\n');
		
fprintf(file, '\n');

		fprintf(file, '\t\t\\begin{scope}[scale=\\cellsize]\n');
			fprintf(file, '\t\t\t%% draw all the tables\n');
			fprintf(file, '\t\t\t\\foreach \\tablenum in {1, ..., \\numberoftables}\n');
			fprintf(file, '\t\t\t{\n');
				fprintf(file, '\t\t\t\t\\pgfmathtruncatemacro{\\tablelength}{ifthenelse(\\tablenum < \\numberoftables, \\maxtablelength, \\numberofstates - (\\numberoftables - 1) * \\maxtablelength)}\n');
				fprintf(file, '\t\t\t\t\\pgfmathsetmacro{\\yoffset}{-(\\tablenum - 1) * (\\tableheight + \\mintablespace + \\scalefactor * \\ysize)}\n');
				
fprintf(file, '\n');

				fprintf(file, '\t\t\t\t\\begin{scope}[yshift=\\yoffset cm]\n');
					fprintf(file, '\t\t\t\t\t\\coordinate (left_upper_corner_\\tablenum) at (0, \\tableheight);\n');
					fprintf(file, '\t\t\t\t\t\\draw (0, 0) grid (\\tablelength, \\tableheight);\n');
					fprintf(file, '\t\t\t\t\t\\begin{scope}[shift={(left_upper_corner_\\tablenum)}]\n');
						fprintf(file, '\t\t\t\t\t\t\\draw (0, 0) -- ++(135:\\lengthlabelline);\n');
						fprintf(file, '\t\t\t\t\t\t\\node[rotate=-45,scale=0.5] at ($(135:\\labelxoffset)+(45:\\labelyoffset)$) {input};\n');
						fprintf(file, '\t\t\t\t\t\t\\node[rotate=-45,scale=0.5] at ($(135:\\labelxoffset)+(180+45:\\labelyoffset)$) {memory};\n');
					fprintf(file, '\t\t\t\t\t\\end{scope}\n');
					fprintf(file, '\t\t\t\t\t\\foreach \\state in { 1, ..., \\tableheight}\n');
					fprintf(file, '\t\t\t\t\t{\n');
						fprintf(file, '\t\t\t\t\t\t\\pgfmathtruncatemacro{\\memorystate}{\\state-1}\n');
						fprintf(file, '\t\t\t\t\t\t\\node (memory_\\tablenum_\\state) at (-1 + \\tiklabelxoffset, \\tableheight - \\state + \\tiklabelyoffset) {$\\padzeroes[\\memory]{\\binarynum{\\memorystate}}$};\n');
					fprintf(file, '\t\t\t\t\t}\n');					
				fprintf(file, '\t\t\t\t\\end{scope}\n');
			fprintf(file, '\t\t\t}\n');
			
fprintf(file, '\n');

            for states_in=1:size(handleable_states, 1)
                fprintf(file, '\t\t\t\\renewcommand{\\neighbors}{');
                readings = zeros(size(rows));
                specific_reading = handleable_states(states_in) - 1;
                for reading=1:size(rows, 2)
                    readings(size(rows, 2) - reading + 1) = mod(specific_reading, Cylinders.Visibility.Constants.Possibilities);
                    specific_reading = floor(specific_reading / Cylinders.Visibility.Constants.Possibilities);
                end
                fprintf(file, '%d', readings(1));
                for reading = 2:size(rows, 2)
                    fprintf(file, ', %d', readings(reading));
                end
                fprintf(file, '}\n');			
                fprintf(file, '\t\t\t\\DrawAtIndex{%d}\n', states_in - 1);
            end
            
fprintf(file, '\n');

            [new_memories, actions] = this.stateMachine{stateId}.GetActions();

            for row = 1:size(actions, 1)
                for column = 1:size(actions, 2)
                    fprintf(file, '\t\t\t\\SetTableValues{%d}{%d}{%d}{%d}\n', column - 1, row, new_memories(row, column), actions(row, column));
                end
            end
            
fprintf(file, '\n');

		fprintf(file, '\t\t\\end{scope}\n');
	fprintf(file, '\t\\end{tikzpicture}\n');
fprintf(file, '\\end{document}\n');
 
%%
                fclose(file);
            end
        end

    end
end

