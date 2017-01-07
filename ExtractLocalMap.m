% Extract a local map around current scan
function localMap = ExtractLocalMap(points, pose, scan, borderSize)

% Transform current scan into world frame
scan_w = Transform(scan, pose);

% Set top-left & bottom-right corner
minX = min(scan_w(:,1) - borderSize);
minY = min(scan_w(:,2) - borderSize);
maxX = max(scan_w(:,1) + borderSize);
maxY = max(scan_w(:,2) + borderSize);

% Extract
isAround = points(:,1) > minX...
         & points(:,1) < maxX...
         & points(:,2) > minY...
         & points(:,2) < maxY;

localMap = points(isAround, :);