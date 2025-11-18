% parameters
n = 13;
m = 8;
k = 17; % number of empty spaces
num_exiting = n - 1;

test_version = [307;309;310;314;313];
parallel_runs = size(test_version, 1);
% supported cases
% Random; Frame; Comb3; TotallyRandom;
% , though come with k
test_name = 'Random';
        
visual_on = true;
debug_memory_on = false;
%debug_frequency = false;
update_ui_frequency = 1;
pause_between_frames = 0.01;

read_from_file = false;
filename_agents = 'Data/testgrid.txt';
filename_memory = 'Data/testmemory.txt';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Next versions are available in next coding (visibility, bits)
% 9 - (1, 2) version; version 8 patched, but now all columns have this weird two time passage!! MAYBE WORKS.
%
% 301 - (1, 4) Sorting algorithm. Remaining vehicles leaves last lane to the west. Exiting moves to the east if possible. DOES NOT WORK
%
% 302 - (1, 4) Sorting algorithm. 301 + Vehicles can exit to the hidden exiting lane. Seems to WORK.
%
% 303 - (1, 4) Sorting algorithm. 301 + Exiting vehicles now move North-South in last lane. DOES NOT WORK.
%
% 304 - (1, 4) Sorting algorithm. 303 + Exiting vehicles counts to 2 and only then moves east. Seems to NOT WORK. (UpTo pos 7)
%
% 305 - (1, 4) Sorting algorithm. 304 + Count is not reset once you move North-South. DOES NOT WORK. 
%
% 306 - (1, 4) Sorting algorithm. 305 + Solved the edge case of Position 7 with no empty South (after North movement). Seems to NOT WORK.
%
% 307 - (1, 3) Sorting algorithm. Exiting vehicles moves West in all lanes except last, and continuing only in the last. Seems to WORK. And up to n-1.
%
% 308 - (1, 3) Sorting algorithm. Two Lane algorithm. Seems to WORK. And up to n.
%
% 309 - (1, 3) Sorting algorithm. Tweaking 307 (Exit/Continue moves South in different times). Seems to WORK. And up to n-1.
%
% 310 - (1, 3) Sorting algorithm. Tweaking 309 (West direction is prioritized). Proved to WORK. And up to n-1.
%
% 311 - (1, 3/4) Sorting algorithm. Tweaking 306 . DOES NOT WORK, pos 5 EXITING vehicles stuck in Pos 5, move only West.
%
% 312 - (1, 3/4) Sorting algorithm. ?
%
% 313 - (1, 3) Sorting algorithm. Reverting 310. Possibly WORKING. 310.2.5.2 (Continue, Pos 5, Neighborhood 2) Reverted 4->5 (instead of 4->1)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(any(ismember(test_version(1), [307, 309, 310, 313]), 'all') && m == 2)
    test_version(:) = 308;
end
if(test_version(1) == 308 && m > 2)
    test_version(:) = 310;
end
    
test_versions = 10 * test_version + [1,2];

use_initial_memory = false;
if (read_from_file)
    grid = csvread(filename_agents);
    [n, m] = size(grid);
    params = Parameters.SimulationParameters(n, m, visual_on);
    
    if (isfile(filename_memory))
        initial_memory = 4 * csvread(filename_memory);
        if(isequal(size(grid), size(initial_memory)))
            use_initial_memory = true;
        end
    end
else
    params = Parameters.SimulationParameters(n, m, visual_on);
    TestCase = Cylinders.Tests.(sprintf('%sTestCase', test_name))(n, m, k, params);
    grid = params.vehicle_continue * TestCase.CreateGrid(); 
    
    num_agents = sum(grid ~= params.no_vehicle, 'all');
    where_agents = find(grid);
    grid(where_agents(randsample(num_agents, num_exiting))) = params.vehicle_exit;
end
params.pause_for = pause_between_frames;

createAgentFunc_withoutMemory = @(sm) Cylinders.Agent.Agent(sm);
createAgentFunc_withMemory = @(sm, memory) Cylinders.Agent.Agent(sm, memory);

table = cell(parallel_runs, 1);
if(use_initial_memory)
    for i = 1:parallel_runs
        table{i} = Cylinders.Table.Table(grid, params, test_versions(i, :)', createAgentFunc_withMemory, @(sm) sm.RequiredVisibility(), initial_memory);
    end
else
    for i = 1:parallel_runs
        table{i} = Cylinders.Table.Table(grid, params, test_versions(i, :)', createAgentFunc_withoutMemory, @(sm) sm.RequiredVisibility());
    end
end

if(params.visual_on)
    clc;
    close all;
    roadAxes = cell(parallel_runs, 1);
    handl_table = figure('Position', [720 60 1080 900]);
    for i = 1:parallel_runs
        roadAxes{i} = subplot(1, parallel_runs, i);
    end
end

iteration = 0;
problem_solved = false(parallel_runs, 1);

while(true)
    if(debug_memory_on)
        if(mod(iteration, update_ui_frequency) == 0) %#ok<*UNRCH>
            for i = 1:parallel_runs
                table{i}.DebugMemory();
            end
        end
    end
    
    if(mod(iteration, update_ui_frequency) == 0)
        for i = 1:parallel_runs
            Show.ShowRoad(roadAxes{i}, table{i}.GetAsyncGrid(), params);
            title(roadAxes{i}, sprintf('Version %d', test_version(i, 1)));
        end
    end
    
    iteration = iteration + 1;
    if(debug_memory_on)
        if(mod(iteration, update_ui_frequency) == 0)
            fprintf ('\n\nIteration %d\n', iteration);
        end
    end

    for i = 1:parallel_runs
        table{i}.ProcessTimeStep();
    
        vehicles = table{i}.GetGrid() == params.vehicle_exit;
        if ((sum(vehicles(:, end), 1) >= n - 1) && ~problem_solved(i))
            fprintf ('\n\nVersion %d finished at %d (th) iteration\n', test_version(i, 1), iteration);
            problem_solved(i) = true;
        end 
    end
    
    if(mod(iteration, update_ui_frequency) == 0)
        pause(params.pause_for);
    end
end

