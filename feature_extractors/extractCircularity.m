function circVal = extractCircularity(bw)
% extractCircularity: Computes the roundness/circularity of the object.
% Using the formula: (4*pi*Area)/(Perimeter^2)
%
% Input:
%   bw - binary image containing a single region.
% Output:
%   circVal - scalar value (>=0)

A = extractArea(bw);
P = extractPerimeter(bw);
if isempty(P) || P == 0
    circVal = [];
else
    circVal = (4*pi*A) / (P^2);
end
end
