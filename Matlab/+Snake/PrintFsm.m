function [ ] = PrintFsm( fsm )
	%PRINTFSM prints fsm to .h file
	% ready to use in CreateFSMTable C++ project
	
    fsmName = class(fsm);
    fsmName = fsmName(7:length(fsmName));
    pwd = mfilename('fullpath');
    fEntry = strfind(pwd, mfilename);
    filename = strcat(pwd(1:fEntry-1), 'C++ Files/', fsmName, '.h');
	fileId = fopen(filename, 'w+');    
	fprintf(fileId, '#pragma once\n');
	fprintf(fileId, '\n');
	fprintf(fileId, '#include "stdafx.h"\n');
	fprintf(fileId, '#include "FSMs.h"\n');
	fprintf(fileId, '\n');
	fprintf(fileId, 'class %s : public FSM\n', fsmName);
    fprintf(fileId, '{\n');
	fprintf(fileId, 'private:\n');
    
    memoryStates = { 'ZeroBit'; 'OneBit'; 'TwoBits'; 'ThreeBits'; 'ErrorBit' };
    directions = { 'North'; 'East'; 'South'; 'West'};
    movements = {'GoNorth'; 'GoEast'; 'GoSouth'; 'GoWest'; 'DoNothing'; 'Error'; 'Stop' };
    
    for memoryState=1:size(memoryStates, 1)
		fprintf(fileId, '\tstatic const BitValue %s = BitValue::%s;\n', memoryStates{memoryState}, memoryStates{memoryState});
    end
    for move=1:size(movements, 1)
		fprintf(fileId, '\tstatic const Movement %s = Movement::%s;\n', movements{move}, movements{move});
    end
    for direction=1:size(directions, 1)
		fprintf(fileId, '\tstatic const Direction %s = Direction::%s;\n', directions{direction}, directions{direction});
    end

	memoryMap = fsm.GetMemoryMap();
    directionMap = fsm.GetDirectionMap();
    bits = log2(size(memoryMap, 1));
    fprintf(fileId, '\n');
        fprintf(fileId, '\tstatic StateFSM<%d>* _GetState(int index)\n', bits);
        fprintf(fileId, '\t{\n');
            fprintf(fileId, '\t\t// send only states from 1 till 9\n');
            fprintf(fileId, '\t\tstatic bool initialized;\n');
            fprintf(fileId, '\t\tstatic std::vector<StateFSM<%d>> states(9);\n', bits);

    fprintf(fileId, '\n');
            fprintf(fileId, '\t\tif (!initialized)\n');
            fprintf(fileId, '\t\t{\n');

    for state = 1:size(memoryMap, 3)
        fprintf(fileId, '\t\t\tstates[%d] = StateFSM<%d>({ ', state - 1, bits);
        for memoryState=1:size(memoryMap, 1)
            if memoryState > 1
                fprintf(fileId, '\t\t\t\t');
            end
            fprintf(fileId, '{ %s, {', memoryStates{memoryState});
            for col = 1:size(memoryMap, 2)
                nextMemValue = memoryMap(memoryState, col, state) + 1;
                if(nextMemValue > size(memoryStates, 1))
                    nextMemValue = size(memoryStates, 1);
                end
                fprintf(fileId, '%s', memoryStates{nextMemValue});
                if(col ~= size(memoryMap, 2))
                    fprintf(fileId, ',');
                end
                fprintf(fileId, ' ');
            end
            fprintf(fileId, '}}');
            if(memoryState == size(memoryMap, 1))
                fprintf(fileId, ' }');
            end
            fprintf(fileId, ',\n');
        end
        for memoryState=1:size(memoryMap, 1)
            fprintf(fileId, '\t\t\t\t');
            if(memoryState == 1)
                fprintf(fileId, '{ ');
            end
            fprintf(fileId, '{ %s, {', memoryStates{memoryState});
            for col = 1:size(directionMap, 2)
                fprintf(fileId, '%s', movements{directionMap(memoryState, col, state) + 1});
                if(col ~= size(directionMap, 2))
                    fprintf(fileId, ',');
                end
                fprintf(fileId, ' ');
            end
            fprintf(fileId, '}}');
            if(memoryState == size(memoryMap, 1))
                fprintf(fileId, ' }');
            end
            fprintf(fileId, ',\n');
        end
        fprintf(fileId, '\t\t\t\t');
        fprintf(fileId, '{');
        noWall = true;
        for col = 1:size(memoryMap, 2)
            if(~any(memoryMap(:, col, state) ~= size(memoryStates, 1)))
                if(~noWall)
                    fprintf(fileId, ',');
                end
                fprintf(fileId, ' %s', directions{col});
                noWall = false;
            end
        end
        fprintf(fileId, ' } );\n');
    end
                fprintf(fileId, '\t\t\tinitialized = true;\n');
            fprintf(fileId, '\t\t}\n');
    fprintf(fileId, '\n');
            fprintf(fileId, '\t\treturn new StateFSM<%d>(states[index - 1]);\n', bits);
        fprintf(fileId, '\t}\n');
    fprintf(fileId, 'public:\n');
        fprintf(fileId, '\tvirtual std::shared_ptr<bStateFSM> GetState(int index) const override\n');
        fprintf(fileId, '\t{\n');
        fprintf(fileId, '\t\treturn std::shared_ptr<bStateFSM>(_GetState(index));\n');
        fprintf(fileId, '\t}\n');
    fprintf(fileId, '};\n');
    
    fclose(fileId);
end

