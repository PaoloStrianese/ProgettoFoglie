close all;
clear;

outputFolderSegmentedLeaves = "segmented_leaves";
outputFolderMaskedLeaves    = "masked_leaves";
datasetFolder               = "dataset";

[allImageNames, leafFolders] = getNamesOfImageAndLeaf(datasetFolder);

imageCount = numel(allImageNames);

segmentationProgressBar = waitbar(0, 'Starting segmentation...');
for idx=1:imageCount
    imagePath = fullfile(datasetFolder, leafFolders(idx), allImageNames(idx));
    outName = strcat(string(idx), "-", leafFolders(idx), ".jpg");

    imageRGB = im2double(imread(imagePath));

    imageRGB = imresize(imageRGB, [1024 1024]);

    % imageRGB = enhancement(imageRGB);
    % saveImage(imageRGB, "enhanced", outName);

    maskedLeaf = createEdgeMask(imageRGB, outName);

    segmentedLeaf = imageRGB.*maskedLeaf;

    saveImage(segmentedLeaf, outputFolderSegmentedLeaves, outName);
    saveImage(maskedLeaf, outputFolderMaskedLeaves, outName);

    waitbar(idx/imageCount, segmentationProgressBar, ...
        sprintf('Progress: %d %%\n Current folder: %s', ...
        floor(idx/imageCount*100), ...
        leafFolders(idx)));
end
close(segmentationProgressBar)


function [fileNames, folders] = getNamesOfImageAndLeaf(datasetPath)
data      = struct2cell(dir(fullfile(datasetPath, "**", "*.jpg"))).';
fileNames = data(:,1);
[~, f]    = fileparts(data(:,2));
folders   = string(f);
end

function saveImage(image, outputFolder, outputName)
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end
outputPath = fullfile(outputFolder, outputName);
imwrite(image, outputPath);
end


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

filteredImg = img_gray;

% Applica filtro gaussiano a filteredImg
gaussianFilter = fspecial('gaussian', [31 31]);
filteredImg = imfilter(filteredImg, gaussianFilter, 'replicate');

% Apply a median filter
filteredImg = medfilt2(filteredImg, [15 15]);

% Apply Canny edge detector
edges = edge(filteredImg, 'Canny', 0.15);

% % Define the size of the region to close with a circular structuring element
se = strel('disk', 15);

% % % Apply morphological closing
edges = imclose(edges, se);


% % Fill holes in the edges
edges = imfill(edges, 'holes');



% labImage = rgb2lab(imgrgb);
% img_gray = labImage(:,:,2);

% Applica un filtro mediano per ridurre il rumore (kernel 9x9)
img_gray = medfilt2(img_gray, [9, 9]);

% Calcola i bordi con i filtri:
edge_sobel   = edge(img_gray, 'Sobel');
edge_prewitt = edge(img_gray, 'Prewitt');
edge_roberts = edge(img_gray, 'Roberts');

% Somma pixel-per-pixel i risultati dei tre filtri
% (conversione in double per sommare immagini binarie)
edge_sum = double(edge_roberts) + double(edge_sobel) + double(edge_prewitt);

% Applica un'operazione di closing per connettere i bordi spezzati
se = strel('disk', 11);
edge_sum = imclose(edge_sum, se);

% Riempi eventuali buchi nella maschera
edge_sum = imfill(edge_sum, 'holes');

% Binarizza: ogni pixel > 0 diventa 1 (bordo rilevato)
mask = edge_sum > 0;


mask = mask + edges;

saveImage(mask, "masks", id);




% Rimuove le aree con meno di 1000 pixel
mask = bwareaopen(mask, 5000);
end