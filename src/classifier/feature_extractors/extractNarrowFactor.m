function narrowVal = extractNarrowFactor(bw)
% Compute the maximum Feret diameter using the boundary points.
boundaries = bwboundaries(bw);
if isempty(boundaries)
    narrowVal = [];
    return;
end
boundary = boundaries{1};
D = pdist(boundary);
if isempty(D)
    maxFeret = 0;
else
    maxFeret = max(D);
end
L = extractPhysiologicalLength(bw);
if isempty(L) || L == 0
    narrowVal = [];
else
    narrowVal = maxFeret / L;
end
end