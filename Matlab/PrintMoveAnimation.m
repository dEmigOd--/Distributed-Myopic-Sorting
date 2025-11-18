% parameters
n = 6;
m = 4;
k = 7; % number of empty spaces
num_exiting = 5;%n - 1;

test_version = 310;
% supported cases
% Random; Frame; Comb3; TotallyRandom;
% , though come with k
test_name = 'Random';
       
% animated velocity
v = 0.2;
visual_on = true;

capture_video = false;
frames_per_second = 24;
continue_to_capture = true;
for_at_least_that_much = 5; % seconds

debug_memory_on = false;
%debug_frequency = false;
debug_tempo_spatiality = false;
debug_tempo_spatiality_scale = 0.1;
debug_tempo_spatiality_iterations = 2000;
debug_tempo_spatiality_skip_iterations = 2000;
keep_track_of_last_visits = false;
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
% 308 - (1, 3) Sorting algorithm. Two Lane algorithm. Seems to WORK [FOR GREEN ONLY]. And up to n.
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
% 313 - (1, 3) Sorting algorithm. Boosting 310. WORKS. 310.2.1.1 at 3 move West + Revert 310.2.7 to proceed faster East.
%
% 317 - (1, 3) Sorting algorithm. Two Lane algorithm. DOES NOT WORK. And up to n.
%
% 318 - (1, 3) Sorting algorithm. Two Lane algorithm. DOES NOT WORK. And up to n. 317 + removed counter-move on 1->2 lane change
%
% 319 - (1, 3) Sorting algorithm. Two Lane algorithm. Proved to WORK. And up to n. 318 + changed D-bit reset timing in pos 6 and 8
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

max_iterations = 20; % basically forever
stop_on_completion = false; % just do not stop;

pdfWriter = Recorder.PdfRoadRecorder(v);

[problem_solved] = TestMultipleSortingAlgorithm_Runner(n, m, k, num_exiting, test_version, test_name, ...
    visual_on, capture_video, frames_per_second, continue_to_capture, for_at_least_that_much, ...
    debug_memory_on, debug_tempo_spatiality, debug_tempo_spatiality_scale, ...
    debug_tempo_spatiality_iterations, debug_tempo_spatiality_skip_iterations, ...
    keep_track_of_last_visits, update_ui_frequency, pause_between_frames, ...
    read_from_file, filename_agents, filename_memory, ...
    max_iterations, stop_on_completion, ...
    [pdfWriter]);
