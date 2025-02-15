function features = extractExGR(imgInput)
% Image reading and verification
if ischar(imgInput) || isstring(imgInput)
    img = imread(imgInput);
else
    img = imgInput;
end
assert(size(img,3) == 3, 'RGB image required');
img = im2double(img);  % Convert to double [0,1]

% Calculate ExGR
r = img(:,:,1);
g = img(:,:,2);
b = img(:,:,3);
exgr = (2*g - r - b) - (1.4*r - g);

% Statistics (same format as ExG)
stats = [...
    mean(exgr(:)), ...
    std(exgr(:)), ...
    skewness(exgr(:)), ...
    kurtosis(exgr(:)), ...
    prctile(exgr(:),25), ...
    prctile(exgr(:),50), ...
    prctile(exgr(:),75)];

% Vegetation area
exgr_norm = mat2gray(exgr);
th = graythresh(exgr_norm);
veg_area = sum(exgr_norm(:) > th) / numel(exgr_norm);

features = [stats, veg_area];
end