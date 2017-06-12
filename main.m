clear; close all; clc;

%cfig = figure('Position', [10,10,1280,1080]);
cfig = figure(1);

% Lidar parameters
lidar = SetLidarParameters();

% Map parameters
borderSize      = 1;            % m
pixelSize       = 0.2;          % m
miniUpdated     = false;        % 
miniUpdateDT    = 0.1;          % m
miniUpdateDR    = deg2rad(5);   % rad
% If the robot has moved 0.1 m or rotated 5 degree from last key scan, 
% we would add a new key scan and update the map

% Scan matching parameters
fastResolution  = [0.05; 0.05; deg2rad(0.5)]; % [m; m; rad]
bruteResolution = [0.01; 0.01; deg2rad(0.1)]; % not used


% Load lidar data
lidar_data = load('dataset/horizental_lidar.mat');
N = size(lidar_data.timestamps, 1);

% Create an empty map
map.points = [];
map.connections = [];
map.keyscans = [];
pose = [0; 0; 0];
path = pose;

% Here we go!!!!!!!!!!!!!!!!!!!!
for scanIdx = 1 : 1 : N
    
    disp(['scan ', num2str(scanIdx)]);
    
    % Get current scan [x1,y1; x2,y2; ...]
    time = lidar_data.timestamps(scanIdx) * 1e-9;
    scan = ReadAScan(lidar_data, scanIdx, lidar, 24);
    
    % If it's the first scan, initiate
    if scanIdx == 1
        map = Initialize(map, pose, scan);
        miniUpdated = true;
        continue;
    end
    
    % ===== Matching current scan to local map ============
    % 1. If we executed a mini update in last step, we shall update the
    %    local points map and local grid map (coarse)
    if miniUpdated
        localMap = ExtractLocalMap(map.points, pose, scan, borderSize);
        gridMap1 = OccuGrid(localMap, pixelSize);
        gridMap2 = OccuGrid(localMap, pixelSize/2);
    end
    
    % 2. Predict current pose using constant velocity motion model
    if scanIdx > 2
        pose_guess = pose + DiffPose(path(:,end-1), pose);
    else
        pose_guess = pose;
    end
        
    % 3. Fast matching
    if miniUpdated
        [pose, ~] = FastMatch(gridMap1, scan, pose_guess, fastResolution);
    else
        [pose, ~] = FastMatch(gridMap2, scan, pose_guess, fastResolution);
    end
    
    % 4. Refine the pose using smaller pixels
    % gridMap = OccuGrid(localMap, pixelSize/2);
    [pose, hits] = FastMatch(gridMap2, scan, pose, fastResolution/2);
    %----------------------------------------------------------------------
    
    
    % Execute a mini update, if the robot has moved a certain distance
    dp = abs(DiffPose(map.keyscans(end).pose, pose));
    if dp(1)>miniUpdateDT || dp(2)>miniUpdateDT || dp(3)>miniUpdateDR
        miniUpdated = true;
        [map, pose] = AddAKeyScan(map, gridMap2, scan, pose, hits,...
                        pixelSize, bruteResolution, 0.1, deg2rad(3));
    else
        miniUpdated = false;
    end    
    path = [path, pose];      
    
    
    % ===== Loop Closing =========================================
%     if miniUpdated
%         if TryLoopOrNot(map)
%             map.keyscans(end).loopTried = true;
%             map = DetectLoopClosure(map, scan, hits, 4, pi/6, pixelSize);
%         end
%     end
    
    %----------------------------------------------------------------------
    
    % Plot
    if mod(scanIdx, 30) == 0
        PlotMap(cfig, map, path, scan, scanIdx);
    end
    
end

close(cfig);
