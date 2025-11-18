% parameters
n = 4;
m = 4;
num_frames = [1;2;4];
kmin = 3;
kmax = 5 * max(num_frames) / min(num_frames); % number of empty spaces
max_exiting = 2 * n * max(num_frames) / min(num_frames) - 3; % n - 1

test_version = 310;
% supported cases
% Random; Frame; Comb3; TotallyRandom;
% , though come with k
test_name = 'Random';
        
visual_on = true;
draw_frame = true;
update_ui_frequency = 1;
pause_between_frames = 0.01;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HERE could be done without COLLAPSE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
collapse_road = true;
collapse_frequency = m^2 * n .* (max(num_frames) ./ num_frames);

ks = kmin - 1 + randi((kmax - kmin), 1, num_frames(1));
num_exiting = randi(max_exiting, 1, num_frames(1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Next versions are available in next coding (visibility, bits)
% 9 - (1, 2) version; version 8 patched, but now all columns have this weird two time passage!! MAYBE WORKS.
%
% 307 - (1, 3) Sorting algorithm. Exiting vehicles moves West in all lanes except last, and continuing only in the last. Seems to WORK. And up to n-1.
%
% 308 - (1, 3) Sorting algorithm. Two Lane algorithm. Seems to WORK. And up to n.
%
% 309 - (1, 3) Sorting algorithm. Tweaking 307 (Exit/Continue moves South in different times). Seems to WORK. And up to n-1.
%
% 310 - (1, 3) Sorting algorithm. Tweaking 309 (West direction is prioritized). Proved to WORK. And up to n-1.
%
% 313 - (1, 3) Sorting algorithm. Reverting 310. Possibly WORKING. 310.2.5.2 (Continue, Pos 5, Neighborhood 2) Reverted 4->5 (instead of 4->1)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (collapse_road)
    road = Cylinders.Road.ParallelRoads(n, m, num_frames, ks, num_exiting, test_version, ...
                    test_name, visual_on, draw_frame, update_ui_frequency, pause_between_frames, collapse_frequency);
else
    road = Cylinders.Road.ParallelRoads(n, m, num_frames, ks, num_exiting, test_version, ...
                test_name, visual_on, draw_frame, update_ui_frequency, pause_between_frames);
end

while(true)
    road.Tick();
end

