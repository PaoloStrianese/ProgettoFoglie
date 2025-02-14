function features = extractHOG(maskImg)
    % Estrae features HOG con dimensione fissa
    % Input: Maschera binaria (qualunque dimensione)
    % Output: Vettore 1x36
    
    % 1. Resize a dimensione fissa (es. 64x64)
    targetSize = [64, 64]; 
    resizedImg = imresize(maskImg, targetSize);
    
    % 2. Conversione in scala di grigi
    grayImg = im2uint8(resizedImg);
    
    % 3. Parametri ottimizzati per 64x64
    cellSize = [16 16];   % 64/16 = 4 celle per lato
    blockSize = [2 2];    % 2x2 celle per blocco
    numBins = 9;          % Orientamenti
    
    % 4. Calcolo HOG garantendo 36 features
    features = extractHOGFeatures(grayImg,...
        'CellSize', cellSize,...
        'BlockSize', blockSize,...
        'NumBins', numBins);
    
    % 5. Forza la dimensione a 36 elementi
    features = features(1:36); 
end