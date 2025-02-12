function narrowVal = extractNarrowFactor(bw)
% extractNarrowFactor: Computes the narrow factor of the object.
% Defined as the ratio between the maximum Feret diameter (F1) and the physiological length.
%
% Input:
%   bw - binary image containing a single region.
% Output:
%   narrowVal - scalar value (>=0)

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