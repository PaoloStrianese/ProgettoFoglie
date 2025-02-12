function features = extractHaralick(img)
% Converti in scala di grigi se necessario
if size(img,3) == 3
    img = rgb2gray(img);
end

% Calcola GLCM per 4 angoli (0°,45°,90°,135°)
offsets = [0 1; -1 1; -1 0; -1 -1];
glcm = graycomatrix(img, 'Offset', offsets, 'NumLevels', 8, 'Symmetric', true);

% Estrai statistiche Haralick (solo proprietà supportate dalla funzione graycoprops)
props = {'Contrast', 'Correlation', 'Energy', 'Homogeneity'};

features = zeros(1, length(props));
for i = 1:length(props)
    stats = graycoprops(glcm, props{i});
    features(i) = mean(stats.(props{i}));
end
end