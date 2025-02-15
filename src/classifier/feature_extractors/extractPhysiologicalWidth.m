function widthVal = extractPhysiologicalWidth(bw)
stats = regionprops(bw, 'MinorAxisLength');
if isempty(stats)
    widthVal = [];
else
    widthVal = stats.MinorAxisLength;
end
end
