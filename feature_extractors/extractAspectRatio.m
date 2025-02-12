function aspectVal = extractAspectRatio(bw)
% extractAspectRatio: Computes the aspect ratio of the object.
% Defined as: physiological length / physiological width.
%
% Input:
%   bw - binary image containing a single region.
% Output:
%   aspectVal - scalar value (>=0)

L = extractPhysiologicalLength(bw);
W = extractPhysiologicalWidth(bw);
if isempty(W) || W == 0
    aspectVal = [];
else
    aspectVal = L / W;
end
end
