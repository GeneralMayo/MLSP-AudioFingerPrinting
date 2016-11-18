# MLSP-Audio-Fingerprinting-Project
Audio fingerprinting research project for 18-797(MLSP)

Just added 3 separates file ( practice.m ; hashing.m and addressing.m) the practice is like the main code and the hashing is a the function that is returning the addresses of the points ( these address will be used to do the searching) addressing.m is just like a helping function that is beeng used by hashing.m
Let keep in mind here that the returned address is larger than the number of anchors . this is the case because depending on how many point we want in a target zone, each of these point will have an address relative to the a particular anchor. remember a point can be member of multiple target zone ( in this case it will be member of as many target zone as there are number of points in the target zone). the exception for this are the laters point.
I have tried to be descriptive in my code by putting comment.. however yeld to me if something is not clear.
