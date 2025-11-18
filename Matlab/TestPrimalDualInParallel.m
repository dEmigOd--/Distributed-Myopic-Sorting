% parameters
n = 7;
m = 6;
% do not change k or test version
k = 1; % number of empty spaces
test_version_left = 105;
test_version_right = test_version_left;

% supported cases
% Random;
% SpecificOmmisions, though come with k
test_name = 'Random';
        
debug_memory_on = false;
debug_frequency = false;
update_ui_frequency = 1;

pause_between_frames = 0.01;

test_class = 'TestPrimalDualInParallel';

test = Test.MultipleCoverage.(test_class)(n, m, test_name, debug_memory_on, debug_frequency, update_ui_frequency, pause_between_frames, ...
    test_version_left, test_version_right, k);

test.RunTest();
