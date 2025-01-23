function out = save_combined_sgv(img, num, outputFolder)
    % Step 2: Converte l'immagine in spazio di colore HSV
    hsvImg = rgb2hsv(img);      % Converte in HSV
    
    % Estrai i canali S (Saturation) e V (Value) dallo spazio HSV
    saturationChannel = hsvImg(:,:,2);  % Estrai il canale di saturazione
    valueChannel = hsvImg(:,:,3);       % Estrai il canale di valore
    
    % Estrai il canale Verde dallo spazio RGB
    greenChannel = img(:,:,2);  % Canale Verde (secondo canale RGB)
    
    % Step 4: Somma i tre canali per ottenere una combinazione
    combinedChannel = (saturationChannel + valueChannel + double(greenChannel)) / 3;  % Media dei tre canali
    
    % Salva l'immagine del canale combinato
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);  % Crea la cartella se non esiste
    end
    imwrite(combinedChannel, fullfile(outputFolder, sprintf('combined_sgv_%d.png', num)));
    
    out = combinedChannel; % Restituisci l'immagine finale combinata
end
