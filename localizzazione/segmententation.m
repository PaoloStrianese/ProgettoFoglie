close all;
clear all;
clc;

% Load existing model
load(fullfile('out','localizerModelMosaic.mat'), 'localizerModel');
disp('Loaded existing localizer.');

outputFolderSegmentedLeaves = fullfile('out', 'segmented_leaves');
outputFolderMaskedLeaves = fullfile('maschere composizioni predette');

composizioniFolder = fullfile('dataset','composizioni');
imgFiles = [dir(fullfile(composizioniFolder, '*.jpg'));];
allImageNames = {imgFiles.name};
imageCount = numel(allImageNames);


segmentationProgressBar = waitbar(0, 'Starting segmentation...');
for idx=1:imageCount
    waitbar(idx/imageCount, segmentationProgressBar, ...
        sprintf('Progress: %d %%\n Current folder: %s', ...
        floor(idx/imageCount*100)));

    imagePath = fullfile(composizioniFolder, allImageNames{idx});

    imageRGB = im2double(correctOrientation(imagePath));
    original = imageRGB;

    imageRGB = imresize(imageRGB, 0.15, "bilinear", "Antialiasing", true);

    maskedLeaf = predictMask(imageRGB, localizerModel, idx);


    maskedLeaf = imresize(maskedLeaf, [size(original,1) size(original,2)], "bilinear","Antialiasing",true);

    maskedLeaf = imopen(maskedLeaf, strel('disk', 5));
    maskedLeaf = imclose(maskedLeaf, strel('disk', 5));
    maskedLeaf = imfill(maskedLeaf, 'holes');
    maskedLeaf = imerode(maskedLeaf, strel('disk', 3));

    segmentedLeaf = original.*maskedLeaf;

    outName = strcat(string(idx), ".png");

    saveImage(segmentedLeaf, outputFolderSegmentedLeaves, outName);
    saveImage(maskedLeaf, outputFolderMaskedLeaves, outName);
end
close(segmentationProgressBar)




function saveImage(image, outputFolder, outputName)
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end
outputPath = fullfile(outputFolder, outputName);
imwrite(image, outputPath);
end
