function areaVal = extractArea(bw)
% extractArea: Computes the area of the object.
%
% Input:
%   bw - binary image containing a single region.
% Output:
%   areaVal - scalar value (>=0)

stats = regionprops(bw, 'Area');
if isempty(stats)
    areaVal = [];
else
    areaVal = stats.Area;
end
end
