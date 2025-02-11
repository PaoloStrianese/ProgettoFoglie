% Cartelle contenenti le maschere e la ground truth
maskDir = fullfile('.cache','segmented_leaves');
gtDir   = fullfile('.cache,''gt');

% Ottieni la lista di file .png nella cartella delle maschere
maskFiles = dir(fullfile(maskDir, '*.png'));

% Verifica che ci siano immagini
if isempty(maskFiles)
    error('Nessuna immagine trovata nella cartella %s', maskDir);
end

% Inizializza le variabili per le metriche globali
totalTP = 0;
totalFP = 0;
totalFN = 0;
totalTN = 0;

% Prealloca gli array per salvare le metriche per immagine
numImages   = length(maskFiles);
precisionArr = zeros(numImages,1);
recallArr    = zeros(numImages,1);
f1Arr        = zeros(numImages,1);

% Ciclo su tutte le immagini nella cartella 'mask'
for i = 1:numImages
    % Nome del file corrente
    maskName = maskFiles(i).name;

    % Percorsi per la maschera predetta e la ground truth
    predPath = fullfile(maskDir, maskName);
    gtPath   = fullfile(gtDir, maskName);

    % Verifica che il file corrispondente esista nella cartella GT
    if ~isfile(gtPath)
        warning('Il file %s non esiste nella cartella %s. Immagine saltata.', maskName, gtDir);
        continue;
    end

    % Carica le immagini
    predMask = imread(predPath);
    gtMask   = imread(gtPath);

    % Se le immagini sono a colori, convertile in scala di grigi
    if size(predMask,3) > 1
        predMask = rgb2gray(predMask);
    end
    if size(gtMask,3) > 1
        gtMask = rgb2gray(gtMask);
    end

    % Converte le immagini in binario (se non lo sono già)
    % Si utilizza imbinarize che effettua una sogliatura automatica
    if ~islogical(predMask)
        predMask = imbinarize(predMask);
    end
    if ~islogical(gtMask)
        gtMask = imbinarize(gtMask);
    end

    % Calcola i valori della matrice di confusione pixel-per-pixel
    % TP: pixel dove sia la maschera predetta che la GT sono 1
    % FP: pixel dove la maschera predetta è 1 e la GT è 0
    % FN: pixel dove la maschera predetta è 0 e la GT è 1
    % TN: pixel dove sia la maschera predetta che la GT sono 0
    TP = sum((predMask == 1) & (gtMask == 1), 'all');
    FP = sum((predMask == 1) & (gtMask == 0), 'all');
    FN = sum((predMask == 0) & (gtMask == 1), 'all');
    TN = sum((predMask == 0) & (gtMask == 0), 'all');

    % Aggiorna i contatori globali
    totalTP = totalTP + TP;
    totalFP = totalFP + FP;
    totalFN = totalFN + FN;
    totalTN = totalTN + TN;

    % Calcola precision, recall e F1 score per questa immagine
    if (TP + FP) == 0
        precision = 0;
    else
        precision = TP / (TP + FP);
    end

    if (TP + FN) == 0
        recall = 0;
    else
        recall = TP / (TP + FN);
    end

    if (precision + recall) == 0
        f1 = 0;
    else
        f1 = 2 * (precision * recall) / (precision + recall);
    end

    % Salva i risultati per l'immagine corrente
    precisionArr(i) = precision;
    recallArr(i)    = recall;
    f1Arr(i)        = f1;

    % Visualizza i risultati per l'immagine corrente
    fprintf('Immagine: %s\n', maskName);
    fprintf('TP: %d, FP: %d, FN: %d, TN: %d\n', TP, FP, FN, TN);
    fprintf('Precision: %.4f, Recall: %.4f, F1 Score: %.4f\n\n', precision, recall, f1);
end

% Calcola le metriche complessive su tutte le immagini
if (totalTP + totalFP) == 0
    overallPrecision = 0;
else
    overallPrecision = totalTP / (totalTP + totalFP);
end

if (totalTP + totalFN) == 0
    overallRecall = 0;
else
    overallRecall = totalTP / (totalTP + totalFN);
end

if (overallPrecision + overallRecall) == 0
    overallF1 = 0;
else
    overallF1 = 2 * (overallPrecision * overallRecall) / (overallPrecision + overallRecall);
end

% Visualizza i risultati globali
fprintf('-----------------------------\n');
fprintf('Metriche Complessive:\n');
fprintf('Totale TP: %d, Totale FP: %d, Totale FN: %d, Totale TN: %d\n', totalTP, totalFP, totalFN, totalTN);
fprintf('Precision complessiva: %.4f\n', overallPrecision);
fprintf('Recall complessiva:    %.4f\n', overallRecall);
fprintf('F1 Score complessivo:  %.4f\n', overallF1);


