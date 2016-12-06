global MATCH_THRESHOLD;
MATCH_THRESHOLD = .50;

recordings = cell(1,4);
recordings{1} = [11 ; 12 ; 13 ; 14];
recordings{2} = [21 ; 22];
recordings{3} = [31 ; 32 ; 33 ; 34];
recordings{4} = [41 ; 42 ; 43];

matchMatrix = cell(3);
matchMatrix{1,2} = {.6 3};
matchMatrix{1,3} = {.1 -3};
matchMatrix{1,4} = {.2 -1};
matchMatrix{2,3} = {.1 -3};
matchMatrix{2,4} = {.1 -1};
matchMatrix{3,4} = {.55 -2};

[timelines, composition] = merge(matchMatrix,recordings);
assert(isequal(timelines{1},[11 ; 12 ; 13 ; 14 ; 22]));
assert(isequal(timelines{2},[41 ; 42 ; 31 ; 32 ; 33 ; 34]));