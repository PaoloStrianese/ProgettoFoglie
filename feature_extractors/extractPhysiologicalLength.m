function lengthVal = extractPhysiologicalLength(bw)
% extractPhysiologicalLength: Computes the physiological length of the object.
% (Here we use the major axis length as provided by regionprops.)
%
% Input:
%   bw - binary image containing a single region.
% Output:
%   lengthVal - scalar value (>=0)

stats = regionprops(bw, 'MajorAxisLength');
if isempty(stats)
    lengthVal = [];
else
    lengthVal = stats.MajorAxisLength;
end
end
