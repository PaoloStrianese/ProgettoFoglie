function features = extractExGR(imgInput)
% Estrae 8 feature basate su ExGR
% Output size: 1×8 vector

% Lettura e controllo immagine
if ischar(imgInput) || isstring(imgInput)
    img = imread(imgInput);
else
    img = imgInput;
end
assert(size(img,3) == 3, 'Richiesta immagine RGB');
img = im2double(img);  % Converti in double [0,1]

% Calcolo ExGR
r = img(:,:,1);
g = img(:,:,2);
b = img(:,:,3);
exgr = (2*g - r - b) - (1.4*r - g);

% Statistiche (stesso formato di ExG)
stats = [...
    mean(exgr(:)), ...
    std(exgr(:)), ...
    skewness(exgr(:)), ...
    kurtosis(exgr(:)), ...
    prctile(exgr(:),25), ...
    prctile(exgr(:),50), ...
    prctile(exgr(:),75)];

% Area vegetazione
exgr_norm = mat2gray(exgr);
th = graythresh(exgr_norm);
veg_area = sum(exgr_norm(:) > th) / numel(exgr_norm);

features = [stats, veg_area];
end