% parameters
n = 17;
m = 12;
k = 19; % number of empty spaces
num_exiting = 43;%n - 1;

test_version = 302;
test_versions = 10 * test_version + [1;2];
% supported cases
% Random; Frame; Comb3; TotallyRandom;
% , though come with k
test_name = 'Random';
        
visual_on = true;
debug_memory_on = false;
debug_frequency = false;
keep_track_of_last_visits = false;
update_ui_frequency = 1;
pause_between_frames = 0.1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Next versions are available in next coding (visibility, bits)
% 9 - (1, 2) version; version 8 patched, but now all columns have this weird two time passage!! MAYBE WORKS.
%
% 3011/2 - (1, 4) Sorting algorithms
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params = Parameters.SimulationParameters(n, m, visual_on);
params.pause_for = pause_between_frames;

TestCase = Cylinders.Tests.(sprintf('%sTestCase', test_name))(n, m, k, params);
grid = params.vehicle_continue * TestCase.CreateGrid();
num_agents = sum(grid ~= params.no_vehicle, 'all');
where_agents = find(grid);
grid(where_agents(randsample(num_agents, num_exiting))) = params.vehicle_exit;

table = Cylinders.Table.TableWithDisappearence(grid, params, test_versions, @(sm) Cylinders.Agent.Agent(sm), @(sm) sm.RequiredVisibility());

if(params.visual_on)
    clc;
    close all;
    if(keep_track_of_last_visits)
        handl_table = figure('Position', [720 60 1080 900]);
        roadAxes = subplot(1, 2, 1);
        visitsAxes = subplot(1, 2, 2);    
    else
        handl_table = figure('Position', [1260 60 540 900]);
        roadAxes = axes(handl_table, ...        
            'Units', 'normalized', ...
            'Position', [0 0 1 1] ...
        );
    end
end

iteration = 0;
% keep track of empty cell last visits
last_visited = zeros(size(table.GetGrid()));
count_visited = zeros(size(table.GetGrid()));

while(true)
    if(debug_memory_on)
        if(mod(iteration, update_ui_frequency) == 0)
            table.DebugMemory();
        end
    end
    
    if(mod(iteration, update_ui_frequency) == 0)
        Show.ShowRoad(roadAxes, table.GetAsyncGrid(), params);
    end
    
    if(keep_track_of_last_visits)
        last_visited(table.GetGrid() == params.no_vehicle) = iteration;
        count_visited(table.GetGrid() == params.no_vehicle) = count_visited(table.GetGrid() == params.no_vehicle) + 1;
        if(mod(iteration, update_ui_frequency) == 0)
            Show.ShowMultiColoredRoad(visitsAxes, iteration - last_visited, params);
            if(debug_frequency)
                disp(count_visited / iteration);
            end
        end
    end

    iteration = iteration + 1;
    if(debug_memory_on)
        if(mod(iteration, update_ui_frequency) == 0)
            fprintf ('\n\nIteration %d\n', iteration);
        end
    end

    table.ProcessTimeStep();
    
    if(mod(iteration, update_ui_frequency) == 0)
        pause(params.pause_for);
    end
end

