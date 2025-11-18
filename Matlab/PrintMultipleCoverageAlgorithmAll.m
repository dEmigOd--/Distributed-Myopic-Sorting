drop_do_not_care = true;

% set one cell entry as figure, all entries in it are subfigures
% version 1;2;3;4
config = {
    {{1,2,3}, {4,6,7,8}, {5}, {9}}, ...
    };
for version =1:4
    Print.MultipleCoveragePrinter.Print(version, config, drop_do_not_care);
end


drop_do_not_care = false;
% version 6;7;8;9
config = {
    {{1,2,3}, {4,5}, {6,7,8}, {9}}, ...
    };
for version = 6:9
    Print.MultipleCoveragePrinter.Print(version, config, drop_do_not_care);
end

% version 101-107
config = {
    {{1,2,3}, {4,5,6}, {7,8,9}}, ...
    };
for version = 101:107
    Print.MultipleCoveragePrinter.Print(version, config, drop_do_not_care);
end

% version 202-203
config = {
    {{1,2,3, 4}, {5,6,8}, {7,9}}, ...
    };
for version = 202:203
    Print.MultipleCoveragePrinter.Print(version, config, drop_do_not_care);
end


%config = {% for version 308
%    {{1,2,4}, {3, 8}, {6}}, ...
%    {{1,2,3}, {4, 6}, {8}}, ...
%    };
%config = {{1,2,3,4}, {5,6, 7}, {8,9}};
%config = {{1},{2,3,4},{5},{6,7,8},{9}};


return;
