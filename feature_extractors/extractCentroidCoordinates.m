function [x, y] = extractCentroidCoordinates(bw)
% extractCentroidCoordinates: Computes the centroid coordinates (x and y) of the object.
%
% Input:
%   bw - binary image containing a single region.
% Output:
%   x - x-coordinate of the centroid.
%   y - y-coordinate of the centroid.

stats = regionprops(bw, 'Centroid');
if isempty(stats)
    x = [];
    y = [];
else
    centroid = stats.Centroid;
    x = centroid(1);
    y = centroid(2);
end
end
