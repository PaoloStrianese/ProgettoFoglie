function [imgEnhanced] = enhancement(imgRGB)
    % Convertiamo l'immagine in double per garantire precisione
    imgDouble = im2double(imgRGB);

    % Separazione dei canali R, G e B
    R = imgDouble(:,:,1);
    G = imgDouble(:,:,2);
    B = imgDouble(:,:,3);

    % Applicazione del filtro mediano a ciascun canale prima del calcolo di ExG
    R_filt = medfilt2(R, [7, 7]);
    G_filt = medfilt2(G, [7, 7]);
    B_filt = medfilt2(B, [7, 7]);

    % Calcolo dell'indice ExG (Excess Green)
    ExG = 2 * G_filt - R_filt - B_filt;

    % Normalizzazione dell'ExG
    ExG_norm = (ExG - min(ExG(:))) / (max(ExG(:)) - min(ExG(:)));

    % Miglioramento del contrasto
    imgEnhanced = imadjust(ExG_norm);
end
