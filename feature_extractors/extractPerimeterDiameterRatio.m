function ratioVal = extractPerimeterDiameterRatio(bw)
% extractPerimeterDiameterRatio: Computes the ratio between the perimeter and the equivalent diameter.
% The equivalent diameter is computed as: 2*sqrt(Area/pi)
%
% Input:
%   bw - binary image containing a single region.
% Output:
%   ratioVal - scalar value (>=0)

A = extractArea(bw);
P = extractPerimeter(bw);
if isempty(A) || A == 0
    ratioVal = [];
else
    equivDiameter = 2 * sqrt(A/pi);
    ratioVal = P / equivDiameter;
end
end
