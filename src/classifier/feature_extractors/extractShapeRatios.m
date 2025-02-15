function features = extractShapeRatios(mask)
% Check if the mask is binary; if not, binarize it
if ~islogical(mask)
    mask = imbinarize(mask);
end

% Extract object properties (MajorAxisLength and MinorAxisLength)
stats = regionprops(mask, 'MajorAxisLength', 'MinorAxisLength');

% If there are no objects, return null features
if isempty(stats)
    features = [0, 0, 0, 0]; % Mean, Median, Standard Deviation, Maximum
    return;
end

% Calculate the ratio between the major and minor axis for each object
shapeRatios = arrayfun(@(s) s.MajorAxisLength / max(s.MinorAxisLength, 1), stats);

% Calculate useful statistics
meanSR   = mean(shapeRatios);
medianSR = median(shapeRatios);
stdSR    = std(shapeRatios);
maxSR    = max(shapeRatios);

% Return 4 features
features = [meanSR, medianSR, stdSR, maxSR];
end