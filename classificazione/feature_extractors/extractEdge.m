function features = extractEdgeFeatures(mask)
    % Verifica se la maschera è binaria; altrimenti, la binarizza
    if ~islogical(mask)
        mask = imbinarize(mask);
    end
    
    % Estrae le proprietà necessarie
    stats = regionprops(mask, 'Area', 'Perimeter', 'Eccentricity', 'Extent', 'Solidity');
    
    % Se non ci sono oggetti, restituisci feature nulle
    if isempty(stats)
        features = zeros(1, 16); % 4 metriche x 4 statistiche
        return;
    end
    
    % Calcola la circolarità per ogni oggetto
    numObjects = length(stats);
    circularity = zeros(numObjects, 1);
    for i = 1:numObjects
        if stats(i).Perimeter > 0
            circularity(i) = (4 * pi * stats(i).Area) / (stats(i).Perimeter^2);
        else
            circularity(i) = 0;
        end
    end
    
    % Estrae le altre metriche
    eccentricities = [stats.Eccentricity];
    extents = [stats.Extent];
    solidities = [stats.Solidity];
    
    % Funzione per calcolare le statistiche
    computeStats = @(x) [mean(x), median(x), std(x), max(x)];
    
    % Calcola le statistiche per ogni metrica
    statsCirc = computeStats(circularity);
    statsEcc = computeStats(eccentricities);
    statsExt = computeStats(extents);
    statsSol = computeStats(solidities);
    
    % Concatena tutte le features
    features = [statsCirc, statsEcc, statsExt, statsSol];
end