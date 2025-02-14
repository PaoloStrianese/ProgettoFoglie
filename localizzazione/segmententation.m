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

    imageRGB = im2double(imread(imagePath));

    imageRGB = imresize(imageRGB, 0.1);

    maskedLeaf = predictMask(imageRGB, localizerModel, idx);

    % maskedLeaf = imopen(maskedLeaf, strel('disk', 11));


    segmentedLeaf = imageRGB.*maskedLeaf;


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
