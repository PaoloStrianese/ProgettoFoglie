clear all;
close all;

addpath("bozze/");
% Read the image
img = imread('dataset/Pianta 10/10.jpg');

img = imresize(img, [512*2 512*2]);

% labImg = rgb2lab(img);
% filteredImg = labImg(:,:,2);

% Convert the image to grayscale
filteredImg = rgb2gray(img);

% Applica filtro gaussiano a filteredImg
gaussianFilter = fspecial('gaussian', [31 31]);
filteredImg = imfilter(filteredImg, gaussianFilter, 'replicate');

% Apply a median filter
filteredImg = medfilt2(filteredImg, [15 15]);

% Convert the image to HSV
hsvImg = rgb2hsv(img);

% Extract the S channel
sChannel = hsvImg(:, :, 2);

% Apply Canny edge detector
edges = edge(filteredImg, 'Canny', 0.15);

% % Define the size of the region to close with a circular structuring element
se = strel('disk', 15);

% % % Apply morphological closing
edges = imclose(edges, se);


% % Fill holes in the edges
edges = imfill(edges, 'holes');



% Applica un filtro mediano per ridurre il rumore (kernel 9x9)
img_gray = medfilt2(filteredImg, [9, 9]);

% Calcola i bordi con i filtri:
% Adjust thresholds to make edge detection more sensitive
edge_sobel   = edge(img_gray, 'Sobel', 0.05);
edge_prewitt = edge(img_gray, 'Prewitt',0.05);
edge_roberts = edge(img_gray, 'Roberts');

% Somma pixel-per-pixel i risultati dei tre filtri
% (conversione in double per sommare immagini binarie)
edge_sum = double(edge_roberts) + double(edge_sobel) + double(edge_prewitt);

% Applica un'operazione di closing per connettere i bordi spezzati
se = strel('disk', 15);
edge_sum = imclose(edge_sum, se);

% % Riempi eventuali buchi nella maschera
edge_sum = imfill(edge_sum, 'holes');

% Binarizza: ogni pixel > 0 diventa 1 (bordo rilevato)
mask = edge_sum > 0;


% % Rimuove le aree con meno di 1000 pixel
% mask = bwareaopen(mask, 5000);


a = mask + edges;

% Display the original image and the edges
figure;
subplot(1, 4, 1);
imshow(filteredImg);
title('Original Image');

subplot(1, 4, 2);
imshow(edges);
title('CAnny');

subplot(1, 4, 3);
imshow(mask);
title('Tua');

subplot(1, 4, 4);
imshow(a);
title('combined');


% Create segmented image by masking the original image
segmentedImg = img;
segmentedImg(repmat(~a, [1 1 3])) = 0;

% Add the segmented image subplot
figure(2);
imshow(segmentedImg);
title('Segmented Image');