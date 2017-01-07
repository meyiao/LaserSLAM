function map = Initialize(map, pose, scan)

% Points in world frame
map.points = Transform(scan, pose);

% Key scans' information
k = length(map.keyscans);
map.keyscans(k+1).pose = pose;
map.keyscans(k+1).iBegin = 1;
map.keyscans(k+1).iEnd = size(scan, 1);
map.keyscans(k+1).loopClosed = true;
map.keyscans(k+1).loopTried = false;