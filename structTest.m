xxx = struct('elem1',struct('elem11',1,'elem12',2));
xxx.('elem2') = struct('elem21',1,'elem22',2,'elem23',3);
elem1Xs = xxx.elem1;
elem1Xs.elem11 = elem1Xs.elem11+1;
elem1Xs.elem11
xxx.elem1.elem11

