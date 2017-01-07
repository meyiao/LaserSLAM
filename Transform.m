function tscan = Transform(scan, pose)

tx = pose(1);
ty = pose(2);
theta = pose(3);

ct = cos(theta);    
st = sin(theta);
R  = [ct, -st; st, ct];

tscan = scan * (R');
tscan(:,1) = tscan(:,1) + tx;
tscan(:,2) = tscan(:,2) + ty;