function [x, y] = extractCentroidCoordinates(bw)
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
