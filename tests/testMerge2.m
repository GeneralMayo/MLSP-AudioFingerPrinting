global MATCH_THRESHOLD;
MATCH_THRESHOLD = .50;

recordings = cell(1,3);
recordings{1} = [11 ; 12 ; 13 ; 14];
recordings{2} = [21 ; 22];
recordings{3} = [31 ; 32 ; 33 ; 34];

matchMatrix = cell(3);
matchMatrix{1,2} = {.7 1};
matchMatrix{1,3} = {.6 -3};
matchMatrix{2,3} = {.2 2};

[timelines, composition] = merge(matchMatrix,recordings,-1);
assert(isequal(timelines{1},[31 ; 32 ; 33 ; 11 ; 12 ; 13 ; 14]));