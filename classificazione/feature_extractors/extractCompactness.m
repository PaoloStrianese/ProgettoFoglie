function compVal = extractCompactness(bw)
% extractCompactness: Computes the compactness of the object.
% One possible definition is: Perimeter / (2*sqrt(pi*Area)).
% (For a perfect circle this value equals 1.)
%
% Input:
%   bw - binary image containing a single region.
% Output:
%   compVal - scalar value (>=0)

A = extractArea(bw);
P = extractPerimeter(bw);
if isempty(A) || A == 0
    compVal = [];
else
    compVal = P / (2 * sqrt(pi*A));
end
end
