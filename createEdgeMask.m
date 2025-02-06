function mask = createEdgeMask(imgrgb, id)
% createEdgeMask restituisce una maschera binaria ottenuta dalla somma
% dei filtri Roberts, Sobel e Prewitt, con operazioni di closing, 
% riempimento dei buchi e rimozione delle aree minori di 1000 pixel.
%
% INPUT:
%   imgrgb - immagine a colori (RGB)
%
% OUTPUT:
%   mask - maschera binaria in cui i bordi sono evidenziati (1)

    % Se l'immagine è a colori, convertila in scala di grigi
    if size(imgrgb, 3) == 3
        img_gray = rgb2gray(imgrgb);
    else
        img_gray = imgrgb;
    end

    % Applica un filtro mediano per ridurre il rumore (kernel 9x9)
    %img_gray = medfilt2(img_gray, [9, 9]);

    % Calcola i bordi con i filtri:
    edge_sobel   = edge(img_gray, 'Sobel');
    edge_prewitt = edge(img_gray, 'Prewitt');
    edge_roberts = edge(img_gray, 'Roberts');

    % Somma pixel-per-pixel i risultati dei tre filtri 
    % (conversione in double per sommare immagini binarie)
    edge_sum = double(edge_roberts) + double(edge_sobel) + double(edge_prewitt);

    % Applica un'operazione di closing per connettere i bordi spezzati
    se = strel('disk', 21);
    edge_sum = imclose(edge_sum, se);

    % Riempi eventuali buchi nella maschera
    edge_sum = imfill(edge_sum, 'holes');

    % Binarizza: ogni pixel > 0 diventa 1 (bordo rilevato)
    mask = edge_sum > 0;

    saveImage(mask, "masks", id);
    
    % Rimuove le aree con meno di 1000 pixel
    mask = bwareaopen(mask, 5000);
end
