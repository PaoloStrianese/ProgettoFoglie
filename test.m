% Specifica il percorso dell'immagine
imgPath = 'dataset\Pianta 9/04.jpg';  % Sostituisci con il percorso reale

% Leggi l'immagine
img = imread(imgPath);
img = imresize(img, [1024 1024]);


% Converte in scala di grigi se l'immagine è a colori
if size(img, 3) == 3
    img_gray = rgb2gray(img);
else
    img_gray = img;
end

img_gray = medfilt2(img_gray, [9, 9]);

% Applica i filtri per il rilevamento dei bordi

% 1. Filtro Sobel
edge_sobel = edge(img_gray, 'Sobel');

% 2. Filtro Prewitt
edge_prewitt = edge(img_gray, 'Prewitt');

% 3. Filtro Laplaciano (Laplacian of Gaussian)
edge_log = edge(img_gray, 'log');

% 4. Filtro Canny
edge_canny = edge(img_gray, 'Canny');

% 5. Filtro Roberts
edge_roberts = edge(img_gray, 'Roberts');

se = strel('disk', 11);

% Calcola la somma pixel-per-pixel dei risultati di Roberts, Sobel e Prewitt
% Convertiamo le immagini binarie in double per poter sommare.
edge_sum = double(edge_roberts) + double(edge_sobel) + double(edge_prewitt);
edge_sum = imclose(edge_sum, se);
edge_sum = imfill(edge_sum, "holes");

% Per visualizzare in maniera binaria, si può applicare una soglia: 
% in questo caso, se almeno uno dei tre filtri ha individuato un bordo, il pixel sarà 1.
edge_union = edge_sum > 0;


% Visualizza i risultati in un'unica figura con subplots
figure;

subplot(2,4,1);
imshow(img_gray);
title('Immagine originale');

subplot(2,4,2);
imshow(edge_sobel);
title('Filtro Sobel');

subplot(2,4,3);
imshow(edge_prewitt);
title('Filtro Prewitt');

subplot(2,4,4);
imshow(edge_roberts);
title('Filtro Roberts');

subplot(2,4,5);
imshow(edge_log);
title('Filtro Laplacian (LoG)');

subplot(2,4,6);
imshow(edge_canny);
title('Filtro Canny');

subplot(2,4,7);
imshow(edge_sum, []); % Visualizza la somma con scala di grigi
title('Somma (Roberts + Sobel + Prewitt)');

subplot(2,4,8);
imshow(edge_union);
title('Unione logica dei bordi');
