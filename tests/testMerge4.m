global MATCH_THRESHOLD;
MATCH_THRESHOLD = .50;

recordings = cell(1,3);
recordings{1} = [11 ; 12 ; 13 ; 14];
recordings{2} = [21 ; 22];
recordings{3} = [31 ; 32 ; 33 ; 34];

matchMatrix = cell(3);
matchMatrix{1,2} = {.6 1};
matchMatrix{1,3} = {.1 -3};
matchMatrix{2,3} = {.7 -3};

[timelines, composition] = merge(matchMatrix,recordings);
assert(isequal(timelines{1},[31 ; 32 ; 33 ; 21 ; 22 ; 14]));