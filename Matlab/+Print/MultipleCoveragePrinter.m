classdef MultipleCoveragePrinter
    %MULTIPLECOVERAGEPRINTER Print configs
    
    methods(Static)
        function [] = Print(version, config, drop_do_not_care)
            if(size(config, 1) > 1)
                fprintf('Wrong config supplied\n');
                return;
            end
            
            if (version > 300 && version <= 400)
                multiplier = 10;
                subversions = 1:2;
            else
                multiplier = 1;
                subversions = 0;
            end
                        
            for sv = 1:numel(subversions)
                printer = Print.BaseCylinderPrinter(multiplier * version + subversions(sv));
                printer.Print(config{sv}, drop_do_not_care);
            end
        end
    end
end

