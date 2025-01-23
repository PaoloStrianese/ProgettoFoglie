function testPaolo(resizedImg, k)
    % Se l'immagine è RGB
    if size(resizedImg, 3) == 3
        % Applica il filtro Wiener a ciascun canale
        denoisedImg = resizedImg; % Inizializza l'immagine denoised
        for c = 1:3
            denoisedImg(:, :, c) = wiener2(resizedImg(:, :, c), [3 3]);
        end
    else
        % Se è già in scala di grigi
        denoisedImg = wiener2(resizedImg, [3 3]);
    end

    figure(), imshow(denoisedImg)

    % Normalizzazione dei dati
    denoisedImg = double(denoisedImg);
    meanVal = mean2(denoisedImg);
    stdDev = std2(denoisedImg);
    denom = stdDev * sqrt(2 * pi);
    lambda = 10;
    normalizedImg = 1 ./ (1 + exp(-lambda * ((denoisedImg - meanVal) / denom)));

    % Descrittori
    
    mean = compute_local_descriptors(normalizedImg, 9, 11, @compute_average_color_ycbcr);
    glcm = compute_local_descriptors(normalizedImg, 9, 11, @compute_glcm);
    % Creazione di un array compatibile per concatenare
    pixelFeatures = [mean.descriptors, glcm.descriptors];

    % Normalizza i descrittori tra 0 e 1
    pixelFeatures = normalize(pixelFeatures); 
    
    % Esegui K-means
    [clusterIdx, clusterCenters] = kmeans(pixelFeatures, k, ...
        'MaxIter', 100, 'Replicates', 5, 'Display', 'off');

    % Dimensioni dell'immagine originale
    [rows, cols, ch] = size(denoisedImg);
    
    % Rimappa i cluster a un'immagine 2D
    labels_img = reshape(clusterIdx, mean.nt_rows, mean.nt_cols, 1);

    segmentedImg = imresize(labels_img, [rows,cols], 'nearest');

    se = strel('disk', 5);
    erodedImg = imerode(segmentedImg, se);

    % Esegui la chiusura morfologica per chiudere i buchi
    se = strel('disk', 11); % Crea un elemento strutturante, tipo un disco
    closedImg = imclose(erodedImg, se);

    % Visualizza l'immagine segmentata con i buchi chiusi e filtrata
    figure;
    imshow(label2rgb(closedImg));
    title('Immagine segmentata con chiusura morfologica e filtrata');
end
