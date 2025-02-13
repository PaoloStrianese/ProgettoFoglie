function features = extractShapeRatios(mask)
% Verifica se la maschera è binaria; altrimenti, la binarizza
if ~islogical(mask)
    mask = imbinarize(mask);
end

% Estrai le proprietà dell'oggetto (MajorAxisLength e MinorAxisLength)
stats = regionprops(mask, 'MajorAxisLength', 'MinorAxisLength');

% Se non ci sono oggetti, restituisci feature nulle
if isempty(stats)
    features = [0, 0, 0, 0]; % Media, Mediana, Deviazione standard, Massimo
    return;
end

% Calcola il rapporto tra asse maggiore e minore per ogni oggetto
shapeRatios = arrayfun(@(s) s.MajorAxisLength / max(s.MinorAxisLength, 1), stats);

% Calcola statistiche utili
meanSR   = mean(shapeRatios);
medianSR = median(shapeRatios);
stdSR    = std(shapeRatios);
maxSR    = max(shapeRatios);

% Restituisce 4 feature
features = [meanSR, medianSR, stdSR, maxSR];
end