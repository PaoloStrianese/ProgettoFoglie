function features = extractExG(imgInput)
% Estrae 8 feature basate su ExG
% Output size: 1×8 vector

% Lettura e controllo immagine
if ischar(imgInput) || isstring(imgInput)
    img = imread(imgInput);
else
    img = imgInput;
end
assert(size(img,3)==3, 'Richiesta immagine RGB');

% Calcolo ExG
r = double(img(:,:,1));
g = double(img(:,:,2));
b = double(img(:,:,3));
exg = 2*g - r - b;

% Statistiche
stats = [...
    mean(exg(:)), ...
    std(exg(:)), ...
    skewness(exg(:)), ...
    kurtosis(exg(:)), ...
    prctile(exg(:),25), ...
    prctile(exg(:),50), ...
    prctile(exg(:),75)];

% Area vegetazione (Otsu)
exg_norm = mat2gray(exg);
th = graythresh(exg_norm);
veg_area = sum(exg_norm(:) > th) / numel(exg_norm);

features = [stats, veg_area];
end