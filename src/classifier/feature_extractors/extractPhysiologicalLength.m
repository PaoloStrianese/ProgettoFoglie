function lengthVal = extractPhysiologicalLength(bw)
stats = regionprops(bw, 'MajorAxisLength');
if isempty(stats)
    lengthVal = [];
else
    lengthVal = stats.MajorAxisLength;
end
end
