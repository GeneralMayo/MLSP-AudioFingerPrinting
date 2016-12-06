global MATCH_THRESHOLD;
MATCH_THRESHOLD = .50;

recordings = cell(1,4);
recordings{1} = [11 ; 12 ; 13 ; 14];
recordings{2} = [21 ; 22];
recordings{3} = [31 ; 32 ; 33 ; 34];
recordings{4} = [41 ; 42 ; 43 ; 44];

matchMatrix = cell(3);
matchMatrix{1,2} = {.59 3};
matchMatrix{1,3} = {.1 -3};
matchMatrix{1,4} = {.2 -1};
matchMatrix{2,3} = {.58 -1};
matchMatrix{2,4} = {.2 2};
matchMatrix{3,4} = {.60 -3};

[timelines, composition] = merge(matchMatrix,recordings);
assert(isequal(timelines{1},[41 ; 11 ; 12 ; 13 ; 14 ; 22 ; 34]));