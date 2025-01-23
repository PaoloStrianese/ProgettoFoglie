function out = binarize_adaptive2(img, num, outputFolder)
    % Step 1: Ridimensiona l'immagine a 512x512
    img = imresize(img, [512 512]);

    % Step 2: Converti l'immagine in spazio di colore HSV
    hsvImg = rgb2hsv(img);      % Converte in HSV
    
    % Step 3: Estrai il canale S (Saturation)
    saturationChannel = hsvImg(:,:,2);  % Canale di saturazione
    
    % Step 4: Converte l'immagine RGB in scala di grigi
    grayImg = rgb2gray(img);            % Immagine in scala di grigi
    
    % Step 5: Applica un filtro mediano ai canali
    saturationChannel = medfilt2(saturationChannel, [3 3]);
    grayImg = medfilt2(grayImg, [3 3]);

    % Step 6: Imposta a 0 i valori di saturazione sotto una certa soglia (0.2)
    threshold = 0.2;  % Soglia
    saturationChannel(saturationChannel < threshold) = 0;

    % Step 7: Combina il canale di saturazione e l'immagine in scala di grigi
    combinedChannel = (saturationChannel + double(grayImg) / 255) / 2;

    % Step 8: Salva l'immagine combinata
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);  % Crea la cartella se non esiste
    end
    imwrite(combinedChannel, fullfile(outputFolder, sprintf('combined_channel_%d.png', num)));

    % Step 9: Applica il clustering k-means con 2 classi
    % Appiattisci l'immagine per il clustering
    [rows, cols] = size(combinedChannel);
    reshapedData = reshape(combinedChannel, [], 1);

    % Esegui k-means con 2 cluster
    k = 2; % Due classi: foglia e sfondo
    [clusterIdx, ~] = kmeans(reshapedData, k, 'Replicates', 5);

    % Ricostruisci l'immagine segmentata
    segmentedImg = reshape(clusterIdx, rows, cols);

    % Step 10: Normalizza i cluster per ottenere una mappa binaria (0 e 1)
    binaryImg = segmentedImg == mode(segmentedImg(:)); % Imposta la classe maggiore come sfondo
    binaryImg = ~binaryImg; % Inverti per avere le foglie come 1
    
    % Step 11: Esegui operazioni morfologiche per migliorare la qualità
    se = strel('disk', 5);
    erodedImg = imerode(binaryImg, se); % Erosione
    se = strel('disk', 15); 
    closedImg = imclose(erodedImg, se); % Chiusura

    % Step 12: Salva e restituisci l'immagine finale
    imwrite(closedImg, fullfile(outputFolder, sprintf('segmented_img_%d.png', num)));
    out = closedImg;
end
