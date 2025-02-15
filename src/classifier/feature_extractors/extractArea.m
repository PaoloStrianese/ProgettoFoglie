function areaVal = extractArea(bw)
stats = regionprops(bw, 'Area');
if isempty(stats)
    areaVal = [];
else
    areaVal = stats.Area;
end
end
