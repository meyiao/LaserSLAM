% Fast scan matching, note this may get stuck in local minimas

function [pose, bestHits] = FastMatch(gridmap, scan, pose, searchResolution)

% Grid map information
metricMap = gridmap.metricMap;
ipixel = 1 / gridmap.pixelSize;
minX   = gridmap.topLeftCorner(1);
minY   = gridmap.topLeftCorner(2);
nCols  = size(metricMap, 2);
nRows  = size(metricMap, 1);

% Go down the hill
maxIter = 50;
maxDepth = 3;
iter = 0;
depth = 0;

pixelScan = scan * ipixel;
bestPose  = pose;
bestScore = Inf;
t = searchResolution(1);
r = searchResolution(3);

while iter < maxIter
    noChange = true;
    
    % Rotation
    for theta = pose(3) + [-r, 0, r]
        
        ct = cos(theta);
        st = sin(theta);
        S  = pixelScan * [ct, st; -st, ct];
        
        % Translation
        for tx = pose(1) + [-t, 0, t]
            Sx = round(S(:,1)+(tx-minX)*ipixel) + 1;
            for ty = pose(2) + [-t, 0, t]
                Sy = round(S(:,2)+(ty-minY)*ipixel) + 1;
                
                isIn = Sx>1 & Sy>1 & Sx<nCols & Sy<nRows;
                ix = Sx(isIn);
                iy = Sy(isIn);
                
                % metric socre
                idx = iy + (ix-1)*nRows;
                hits = metricMap(idx);
                score = sum(hits);
                
                % update 
                if score < bestScore
                    noChange  = false;
                    bestPose  = [tx; ty; theta];
                    bestScore = score;
                    bestHits  = hits;
                end
                
            end
        end
    end
    
    % No better match was found, increase resolution
    if noChange
        r = r / 2;
        t = t / 2;
        depth = depth + 1;
        if depth > maxDepth
            break;
        end
    end
    
    pose = bestPose;
    iter = iter + 1;
    
end
    
        
                
                
                
            
        
        