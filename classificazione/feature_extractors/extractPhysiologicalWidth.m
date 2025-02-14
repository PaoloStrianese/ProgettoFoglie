function widthVal = extractPhysiologicalWidth(bw)
% extractPhysiologicalWidth: Computes the physiological width of the object.
% (Here we use the minor axis length as provided by regionprops.)
%
% Input:
%   bw - binary image containing a single region.
% Output:
%   widthVal - scalar value (>=0)

stats = regionprops(bw, 'MinorAxisLength');
if isempty(stats)
    widthVal = [];
else
    widthVal = stats.MinorAxisLength;
end
end
