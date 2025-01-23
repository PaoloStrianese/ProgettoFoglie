function out = binarize_s_adaptive(img, num, outputFolder)
    % Step 2: Converte l'immagine in spazio di colore HSV
    hsvImg = rgb2hsv(img);      % Converte in HSV
    
    % Step 3: Estrai il canale S (Saturation)
    saturationChannel = hsvImg(:,:,2);  % Estrai il canale di saturazione    
    % Estrai il canale Verde dallo spazio RGB
    greenChannel = img(:,:,2);  % Canale Verde (secondo canale RGB)
    
    % Step 4: Applicare il filtro di Wiener al canale di saturazione
    saturationChannel = wiener2(saturationChannel, [3 3]);
    greenChannel = wiener2(greenChannel, [3 3]);

    % Step 5: Imposta a 0 i valori di saturazione sotto una certa soglia (0.2)
    threshold = 0.2;  % Soglia a 0.2
    saturationChannel(saturationChannel < threshold) = 0;
    
    % Step 6: Combina i canali filtrati (Media dei 3 canali)
    combinedChannel = (saturationChannel + double(greenChannel)) / 2;

    
    % Salva l'immagine della combinazione filtrata
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);  % Crea la cartella se non esiste
    end
    
    % Salva l'immagine del canale combinato filtrato
    imwrite(combinedChannel, fullfile(outputFolder, sprintf('combined_filtered_%d.png', num)));
    
    % Step 9: Binarizzazione con sogliatura adattiva
    % Calcola la soglia adattiva per l'immagine filtrata
    adaptiveThreshold = adaptthresh(combinedChannel, 0.5);  % 1 è la sensibilità
    
    % Binarizza l'immagine usando la soglia adattiva
    binaryImg = imbinarize(combinedChannel, adaptiveThreshold);
    
    % Step 10: Esegui operazioni morfologiche per migliorare la qualità
    se = strel('disk', 5);
    erodedImg = imerode(binaryImg, se); % Erosione
    
    % Esegui la chiusura morfologica per chiudere i buchi
    se = strel('disk', 15); % Crea un elemento strutturante, tipo un disco
    closedImg = imclose(erodedImg, se); % Chiusura morfologica
    
    out = closedImg; % Restituisci l'immagine finale elaborata
end
