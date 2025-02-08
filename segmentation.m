close all;
clear;
clc;

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

    imageRGB = imresize(imageRGB, [2048 2048]);

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

