function rectVal = extractRectangularity(bw)
% extractRectangularity: Computes the rectangularity of the object.
% One possible definition is: (Perimeter^2)/Area.
%
% Input:
%   bw - binary image containing a single region.
% Output:
%   rectVal - scalar value (>=0)

A = extractArea(bw);
P = extractPerimeter(bw);
if isempty(A) || A == 0
    rectVal = [];
else
    rectVal = (P^2) / A;
end
end
