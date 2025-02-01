function [mask_predicted] = classify_knn(imageRGB, train_values, train_labels, imgID)
    % Funzione per classificare un'immagine di foglie utilizzando un classificatore KNN
    % con l'aggiunta degli indici ExG, VARI e RGBVI
    
    % Verifica degli input
    if nargin < 3
        error('Sono richiesti 3 input: imageRGB, train_values, train_labels.');
    end
    
    % Addestramento del classificatore KNN
    classifier_knn = fitcknn(train_values, train_labels, 'NumNeighbors', 11);
    disp('Fine Addestramento classificatore KNN.');
    
    % Riorganizzazione dell'immagine di test
    [ir, ic, ich] = size(imageRGB);
    if ich ~= 3
        error('L''immagine deve essere in formato RGB (3 canali).');
    end
    test_values = reshape(im2double(imageRGB), ir * ic, ich);
    
    % Estrazione dei canali R, G e B
    R = test_values(:,1);
    G = test_values(:,2);
    B = test_values(:,3);
    
    % Calcolo degli indici
    ExG = 2 * G - R - B;
    VARI = (G - R) ./ (G + R - B + 1e-6); % Evita divisione per zero
    RGBVI = (G.^2 - R .* B) ./ (G.^2 + R .* B + 1e-6); % Stabilità numerica
    
    % Creazione della matrice con i nuovi valori
    test_values = [R, G, B, ExG, VARI, RGBVI];
    disp('Immagine di test riorganizzata con nuovi indici.');
    
    % Classificazione dei dati di test con il classificatore
    test_predicted = predict(classifier_knn, test_values);
    disp('Classificazione completata.');
    
    % Ristrutturazione del vettore delle etichette in una maschera immagine
    mask_predicted = reshape(test_predicted, ir, ic);
    
    % Post-elaborazione della maschera con chiusura morfologica
    se = strel('disk', 7);
    mask_predicted = imclose(mask_predicted, se);
    disp('Post-elaborazione completata.');
    fprintf('----------- FINE IMG %d -----------\n', imgID);
end
