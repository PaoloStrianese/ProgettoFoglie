function [imgEnhanced] = enhancement(imgRGB)

    % Estrai i canali R, G e B
    R = imgRGB(:, :, 1);
    G = imgRGB(:, :, 2);
    B = imgRGB(:, :, 3);

    % Calcolo degli indici di vegetazione
    ExG = 2 * G - R - B;
    VARI = (G - R) ./ (G + R - B + 1e-6); % Evita divisione per zero
    RGBVI = (G.^2 - R .* B) ./ (G.^2 + R .* B + 1e-6); % Stabilità numerica

    % Creazione di una maschera combinata basata sugli indici
    % Nota: le soglie devono essere determinate in base alle caratteristiche specifiche delle tue immagini
    mask = (ExG > 0) & (VARI > 0) & (RGBVI > 0);

    % Conversione in HSV per la manipolazione della tonalità
    imgHSV = rgb2hsv(imgRGB);

    % Spostamento delle tonalità verso il verde puro nelle aree identificate dalla maschera
    hue = imgHSV(:, :, 1); % Canale della tonalità
    hue(mask) = 0.33; % 0.33 corrisponde al verde puro nello spazio HSV
    imgHSV(:, :, 1) = hue;

    % Conversione in RGB
    imgEnhanced = hsv2rgb(imgHSV);
end

%% Funzione per applicare il filtro mediano su immagini RGB o in scala di grigi
function outImage = apply_medfilt(image, filterSize)
    % Se l'immagine è RGB, applica il filtro a ciascun canale separatamente
    if size(image, 3) == 3
        outImage = image;
        for c = 1:3
            outImage(:, :, c) = medfilt2(image(:, :, c), filterSize);
        end
    else
        outImage = medfilt2(image, filterSize);
    end
end
