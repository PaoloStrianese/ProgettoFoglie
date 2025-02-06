close all;
clear;

outputFolderSegmentedLeaves = "segmented_leaves";
outputFolderMaskedLeaves    = "masked_leaves";
datasetFolder               = "dataset";

[allImageNames, leafFolders] = getNamesOfImageAndLeaf(datasetFolder);

imageCount = numel(allImageNames);

% Caricamento e conversione dei dati da Excel
[rgb_leaf, rgb_bg] = load_and_convert_excel_data();
disp('Dati RGB caricati da Excel.');

% Riduzione dei dati per il training
rgb_leaf = rgb_leaf(:, :);
rgb_bg = rgb_bg(:, :);

% Concateniamo i dati in un unico array per l'addestramento
train_values = [rgb_leaf; rgb_bg];

% Creiamo le etichette per il training: 1 = foglia
train_labels = ones(size(train_values, 1), 1);
nrs = size(rgb_leaf, 1);
train_labels(nrs + 1:end) = 0;

modelFileName = 'knn_classifier_model.mat';
if exist(modelFileName, 'file')
    % Load existing model
    load(modelFileName, 'classifier_knn');
    disp('Loaded existing KNN classifier.');
else
    % Train and save new model
    classifier_knn = fitcknn(train_values, train_labels, 'NumNeighbors', 11);
    save(modelFileName, 'classifier_knn');
    disp('Trained and saved new KNN classifier.');
end


segmentationProgressBar = waitbar(0, 'Starting segmentation...');
for idx=1:imageCount
    imagePath = fullfile(datasetFolder, leafFolders(idx), allImageNames(idx));

    imageRGB = im2double(imread(imagePath));

    imageRGB = imresize(imageRGB, [512*2 512*2]);

    maskedLeaf = classify_knn(imageRGB, classifier_knn, idx);

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

