close all;
clear all;

cacheFolder = ".cache";
outputFolderSegmentedLeaves = fullfile(cacheFolder, "segmented_leaves");
outputFolderMaskedLeaves    = fullfile(cacheFolder, "masked_leaves");
datasetFolder               = "dataset";
groundTruthFolder           = "gt";
mosaicLeafName              = 'mosaic_leaf.png';
mosaicBGName                = 'mosaic_background.png';
modelFileName               = fullfile(cacheFolder,'localizer_model.mat');

if ~exist(cacheFolder, 'dir')
    mkdir(cacheFolder);
end

[allImageNames, leafFolders] = getNamesOfImageAndLeaf(datasetFolder);

imageCount = numel(allImageNames);


if exist(modelFileName, 'file')
    % Load existing model
    load(modelFileName, 'localizerModel');
    disp('Loaded existing KNN classifier.');
else
    if ~exist(fullfile(cacheFolder,mosaicLeafName), 'file') && ~exist(fullfile(cacheFolder,mosaicBGName), 'file')
        disp('Mosaic images not found. Generating new ones.');
        [leaf_img, bg_img] = generateMosaicImage(mosaicLeafName, mosaicBGName, datasetFolder, groundTruthFolder, cacheFolder);
    else
        disp('Mosaic images found. Loading them.');
        leaf_img = imread(fullfile(cacheFolder, mosaicLeafName));
        bg_img   = imread(fullfile(cacheFolder, mosaicBGName));
    end

    leaf_img = im2double(leaf_img);
    bg_img   = im2double(bg_img);

    disp('Extracting features for training...');
    % Estrazione dei dati RGB da ogni pixel
    rgb_leaf = reshape(leaf_img, [], 3);
    rgb_bg   = reshape(bg_img, [], 3);

    % Convert to HSV
    hsv_leaf = rgb2hsv(rgb_leaf);
    hsv_bg   = rgb2hsv(rgb_bg);

    % Convert to Lab
    lab_leaf = rgb2lab(rgb_leaf);
    lab_bg   = rgb2lab(rgb_bg);

    % Concateniamo i dati in un unico array per l'addestramento
    train_values = [rgb_leaf, hsv_leaf, lab_leaf;
        rgb_bg, hsv_bg, lab_bg];

    % Creiamo le etichette per il training: 1 = foglia
    train_labels = ones(size(train_values, 1), 1);
    nrs = size(rgb_leaf*3, 1);
    train_labels(nrs + 1:end) = 0;

    % Train and save new model
    localizerModel = fitcknn(train_values, train_labels);
    save(modelFileName, 'localizerModel');
    disp('Trained and saved new localizer model.');
end


segmentationProgressBar = waitbar(0, 'Starting segmentation...');
for idx=1:imageCount
    imagePath = fullfile(datasetFolder, leafFolders(idx), allImageNames(idx));

    imageRGB = im2double(imread(imagePath));

    imageRGB = imresize(imageRGB, [512*2 512*2]);

    maskedLeaf = classify_knn(imageRGB, localizerModel, idx);

    maskedLeaf = imopen(maskedLeaf, strel('disk', 5));

    % Prendi la regione più grossa nella maschera
    cc = bwconncomp(maskedLeaf);
    numPixels = cellfun(@numel, cc.PixelIdxList);
    [~, idxMax] = max(numPixels);
    maskedLeaf = false(size(maskedLeaf));
    maskedLeaf(cc.PixelIdxList{idxMax}) = true;

    segmentedLeaf = imageRGB.*maskedLeaf;

    outName = strcat(string(idx), "-", leafFolders(idx), ".jpg");

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

