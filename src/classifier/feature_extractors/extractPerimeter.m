function perimVal = extractPerimeter(bw)
stats = regionprops(bw, 'Perimeter');
if isempty(stats)
    perimVal = [];
else
    perimVal = stats.Perimeter;
end
end