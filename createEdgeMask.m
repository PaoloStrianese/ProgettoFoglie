function mask = createEdgeMask(imgrgb, id)
% createEdgeMask restituisce una maschera binaria ottenuta dalla somma
% dei filtri Roberts, Sobel, Prewitt e Canny, con operazioni di closing,
% riempimento dei buchi e rimozione delle aree minori di 1000 pixel.
%
% INPUT:
%   imgrgb - immagine a colori (RGB)
%
% OUTPUT:
%   mask - maschera binaria in cui i bordi sono evidenziati (1)

%imgrgb = enhancement(imgrgb);
%saveImage(imgrgb, "enhanced", id);


% Se l'immagine è a colori, convertila in scala di grigi
if size(imgrgb, 3) == 3
    img_gray = rgb2gray(imgrgb);
else
    img_gray = imgrgb;
end

img_gray = medfilt2(img_gray, [11,11]);

%saveImage(img_gray, "gray", id);

% Calcola i bordi con i filtri:
edge_sobel   = edge(img_gray, 'Sobel');
%saveImage(edge_sobel, "sobel", id);
edge_prewitt = edge(img_gray, 'Prewitt');
%saveImage(edge_prewitt, "prewit", id);
edge_roberts = edge(img_gray, 'Roberts');
%saveImage(edge_roberts, "robert", id);
edge_canny = edge(img_gray, 'Canny', [0.08 0.15]);  % Applica Canny

%saveImage(edge_canny, "canny", id);

% Somma pixel-per-pixel i risultati dei quattro filtri
% (conversione in double per sommare immagini binarie)
edge_sum = double(edge_roberts) + double(edge_sobel) + double(edge_prewitt) + double(edge_canny);

%saveImage(edge_sum, "mask-pre", id)

% Applica un'operazione di closing per connettere i bordi spezzati
se = strel('disk', 15);
edge_sum = imclose(edge_sum, se);

% Riempi eventuali buchi nella maschera
edge_sum = imfill(edge_sum, 'holes');

se = strel('disk', 3);
edge_sum = imerode(edge_sum, se);

% Binarizza: ogni pixel > 0 diventa 1 (bordo rilevato)
mask = edge_sum > 0;

saveImage(mask, "masks", id);

% Rimuove le aree con meno di 1000 pixel
mask = bwareaopen(mask, 5000);
end