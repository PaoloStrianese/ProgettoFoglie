function [imgEnhanced] = enhancement(imgRGB)
    % Convertiamo l'immagine in double per garantire precisione
    imgDouble = im2double(imgRGB);
    
    % Separazione dei canali R, G e B
    R = imgDouble(:,:,1);
    G = imgDouble(:,:,2);
    B = imgDouble(:,:,3);
    
    % Applicazione del filtro mediano a ciascun canale
    R_filt = medfilt2(R, [7, 7]);
    G_filt = medfilt2(G, [7, 7]);
    B_filt = medfilt2(B, [7, 7]);
    
    % Calcolo dell'indice Excess Green (ExG)
    ExG = 2 * G_filt - R_filt - B_filt;
    
    % Calcolo dell'indice Excess Red (ExR)
    ExR = 1.4 * R_filt - G_filt;
    
    % Calcolo dell'indice ExGR
    % (la differenza tra ExG e ExR evidenzia le aree vegetali)
    ExGR = ExG - ExR;  % equivalente a: 3*G_filt - 2.4*R_filt - B_filt
    
    % Normalizzazione di ExGR in [0,1]
    ExGR_norm = (ExGR - min(ExGR(:))) / (max(ExGR(:)) - min(ExGR(:)));
    
    % Creazione di una maschera binaria che evidenzia le foglie.
    % Si usa imbinarize che, di default, utilizza il metodo di Otsu.
    mask = imbinarize(ExGR_norm);
    
    % Applicazione della maschera all'immagine RGB:
    % le regioni non appartenenti alle foglie vengono ridotte (qui impostate a zero).
    imgEnhanced = imgRGB;
    imgEnhanced(repmat(~mask, [1, 1, 3])) = 0;
    
    % In alternativa, se si desidera un effetto "soft" che preservi gradazioni,
    % si può moltiplicare l'immagine RGB per la maschera normalizzata:
    % imgEnhanced = imgRGB .* repmat(ExGR_norm, [1, 1, 3]);
end