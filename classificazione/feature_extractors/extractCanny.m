function features = extractCanny(image, leafMask)

% Converti in scala di grigi se l'immagine è RGB
if size(image, 3) == 3
    grayImg = rgb2gray(image);
else
    grayImg = image;
end

% Migliora il contrasto per enfatizzare i dettagli interni (venature)
enhancedImg = imadjust(grayImg);

% Applica un filtro gaussiano per ridurre il rumore
filteredImg = imgaussfilt(enhancedImg, 2);

% Applica l'operatore Canny per estrarre le venature
edges = edge(filteredImg, 'Canny');

% Se è disponibile una maschera della foglia, limita l'analisi al suo interno
if nargin > 1 && ~isempty(leafMask)
    if ~islogical(leafMask)
        leafMask = imbinarize(leafMask);
    end
    edges(~leafMask) = 0;
end

% Esegui la skeletonizzazione per ottenere una rappresentazione sottile
venationSkeleton = bwmorph(edges, 'skel', Inf);

% Estrai le proprietà delle regioni ottenute dal pattern di venature
stats = regionprops(venationSkeleton, 'Area', 'Perimeter', 'Eccentricity', 'Extent', 'Solidity');

% Se non sono rilevate regioni, restituisce un vettore di feature a zero
if isempty(stats)
    features = zeros(1, 16);  % 4 metriche x 4 statistiche
    return;
end

% Calcola la circolarità per ogni oggetto (solo se Perimeter > 0)
numObjects = length(stats);
circularity = zeros(numObjects, 1);
for i = 1:numObjects
    if stats(i).Perimeter > 0
        circularity(i) = (4 * pi * stats(i).Area) / (stats(i).Perimeter^2);
    else
        circularity(i) = 0;
    end
end

% Estrai le altre metriche
eccentricities = [stats.Eccentricity];
extents = [stats.Extent];
solidities = [stats.Solidity];

% Funzione anonima per calcolare le statistiche: media, mediana, deviazione standard, massimo
computeStats = @(x) [mean(x), median(x), std(x), max(x)];

% Calcola le statistiche per ogni metrica
statsCirc = computeStats(circularity);
statsEcc = computeStats(eccentricities);
statsExt = computeStats(extents);
statsSol = computeStats(solidities);

% Concatena tutte le feature in un unico vettore
features = [statsCirc, statsEcc, statsExt, statsSol];
end