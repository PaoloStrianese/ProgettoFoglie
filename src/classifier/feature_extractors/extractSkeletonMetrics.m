function features = extractSkeletonMetrics(segmentedImg)
    % 1. Robust skeletonization
    binImg = im2gray(segmentedImg) > 0;
    if ndims(binImg) == 2 % Convert to pseudo-3D for Skel2Graph3D
        skel3D = bwskel(binImg > 0, 'MinBranchLength', 10);
        skel3D = reshape(skel3D, [size(binImg) 1]); % Add Z dimension
    else
        skel3D = bwskel(binImg);
    end

    % 2. Branch analysis with error handling
    try
        [~,node,link] = Skel2Graph3D(skel3D, 5); % Threshold=5 to remove artifacts
    catch
        error('Install Skel2Graph3D from: https://github.com/phi-max/skel2graph3d-matlab');
    end

    % 3. Count valid nodes :cite[1]
    numNodi = sum(arrayfun(@(n) length(n.conn) > 2, node)); % Only bifurcation nodes

    % 4. Branch lengths from link structures :cite[5]
    branchLengths = arrayfun(@(l) length(l.point), link);
    avgBranchLength = mean(branchLengths(branchLengths > 5)); % Filter out micro-branches

    % 5. Compute angles based on actual connections :cite[4]
    angles = [];
    for n = node
        if length(n.conn) >= 3 % Only bifurcation nodes
            coords = [node(n.conn).comx; node(n.conn).comy]';
            vecs = coords - repmat([n.comx, n.comy], size(coords,1), 1);
            ang = atan2(vecs(:,2), vecs(:,1));
            ang_diff = diff(sort(ang));
            angles = [angles; ang_diff(ang_diff > 0)];
        end
    end
    avgAngle = rad2deg(mean(angles(~isnan(angles))));

    features = [numNodi, avgBranchLength, avgAngle];
end