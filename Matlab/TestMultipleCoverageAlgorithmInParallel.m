% parameters
n = 10;
m = 11;
% do not change k or test version
k = 1; % number of empty spaces
test_version_right = 202;
test_version_left = 203;%102;

% supported cases
% Random;
% SpecificOmmisions, though come with k
test_name = 'Random';
        
debug_memory_on = false;
debug_frequency = false;
update_ui_frequency = 1;

pause_between_frames = 0.01;

if(test_version_right == 202 && test_version_left == 102)
    test_class = 'Testv102v202';
else
    test_class = 'TestInParallel';
end

test = Test.MultipleCoverage.(test_class)(n, m, test_name, debug_memory_on, debug_frequency, update_ui_frequency, pause_between_frames, ...
    test_version_left, test_version_right, k);

test.RunTest();
