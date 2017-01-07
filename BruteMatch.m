function [pose, bestHits] = BruteMatch(gridmap, scan, pose,...
                            bruteResolution, tmax, rmax)
% Grid map information
metricMap = gridmap.metricMap;
ipixel = 1 / gridmap.pixelSize;
minX   = gridmap.topLeftCorner(1);
minY   = gridmap.topLeftCorner(2);
nCols  = size(metricMap, 2);
nRows  = size(metricMap, 1);

% Search space                               
xs = pose(1) - tmax : bruteResolution(1) : pose(1) + rmax;
ys = pose(2) - tmax : bruteResolution(2) : pose(2) + rmax;
rs = pose(3) - rmax : bruteResolution(3) : pose(3) + rmax;
nx = length(xs);    ny = length(ys);    nr = length(rs);

% Searching
pixelScan = scan * ipixel;
scores = Inf(nx, ny, nr);
bestScore = Inf;

% Rotation
for ir = 1 : nr
    
    theta = rs(ir);
    ct = cos(theta);
    st = sin(theta);
    S  = pixelScan * [ct, st; -st, ct];
    
    % Translation along x-axis
    for ix = 1 : nx
        
        tx = xs(ix);
        Sx = round(S(:,1)+(tx-minX)*ipixel) + 1;
        
        % Translate along y-axis
        for iy = 1 : ny
            
            ty = ys(iy);
            Sy = round(S(:,2)+(ty-minY)*ipixel) + 1;
            
            % Metric score
            isIn = Sx>1 & Sy>1 & Sx<nCols & Sy<nRows;
            idx  = Sy(isIn) + (Sx(isIn)-1)*nRows;
            hits = metricMap(idx);
            score = sum(hits);
            
            scores(ix, iy, ir) = score;
            
            if score < bestScore
                bestScore = score;
                bestHits = hits;
                pose = [tx; ty; theta];
            end
            
        end  
    end
end
