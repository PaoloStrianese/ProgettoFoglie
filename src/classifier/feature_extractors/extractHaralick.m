function [features] = extractHaralick(img)

% Convert to grayscale if necessary
if size(img,3) == 3
    img = rgb2gray(img);
end

% Compute GLCM for 4 angles (0°, 45°, 90°, 135°)
offsets = [0 1; -1 1; -1 0; -1 -1];
glcm = graycomatrix(img, 'Offset', offsets, 'NumLevels', 8, 'Symmetric', true);

% Extract Haralick statistics (only properties supported by the graycoprops function)
props = {'Contrast', 'Correlation', 'Energy', 'Homogeneity'};

features = zeros(1, length(props));
for i = 1:length(props)
    stats = graycoprops(glcm, props{i});
    features(i) = mean(stats.(props{i}));
end
end