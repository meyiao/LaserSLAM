%
function [map, pose] = AddAKeyScan(map,...
                                   gridMap,...
                                   scan,... 
                                   pose,... 
                                   hits,...
                                   pixelSize,... 
                                   bruteResolution,... 
                                   tmax,...
                                   rmax)

% First, evaluate the pose & hits, make sure that there is no large error
lastKeyPose = map.keyscans(end).pose;
dp = DiffPose(lastKeyPose, pose);
if abs(dp(1)) > 0.5 || abs(dp(2)) > 0.5 || abs(dp(3)) > pi
    disp('Oh no no no nobody but you : So Large Error!');
    pose = lastKeyPose;
end
   
% ToDo: refine the relative pose, estimate the pose's covariance.
% And push them into the map.connections, which will be neede when we close
% a loop (pose graph optimization).

scan_w = Transform(scan, pose);
newPoints = scan_w(hits>1.1, :);
%
if isempty(newPoints)
    return;
end

% keyscans
k = length(map.keyscans);
map.keyscans(k+1).pose = pose;
map.keyscans(k+1).iBegin = size(map.points, 1) + 1;
map.keyscans(k+1).iEnd = size(map.points, 1) + size(newPoints, 1);
map.keyscans(k+1).loopTried = false;
map.keyscans(k+1).loopClosed = false;

% points
map.points = [map.points; newPoints];

% connections 
% ToDo: Estimate the relative pose and covariance, they will be useful
% when we close a loop (pose graph optimization).
c = length(map.connections);
map.connections(c+1).keyIdPair = [k, k+1];
map.connections(c+1).relativePose = zeros(3,1);
map.connections(c+1).covariance = zeros(3);




