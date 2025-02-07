function [mask_predicted] = classify_knn(imageRGB, model, imgID)
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
    rgbImage = im2double(imageRGB);
    
    % Extract RGB features
    rgb_features = reshape(rgbImage, ir * ic, ich);
    
    % Convert to HSV and extract features
    hsv_features = reshape(rgb2hsv(rgbImage), ir * ic, 3);
    
    % Convert to LAB and extract features
    lab_features = reshape(rgb2lab(rgbImage), ir * ic, 3);
    
    % Combine all features into one matrix
    test_values = [rgb_features, hsv_features, lab_features];
    disp('Immagine di test riorganizzata.');
    
    % Classificazione dei dati di test con il classificatore
    test_predicted = predict(model, test_values);
    disp('Classificazione completata.');
    
    % Ristrutturazione del vettore delle etichette in una maschera immagine
    mask_predicted = reshape(test_predicted, ir, ic);
    
    % Post-elaborazione della maschera con chiusura morfologica
    se = strel('disk', 7);
    mask_predicted = imclose(mask_predicted, se);
    disp('Post-elaborazione completata.');
    fprintf('----------- FINE IMG %d -----------\n', imgID);

end
