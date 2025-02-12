function perimVal = extractPerimeter(bw)
% extractPerimeter: Computes the perimeter of the object.
%
% Input:
%   bw - binary image containing a single region.
% Output:
%   perimVal - scalar value (>=0)

stats = regionprops(bw, 'Perimeter');
if isempty(stats)
    perimVal = [];
else
    perimVal = stats.Perimeter;
end
end