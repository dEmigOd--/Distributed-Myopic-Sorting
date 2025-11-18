classdef TabbedPrinter < handle
    %TABBEDPRINTER the printer will automatically add and remove tabs
    
    properties(Constant)
        MAX_SECTIONS = 20;
    end
    
    properties
        tab_num;
        section_names;
        file;
    end
    
    methods (Access = private)
        function [] = ConditionallyPrintString(this, condition, str)
            if(condition)
                this.PrintRawString(str);
            end
        end
        
        function [] = PrintParameters(this, parameterStr, openBrace, closeBrace)
            if(~isempty(parameterStr))
                this.PrintRawString(openBrace);
                this.PrintRawString(parameterStr);
                this.PrintRawString(closeBrace);            
            end
        end
        
        function [] = PrintRequiredParameters(this, parameterStr)
            this.PrintParameters(parameterStr, '{', '}');
        end
        
        function [] = PrintOptionalParameters(this, parameterStr)
            this.PrintParameters(parameterStr, '[', ']');
        end
        
        function [] = BeginGeneralSection(this, sectionName, sectionRequiredParameters, sectionOptionalParameters, sectionFreeParameters, beginRequired, startBlock)
            this.PrintTabs();
            
            this.section_names(this.tab_num + 1, :) = { sectionName, beginRequired };
            
            this.PrintRawString('\');
            this.ConditionallyPrintString(beginRequired, 'begin{');
            this.PrintRawString(sectionName);
            this.ConditionallyPrintString(beginRequired, '}');
            
            this.PrintRequiredParameters(sectionRequiredParameters);
            this.PrintOptionalParameters(sectionOptionalParameters);
            this.ConditionallyPrintString(~isempty(sectionFreeParameters), sectionFreeParameters);
            
            this.ConditionallyPrintString(~isempty(startBlock), startBlock);
            this.PrintEndLine();

            this.BeginIndentation();
        end
        
        function [] = PrintRawString(this, str)
        	fprintf(this.file, '%s', str);
        end
        
        function [] = PrintTabs(this)
            for i=1:this.tab_num
                fprintf(this.file, '\t');
            end
        end        
    end
    
    methods
        function obj = TabbedPrinter()
            obj.tab_num = 0;
            obj.section_names = cell(Print.TabbedPrinter.MAX_SECTIONS, 2);
        end
        
        function [] = OpenFile(this, directory, filename)
            this.file = fopen(sprintf('%s/%s.tex', directory, filename), 'w+'); 
        end
        
        function [] = CloseFile(this)
            if(this.tab_num > 0)
                fprintf('WARNING: Not all open sections ended\n');
            end
            fclose(this.file);
        end
        
        function [] = BeginSection(this, sectionName, sectionRequiredParameters, sectionOptionalParameters)
            this.BeginGeneralSection(sectionName, sectionRequiredParameters, sectionOptionalParameters, '', true, '');
        end
        
        function [] = BeginFreeSection(this, sectionName, sectionFreeParameters)
            this.BeginGeneralSection(sectionName, '', '', sectionFreeParameters, true, '');
        end
        
        function [] = BeginlessSection(this, sectionName, sectionRequiredParameters, sectionOptionalParameters)
            this.BeginGeneralSection(sectionName, sectionRequiredParameters, sectionOptionalParameters, '', false, '');
        end
        
        function [] = BeginCommand(this, commandName, commandRequiredParameters, commandOptionalParameters)
            this.BeginGeneralSection(commandName, commandRequiredParameters, commandOptionalParameters, '', false, '{%');
        end
        
        function [] = BeginIndentation(this)
            this.tab_num = this.tab_num + 1;
        end
        
        function [] = EndIndentation(this)
            this.tab_num = this.tab_num - 1;
        end
        
        function [] = EndCommand(this)
            this.EndSection();
            this.PrintLine('}%');
        end
        
        function [] = EndSection(this)
            this.EndIndentation();
            
            if(this.section_names{this.tab_num + 1, 2})
                this.PrintTabs();

                this.PrintRawString(sprintf('\\end{%s}', this.section_names{this.tab_num + 1, 1}));

                this.PrintEndLine();
            end
        end
        
        function [] = PrintEndLine(this)
        	fprintf(this.file, '\n');
        end
        
        function [] = PrintLine(this, line)
            this.PrintTabs();
            this.PrintRawString(line);
            this.PrintEndLine();
        end
        
    end
end

