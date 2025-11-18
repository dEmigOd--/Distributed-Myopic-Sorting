classdef BaseCylinderPrinter < handle
    %BASECYLINDERPRINTER the basic class to print State Machines of Cylinder package
    
    properties (Access = private)
        sm_version;
        
        printer;
    end
    
    methods (Access = private)
        function success = CreateWorkingDirectories(~)
            success = false;
            [result, ~, ~] = mkdir('./', '+Cylinders');
            if(~result)
                fprintf('Unable to create directory\n');
                return;
            end
            [result, ~, ~] = mkdir('./+Cylinders', 'Tables');
            if(~result)
                fprintf('Unable to create directory\n');
                return;
            end
            
            success = true;
        end
        
        function [] = PrintHeader(this)
            this.printer.PrintLine('\documentclass{article}');

            this.printer.PrintEndLine();

            this.printer.PrintLine('\usepackage{standalone}');
            this.printer.PrintLine('\usepackage{tikz}');
            this.printer.PrintLine('\usepackage{amsmath, amssymb}');
            this.printer.PrintLine('\usepackage{subcaption}');
            this.printer.PrintLine('\usepackage{import}');
            this.printer.PrintLine('\usepackage{fmtcount}');
            this.printer.PrintLine('\usetikzlibrary{calc, patterns, intersections}');

            %this.printer.PrintEndLine();
            %
            %this.printer.PrintLine('\newcommand{\lineinput}[1]{\begingroup\endlinechar=-1 \input{#1}\endgroup}');
           
            this.printer.PrintEndLine();
        end
        
        function [] = PrintSubfigure(this, filename, position, width)
            this.printer.BeginFreeSection('subfigure', sprintf('[b]{%.2f\\textwidth}', width));
            
                this.printer.PrintLine('\centering');
                %this.printer.PrintLine(sprintf('\\lineinput{Ver.%d/%s%d}', this.sm_version, filename, position));
                this.printer.PrintLine(sprintf('\\subimport{Ver.%d/}{%s%d}', this.sm_version, filename, position));
                this.printer.PrintLine(sprintf('\\caption{Position %d}', position));
                this.printer.PrintLine(sprintf('\\label{subfig:fg_%d_%d}', this.sm_version, position));
            
            this.printer.EndSection();
        end
        
        function [] = PrintStateMachineWrapper(this, filename, config, states_printed, first_figure_modifier)
            textwidth = 0.96;
            
            for i=1:size(config, 2)
                % basically we want a special [h] for paper inclusion modifier
                if(i==1)
                    this.printer.BeginSection('figure', '', first_figure_modifier);
                else
                    this.printer.BeginSection('figure', '', '');
                end
                this.printer.PrintLine('\centering');

                page_width = sum(states_printed(cell2mat(config{i}))) + size(config{i}, 2);
                sub_captions = '';
                for j=1:size(config{i}, 2)
                    if j ~= 1
                        this.printer.PrintLine('\hfill');
                        sub_captions = sprintf('%s, ', sub_captions);
                    end
                    % count additional space for memory bit value on the left
                    width = states_printed(config{i}{j}) + 1;
                    % here we setting an actual width proportional to the number of states
                    this.PrintSubfigure(filename, config{i}{j}, width / page_width * textwidth);
                    sub_captions = sprintf('%s(\\subref{subfig:fg_%d_%d}) at position %d', sub_captions, this.sm_version, config{i}{j}, config{i}{j});
                end
                this.printer.PrintLine(sprintf('\\caption{State machine(s) %s.}', sub_captions));
                this.printer.PrintLine(sprintf('\\label{fig:fg_%d_%d}', this.sm_version, i));
                this.printer.EndSection();
            end            
        end
        
        function [] = PrintToFile(this, directory, filename, position_filename, config, states_printed, first_figure_modifier)
            %% TEX content                
            % print one file with all the figures
            this.printer.OpenFile(directory, filename);
            
            this.PrintHeader();
            this.printer.BeginSection('document', '', '');
            this.PrintStateMachineWrapper(position_filename, config, states_printed, first_figure_modifier);
            this.printer.EndSection();
            
            this.printer.CloseFile();
        end
    end
    
    methods
        function obj = BaseCylinderPrinter(version)
            obj.sm_version = version;
            
            obj.printer = Print.TabbedPrinter();
        end
        
        function [] = Print(this, config, drop_do_not_care)
            if(~this.CreateWorkingDirectories())
                return;
            end
            
            % create state machine
            stateMachineCreator = Cylinders.StateMachine.StateMachineCreator();
            state_machine = stateMachineCreator.CreateStateMachine(this.sm_version);
            % print all state machines

            directory = './+Cylinders/Tables';
            filename = sprintf('Table.Ver_%d.Position_', this.sm_version);

            states_printed = state_machine.Print(directory, filename, this.sm_version, drop_do_not_care);

            this.PrintToFile(directory, sprintf('Table.Ver_%d.All', this.sm_version), filename, config, states_printed, '');
            this.PrintToFile(directory, sprintf('Table.Ver_%d.All.Appendix', this.sm_version), filename, config, states_printed, 'ht');
        end
        
        function [] = PrintInOneTable(this, drop_do_not_care)
            if(~this.CreateWorkingDirectories())
                return;
            end
            
            % create state machine
            stateMachineCreator = Cylinders.StateMachine.StateMachineCreator();
            state_machine = stateMachineCreator.CreateStateMachine(this.sm_version);
            % print all state machines

            directory = './+Cylinders/Tables';
            filename = sprintf('Table.Ver_%d.OneTable', this.sm_version);

            state_machine.PrintInOneTable(directory, filename, this.sm_version, drop_do_not_care);
        end
    end
end

