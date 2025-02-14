close all;
clear;
clc;

outputFolderSegmentedLeaves = fullfile('.cache', "1segmented_leaves");
if ~exist(outputFolderSegmentedLeaves, 'dir')
    mkdir(outputFolderSegmentedLeaves);
end

outputFolderMaskedLeaves = fullfile('.cache', "canny_comp");
if ~exist(outputFolderMaskedLeaves, 'dir')
    mkdir(outputFolderMaskedLeaves);
end


datasetPath = fullfile('.cache', 'Composizioni Dataset2');
images = dir(fullfile(datasetPath, "*.jpg"));
imageCount = numel(images);

load(fullfile('.cache',"localizer_model.mat"), "localizerModel");



segmentationProgressBar = waitbar(0, 'Starting segmentation...');
for idx=1:imageCount
    imagePath = fullfile(datasetPath,images(idx).name);

    outName = strcat(string(idx), ".png");

    imageRGB = im2double(correctOrientation(imagePath));
    imageRGB = correggiBilanciamentoBianco(imageRGB);
    imageRGB = imresize(imageRGB, 1, "nearest");


    maskedLeaf = createEdgeMask(imageRGB, outName);

    imwrite(maskedLeaf, fullfile('fase 1',  outName));

    segmentedLeaf = imageRGB.*maskedLeaf;


    imwrite(segmentedLeaf, fullfile('fase 2',  outName));

    maskedLeaf = predictMask(segmentedLeaf, localizerModel, idx);

    imwrite(maskedLeaf, fullfile(outputFolderMaskedLeaves,  outName));

    segmentedLeaf = imageRGB.*maskedLeaf;

    imwrite(segmentedLeaf, fullfile(outputFolderSegmentedLeaves, outName));


    waitbar(idx/imageCount, segmentationProgressBar, ...
        sprintf('Progress: %d %%\n Current folder: %s', ...
        floor(idx/imageCount*100)));
end
close(segmentationProgressBar)


function [fileNames, folders] = getNamesOfImageAndLeaf(datasetPath)
data      = struct2cell(dir(fullfile(datasetPath, "**", "*.jpg"))).';
fileNames = data(:,1);
[~, f]    = fileparts(data(:,2));
folders   = string(f);
end

