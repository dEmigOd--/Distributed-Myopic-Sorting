% Seems Like exporting to csv then calling Algorithm310x project to test
%test_versions = [307;309;310;313;314;315;316]';
test_versions = [1]';

for version = test_versions

    if (version > 300 && version <= 400)
        multiplier = 10;
        subVersion = 1:2;
    else
        multiplier = 1;
        subVersion = 0;
    end

    for sv = 1:numel(subVersion)
        % create state machine
        stateMachineCreator = Cylinders.StateMachine.StateMachineCreator();
        state_machine = stateMachineCreator.CreateStateMachine(multiplier * version + subVersion(sv));

        state_machine.ExportData('+Cylinders/Data', version, subVersion(sv));
    end
end
