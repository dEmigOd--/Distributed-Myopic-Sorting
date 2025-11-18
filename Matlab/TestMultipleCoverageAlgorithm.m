% parameters
n = 6;
m = 9;
k = 7;%(n * m - 1); % number of empty spaces

test_version = 9; % for versions 100 make sure all except 1 are empty
% supported cases
% Random; Frame; Comb3; TotallyRandom;
% SpecificOmmisions, though come with k
test_name = 'Random';
%test_name = 'SpecificOmmisions';

filename_agents = 'Data/testgrid.20220323.txt';
filename_animation = 'Grid.MultiCoverage.Ver.1';

visual_on = true;
debug_memory_on = false;
debug_frequency = false;
keep_track_of_last_visits = false;
update_ui_frequency = 1;
pause_between_frames = 0.1;

if (floor(test_version / 100) == 2)
    k = n * m - k;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Next versions are available in next coding (visibility, bits)
% 0 - first try with (2, 2); manual next state. NOT WORKING
%
% 1 - (2, 2); 1 bit for timer, 1 - for state 5,9 direction. WORKS
%
% 2 - (2, 2); rebranded ver 1; now north direction is 0-valued, to not have state 2 support state 10 !!; MAYBE WORKS - have unusual side effects in
% first cycle !! The rightmost empty cell skips columns and to the cycle.
%
% 3 - IS ver 1 (2, 2) + SPEEDUP, i.e. if no collision is possible movement is possible out-of-sync (i.e. north bound on even times); PROBABLY WORKS as
% ver 1.
%
% 4 - IS ver 2 (2, 2) - with filled in missing actions (i.e. to let the agents start with arbitrary state bit)
%
% 5 - First try with (1, 3); NOT WORKING
%
% 6 - (1, 3) version; 2 LSB for timer; with full split between direction movement. state 9 could move into state 7 !! MAYBE WORKS.
%
% 7 - (1, 2) version; LSB for timer; with NW-SE split between direction movement. state 9 could move into state 7 !! NOT WORKING on 3 x m grids.
%
% 8 - (1, 2) version; version 7 patched, so no agent is stuck in (2, n-1) on 3 row grids!! MAYBE WORKS.
% double traversal of n-1 column on the first passage ??
%
% 9 - (1, 2) version; version 8 patched, but now all columns have this weird two time passage!! NOT WORKING on 3 x m grids.
%
%
% ALL 1xx versions run for a SINGLE agent algorithms
%
% 102 - (1, 1) dual version. Single agent algorithm for covering, WORKS
%
% 108 - (2, 5) a self-learned Hamiltonian circuit following algorithm
%
% 202 - (1, 2) primal trial for version 102, WORKS!! (meaning following 102
% path, works always otherwise)
% 203 - (1, 2). Kind of 202, but does not hit the first row while traversing the columns. NOT WORKING on 3 x m grids
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(strcmp(test_name, 'SpecificOmmisions'))
%     kSpecificOmmisions202 = [n, m-1];
%     grid102 = ones(n, m);
%     grid102(sub2ind([n, m], kSpecificOmmisions202(:, 1), kSpecificOmmisions202(:, 2))) = 0;
%     [I, J] = ind2sub([n, m], find(grid102));
%     kSpecificOmmisions102 = [I, J];
%     k = kSpecificOmmisions102;
    grid = csvread(filename_agents);
    [n, m] = size(grid);
    [I, J] = ind2sub([n, m], find(grid == 0));
    k = [I, J];
end

params = Parameters.SimulationParameters(n, m, visual_on);
params.pause_for = pause_between_frames;

TestCase = Cylinders.Tests.(sprintf('%sTestCase', test_name))(n, m, k, params);
grid = TestCase.CreateGrid();

table = Cylinders.Table.Table(grid, params, test_version, @(sm) Cylinders.Agent.Agent(sm), @(sm) sm.RequiredVisibility());

% just a list of parameters
debug_tempo_spatiality = false;
capture_video = false; 
frames_per_second = 3;
continue_to_capture = false;
for_at_least_that_much = 0;
debug_tempo_spatiality_iterations = 0;
debug_tempo_spatiality_skip_iterations = 0;
debug_tempo_spatiality_scale = 1;
max_iterations = 100000;
stop_on_completion = false;

progress_recorders = [];%[Recorder.GridRecorder(n, m, filename_animation, 'grid.agents.common', frames_per_second)];

clc;
close all;

recorder = Recorder.Recorder(params, keep_track_of_last_visits, debug_tempo_spatiality, capture_video, ...
                frames_per_second, debug_memory_on, update_ui_frequency, continue_to_capture, ...
                for_at_least_that_much, debug_tempo_spatiality_iterations, debug_tempo_spatiality_skip_iterations, ...
                debug_tempo_spatiality_scale, max_iterations, stop_on_completion, ...
                progress_recorders);

recorder.PreRun(table);

while(recorder.ShouldContinue())
    recorder.PreStep(table);

    table.ProcessTimeStep();

    recorder.PostStep(table);
end  

recorder.PostRun(table);

problem_solved = recorder.ProblemSolved();

% if(params.visual_on)
%     clc;
%     close all;
%     if(keep_track_of_last_visits)
%         handl_table = figure('Position', [720 60 1080 900]);
%         roadAxes = subplot(1, 2, 1);
%         visitsAxes = subplot(1, 2, 2);    
%     else
%         handl_table = figure('Position', [1260 60 540 900]);
%         roadAxes = axes(handl_table, ...        
%             'Units', 'normalized', ...
%             'Position', [0 0 1 1] ...
%         );
%     end
% end
% 
% iteration = 0;
% % keep track of empty cell last visits
% last_visited = zeros(size(table.GetGrid()));
% count_visited = zeros(size(table.GetGrid()));
% 
% while(true)
%     if(debug_memory_on)
%         if(mod(iteration, update_ui_frequency) == 0)
%             table.DebugMemory();
%         end
%     end
%     
%     if(mod(iteration, update_ui_frequency) == 0)
%         Show.ShowRoad(roadAxes, table.GetAsyncGrid(), params);
%     end
%     
%     if(keep_track_of_last_visits)
%         last_visited(table.GetGrid() == params.no_vehicle) = iteration;
%         count_visited(table.GetGrid() == params.no_vehicle) = count_visited(table.GetGrid() == params.no_vehicle) + 1;
%         if(mod(iteration, update_ui_frequency) == 0)
%             Show.ShowMultiColoredRoad(visitsAxes, iteration - last_visited, params);
%             if(debug_frequency)
%                 disp(count_visited / iteration);
%             end
%         end
%     end
% 
%     iteration = iteration + 1;
%     if(debug_memory_on)
%         if(mod(iteration, update_ui_frequency) == 0)
%             fprintf ('\n\nIteration %d\n', iteration);
%         end
%     end
% 
%     table.ProcessTimeStep();
%     
%     if(mod(iteration, update_ui_frequency) == 0)
%         pause(params.pause_for);
%     end
% end

