classdef PdfRoadRecorder < Recorder.BaseRecorder
    %PdfRoadRecorder will print few frames of algorithm execution into tex
    
    properties (Constant)
        treeProbability = 0.3;
        subSteps = 20;
    end
    
    properties
        printer;
        
        oldAgents;
        
        leftTrees;
        rightTrees;
        treesCreated;
        
        v;
        distance;
        exitAgents;
    end
    
    methods
        function obj = PdfRoadRecorder(v)
            obj.v = v;
            obj.distance = 0;
        end
        
        function [] = PreRun(obj, table)
            grid = table.GetGrid();
            obj.treesCreated = -size(grid, 1);
            
            obj.printer = Print.AnimationPrinter();
            obj.printer.StartPrint(['RoadAnimation.' datestr(now, 'yyyy-mm-dd-HH-MM-SS')]);
            
            vehicleIndices = (1:numel(grid))';
            vehicleIndices = vehicleIndices(grid(:) ~= Parameters.SimulationParameters.no_vehicle);
            obj.exitAgents = false(sum(grid ~= Parameters.SimulationParameters.no_vehicle, 'all'), 1);
            obj.exitAgents(grid(vehicleIndices) == Parameters.SimulationParameters.vehicle_exit) = true;
            
            % patching first frame
            obj.distance = -obj.v;
            obj.PreStep(table);
            obj.PostStep(table);
        end
        
        function [] = PostRun(obj, table) %#ok<INUSD>
            obj.printer.EndPrint();
        end
        
        function [] = PreStep(obj, table)
            obj.oldAgents = table.GetTrackingInfo();
        end
        
        function [] = PostStep(obj, table)
            newAgents = table.GetTrackingInfo();            
            agentsMoved = any(newAgents ~= obj.oldAgents, 'all');
            
            grid = table.GetGrid();
            dists = (0:size(grid, 1)-1)';
            agentRowIndices = (1:size(newAgents, 1))';
            stepsToExecute = 1 + (obj.subSteps - 1) * agentsMoved;
            
            for i=1:stepsToExecute
                obj.distance = obj.distance + obj.v;

                % update trees positions
                obj.leftTrees = obj.leftTrees + obj.v;
                obj.rightTrees = obj.rightTrees + obj.v;
                if(obj.treesCreated < round(obj.distance, 0))
                    % create new trees
                    newTrees = rand(round(obj.distance, 0) - obj.treesCreated, 2) < obj.treeProbability;
                    % translate decisions into distances
                    nlTrees = [dists(newTrees(:,1)); obj.leftTrees];
                    nrTrees = [dists(newTrees(:,2)); obj.rightTrees];
                    % cut-off invisible trees
                    obj.leftTrees = nlTrees(1:min(size(grid, 1), size(nlTrees, 1)), :);
                    obj.rightTrees = nrTrees(1:min(size(grid, 1), size(nrTrees, 1)), :);
                    obj.treesCreated = round(obj.distance, 0);
                end

                if(stepsToExecute > 1)
                    lambda = 1 - (i - 1) / (stepsToExecute - 1);
                else
                    lambda = 1;
                end
                agentLocations = lambda * obj.oldAgents + (1 - lambda) * newAgents;
                zeroBaseAdjustment = [-1,-1];
                
                obj.printer.PrintFrame(obj.leftTrees, obj.rightTrees, agentLocations(agentRowIndices(obj.exitAgents), :) + zeroBaseAdjustment, ...
                    agentLocations(agentRowIndices(~obj.exitAgents), :) + zeroBaseAdjustment, obj.distance);
            end
        end
    end
end

