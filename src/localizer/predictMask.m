function [mask_predicted] = predictMask(imageRGB, model, imgID)
% Funzione per classificare un'immagine di foglie utilizzando un classificatore KNN
% Input:
%   imageRGB - immagine in formato RGB da classificare
%   train_values - dati di training (matrice di valori RGB)
%   train_labels - etichette per i dati di training (1=foglia, 0=sfondo)
% Output:
%   mask_predicted - maschera binaria della classificazione (1=foglia, 0=sfondo)

% Riorganizzazione dell'immagine di test
[ir, ic, ich] = size(imageRGB);
if ich ~= 3
    error('L''immagine deve essere in formato RGB (3 canali).');
end

% Convert the image to double precision
imageRGB = reshape(imageRGB, ir * ic, ich);

test_values = extractFeaturesLocalizer(imageRGB);

% Normalizzazione dei dati di test
test_values = normalize(test_values, 'range');

% Classificazione dei dati di test con il classificatore
[test_predicted, score] = predict(model, test_values);


idx = max(score, [], 2) < 0.65;
test_predicted(idx) = {'0'};

% Convert predicted labels (cell array of strings) to numeric values
pred_numeric = cellfun(@str2double, test_predicted);
%pred_numeric = test_predicted;
% Ristrutturazione del vettore delle etichette in una maschera immagine
mask_predicted = reshape(pred_numeric, ir, ic);

mask_predicted = logical(mask_predicted);

end