function features = extractCanny(image, leafMask)

% Convert to grayscale if the image is RGB
if size(image, 3) == 3
    grayImg = rgb2gray(image);
else
    grayImg = image;
end

% Enhance contrast to emphasize internal details (veins)
enhancedImg = imadjust(grayImg);

% Apply a Gaussian filter to reduce noise
filteredImg = imgaussfilt(enhancedImg, 2);

% Apply the Canny operator to extract the veins
edges = edge(filteredImg, 'Canny');

% If a leaf mask is provided, limit the analysis to its area
if nargin > 1 && ~isempty(leafMask)
    if ~islogical(leafMask)
        leafMask = imbinarize(leafMask);
    end
    edges(~leafMask) = 0;
end

% Perform skeletonization to obtain a thin representation
venationSkeleton = bwmorph(edges, 'skel', Inf);

% Extract region properties from the vein pattern
stats = regionprops(venationSkeleton, 'Area', 'Perimeter', 'Eccentricity', 'Extent', 'Solidity');

% If no regions are detected, return a feature vector of zeros
if isempty(stats)
    features = zeros(1, 16);  % 4 metrics x 4 statistics
    return;
end

% Compute circularity for each object (only if Perimeter > 0)
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

% Anonymous function to compute statistics: mean, median, standard deviation, maximum
computeStats = @(x) [mean(x), median(x), std(x), max(x)];

% Compute the statistics for each metric
statsCirc = computeStats(circularity);
statsEcc = computeStats(eccentricities);
statsExt = computeStats(extents);
statsSol = computeStats(solidities);

% Concatenate all features into a single vector
features = [statsCirc, statsEcc, statsExt, statsSol];
end