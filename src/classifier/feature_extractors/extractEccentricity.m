function eccVal = extractEccentricity(bw)
stats = regionprops(bw, 'Eccentricity');
if isempty(stats)
    eccVal = [];
else
    eccVal = stats.Eccentricity;
end
end