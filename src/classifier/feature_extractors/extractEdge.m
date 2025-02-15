function features = extractEdge(mask)
% Check if the mask is binary; otherwise, binarize it
if ~islogical(mask)
    mask = imbinarize(mask);
end

% Extract the necessary properties
stats = regionprops(mask, 'Area', 'Perimeter', 'Eccentricity', 'Extent', 'Solidity');

% If no objects are found, return zero features
if isempty(stats)
    features = zeros(1, 16); % 4 metrics x 4 statistics
    return;
end

% Calculate circularity for each object
numObjects = length(stats);
circularity = zeros(numObjects, 1);
for i = 1:numObjects
    if stats(i).Perimeter > 0
        circularity(i) = (4 * pi * stats(i).Area) / (stats(i).Perimeter^2);
    else
        circularity(i) = 0;
    end
end

% Extract the other metrics
eccentricities = [stats.Eccentricity];
extents = [stats.Extent];
solidities = [stats.Solidity];

% Function to compute statistics
computeStats = @(x) [mean(x), median(x), std(x), max(x)];

% Calculate statistics for each metric
statsCirc = computeStats(circularity);
statsEcc = computeStats(eccentricities);
statsExt = computeStats(extents);
statsSol = computeStats(solidities);

% Concatenate all features
features = [statsCirc, statsEcc, statsExt, statsSol];
end