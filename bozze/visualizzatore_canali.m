

% Carica l'immagine
% img = imread('dataset/Pianta 3/01.jpg');
img = imread("composizioni/02.jpg");
% Converte l'immagine in diversi spazi colore
orig = img;
img = enhancement(img);

img_hsv = rgb2hsv(img);
img_ycbcr = rgb2ycbcr(img);
img_lab = rgb2lab(img);

% Crea una figura per visualizzare i canali
figure;

% Immagine originale
subplot(5,3,1), imshow(orig), title('Original Image');

% Immagine migliorata
subplot(5,3,2), imshow(img), title('Enhanced Image');

% Spazio RGB
subplot(5,3,4), imshow(img(:,:,1)), title('Red Channel');
subplot(5,3,5), imshow(img(:,:,2)), title('Green Channel');
subplot(5,3,6), imshow(img(:,:,3)), title('Blue Channel');

% Spazio HSV
subplot(5,3,7), imshow(img_hsv(:,:,1)), title('Hue Channel');
subplot(5,3,8), imshow(img_hsv(:,:,2)), title('Saturation Channel');
subplot(5,3,9), imshow(img_hsv(:,:,3)), title('Value Channel');

% Spazio YCbCr
subplot(5,3,10), imshow(img_ycbcr(:,:,1)), title('Y Channel');
subplot(5,3,11), imshow(img_ycbcr(:,:,2)), title('Cb Channel');
subplot(5,3,12), imshow(img_ycbcr(:,:,3)), title('Cr Channel');

% Spazio Lab
subplot(5,3,13), imshow(img_lab(:,:,1), []), title('L Channel');
subplot(5,3,14), imshow(img_lab(:,:,2), []), title('A Channel');
subplot(5,3,15), imshow(img_lab(:,:,3), []), title('B Channel');

