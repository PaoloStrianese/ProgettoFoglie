function shadowRemovedImg = removeShadows(img)
    % Converti in formato double per calcoli precisi
    img = double(img);
    
    % Imposta una soglia per i valori troppo chiari (ad esempio 245 su 255)
    threshold = 245; % Threshold alto per i pixel troppo chiari (da 0 a 255)
    
    % Separazione dei canali
    if size(img, 3) == 3
        R = img(:, :, 1);
        G = img(:, :, 2);
        B = img(:, :, 3);
        
        % Crop sui valori troppo chiari per ciascun canale
        R(R > threshold) = threshold;
        G(G > threshold) = threshold;
        B(B > threshold) = threshold;
        
        % Ripristina l'intensità per non rendere l'immagine troppo scura
        R = R - min(R(:)); % Sottrarre il minimo per spostare l'intervallo in [0, max(R)]
        G = G - min(G(:)); % Sottrarre il minimo per spostare l'intervallo in [0, max(G)]
        B = B - min(B(:)); % Sottrarre il minimo per spostare l'intervallo in [0, max(B)]
        
        % Normalizza ciascun canale per avere valori tra 0 e 255
        R = R / max(R(:)) * 255;
        G = G / max(G(:)) * 255;
        B = B / max(B(:)) * 255;
        
        % Normalizzazione di ogni canale
        sumRGB = R + G + B + eps; % Somma per evitare divisione per zero
        normR = R ./ sumRGB;
        normG = G ./ sumRGB;
        normB = B ./ sumRGB;
        
        % Ricostruisci l'immagine normalizzata
        shadowRemovedImg = cat(3, normR, normG, normB);
    else
        % Se è in scala di grigi, restituisci direttamente l'immagine originale
        shadowRemovedImg = img;
    end
    
    % Converti di nuovo in formato uint8
    shadowRemovedImg = uint8(shadowRemovedImg * 255);
    
    % Visualizza il risultato
    figure;
    subplot(1, 2, 1);
    imshow(uint8(img)); % Visualizza l'immagine modificata
    title('Immagine originale con ombre');
    
    subplot(1, 2, 2);
    imshow(shadowRemovedImg); % Visualizza l'immagine con ombre rimosse
    title('Immagine con ombre rimosse');
end
