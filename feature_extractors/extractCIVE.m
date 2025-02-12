function features = extractCIVE(imgInput)
% Estrae 8 feature basate su CIVE
% Output size: 1×8 vector

% Lettura immagine
img = imgInput;

% Calcolo CIVE
r = double(img(:,:,1));
g = double(img(:,:,2));
b = double(img(:,:,3));
cive = 0.441*r - 0.811*g + 0.385*b + 18.78745;

% Statistiche
stats = [mean(cive(:)) std(cive(:)) skewness(cive(:)) kurtosis(cive(:)) prctile(cive(:),25) prctile(cive(:),50) prctile(cive(:),75)];

% Area vegetazione
cive_norm = mat2gray(cive);
th = graythresh(cive_norm);
veg_area = sum(cive_norm(:) > th) / numel(cive_norm);

features = [stats, veg_area];
end