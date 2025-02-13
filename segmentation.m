close all;
clear all;

TRAIN_WITHOUT_MOSAIC = true;

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

if ~exist(modelFileName, 'file')
    if (TRAIN_WITHOUT_MOSAIC == true)
        disp('Training without mosaic images but with the whole dataset.');
        trainLocalizer(cacheFolder, datasetFolder, groundTruthFolder, allImageNames, leafFolders, imageCount);
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

        [ir, ic, ich] = size(leaf_img);
        leaf_img = reshape(leaf_img, ir * ic, ich);
        [ir, ic, ich] = size(bg_img);
        bg_img = reshape(bg_img, ir * ic, ich);

        disp('Extracting features for training...');

        leaf_values = extractFeaturesLocalizer(leaf_img);
        bg_values = extractFeaturesLocalizer(bg_img);

        train_values = [leaf_values; bg_values];
        % Normalize training values to the range [0, 1]
        train_values = normalize(train_values, 'range');

        % Creiamo le etichette per il training: 1 = foglia
        train_labels = ones(size(train_values, 1), 1);
        nrs = size(leaf_values, 1);
        train_labels(nrs + 1:end) = 0;

        % Train and save new model
        localizerModel = TreeBagger(100, train_values, train_labels, 'Method', 'classification');
        save(modelFileName, 'localizerModel');
        disp('Trained and saved new localizer model.');
    end
end

% Load existing model
load(modelFileName, 'localizerModel');
disp('Loaded existing localizer.');


segmentationProgressBar = waitbar(0, 'Starting segmentation...');
for idx=1:imageCount
    waitbar(idx/imageCount, segmentationProgressBar, ...
        sprintf('Progress: %d %%\n Current folder: %s', ...
        floor(idx/imageCount*100), ...
        leafFolders(idx)));

    imagePath = fullfile(datasetFolder, leafFolders(idx), allImageNames(idx));

    imageRGB = im2double(imread(imagePath));

    imageRGB = correggiBilanciamentoBianco(imageRGB);

    imageRGB = imresize(imageRGB, [256 256]);

    maskedLeaf = predictMask(imageRGB, localizerModel, idx);

    maskedLeaf = imopen(maskedLeaf, strel('disk', 11));

    %Prendi la regione più grossa nella maschera
    cc = bwconncomp(maskedLeaf);
    numPixels = cellfun(@numel, cc.PixelIdxList);
    [~, idxMax] = max(numPixels);
    maskedLeaf = false(size(maskedLeaf));
    maskedLeaf(cc.PixelIdxList{idxMax}) = true;

    segmentedLeaf = imageRGB.*maskedLeaf;

    value = mod(idx,10) + 1;
    if value < 10
        imageName = sprintf('0%d', value);
    else
        imageName = sprintf('%d', value);
    end
    outName = strcat(leafFolders(idx), "-","0",imageName , ".png");

    saveImage(segmentedLeaf, outputFolderSegmentedLeaves, outName);
    saveImage(maskedLeaf, outputFolderMaskedLeaves, outName);
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

