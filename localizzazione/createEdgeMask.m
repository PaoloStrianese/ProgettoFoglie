function mask = createEdgeMask(imgrgb, id)
% createEdgeMask restituisce una maschera binaria ottenuta dalla somma
% dei filtri (Sobel e Canny applicati su immagini originali ed enhanceate), 
% seguita da operazioni di closing, riempimento dei buchi e rimozione 
% delle aree minori di 5000 pixel.
%
% INPUT:
%   imgrgb - immagine a colori (RGB)
%   id     - identificativo per il salvataggio delle immagini intermedie
%
% OUTPUT:
%   mask - maschera binaria in cui i bordi sono evidenziati (1)

    % Migliora l'immagine e salva il risultato
    imgEnhanced = enhancement(imgrgb);
    saveImage(imgEnhanced, "enhanced", id);

    % Converti in scala di grigi:
    % - 'grayEnhanced' per l'immagine migliorata
    % - 'grayOriginal' per l'immagine originale
    if size(imgEnhanced, 3) == 3
        grayEnhanced = rgb2gray(imgEnhanced);
        grayOriginal = rgb2gray(imgrgb);
    else
        grayEnhanced = imgEnhanced;
        grayOriginal = imgrgb;
    end

    % Applica il filtro mediano per ridurre il rumore
    grayEnhanced = medfilt2(grayEnhanced, [5, 5]);
    grayOriginal = medfilt2(grayOriginal, [5, 5]);
    saveImage(grayEnhanced, "gray", id);

    % Calcola i bordi con i filtri:
    % - Sobel sull'immagine originale
    % - Canny su entrambe le versioni (originale e migliorata)
    edgeSobel = edge(grayOriginal, 'Sobel');
    edgeCannyOriginal = edge(grayOriginal, 'Canny', [0.08, 0.15]);
    edgeCannyEnhanced = edge(grayEnhanced, 'Canny', [0.08, 0.15]);
    saveImage(edgeCannyOriginal, "canny", id);

    % Somma le immagini binarie dei bordi (conversione in double per la somma)
    edgeSum = double(edgeSobel) + double(edgeCannyOriginal) + double(edgeCannyEnhanced);
    saveImage(edgeSum, "mask-pre", id);

    % Connette i bordi spezzati e riempie i buchi
    seClose = strel('disk', 15);
    edgeSum = imclose(edgeSum, seClose);
    edgeSum = imfill(edgeSum, 'holes');

    % Erode leggermente per affinare i bordi
    seErode = strel('disk', 3);
    edgeSum = imerode(edgeSum, seErode);

    % Binarizza: tutti i pixel > 0 diventano 1
    mask = edgeSum > 0;
    saveImage(mask, "masks", id);

    % Rimuove le aree con meno di 5000 pixel
    mask = bwareaopen(mask, 5000);
end