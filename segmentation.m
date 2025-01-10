close all;
clear all;

outputFolderSegmentedLeaves = "segmented_leaves";
outputFolderMaskedLeaves    = "masked_leaves";
datasetFolder               = "dataset";

[allImageNames, leafFolders] = getNamesOfImageAndLeaf(datasetFolder);

imageCount = numel(allImageNames);

segmentationProgressBar = waitbar(0, 'Starting segmentation...');
for idx=1:imageCount
    imagePath = fullfile(datasetFolder, leafFolders(idx), allImageNames(idx));

    imageRGB = im2double(imread(imagePath));

    imageRGB = imresize(imageRGB, 0.3);

    maskedLeaf = binarizeImage(imageRGB);

    maskedLeaf = enhanceMask(maskedLeaf);

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


function bw = binarizeImage(rgbImage)
imageYCbCr = rgb2ycbcr(rgbImage);
[~, cb, ~] = getChannels(imageYCbCr);
level = graythresh(cb);
bw    = im2bw(rgbImage, level); %#ok<IM2BW>
end

function [fileNames, folders] = getNamesOfImageAndLeaf(datasetPath)
data      = struct2cell(dir(fullfile(datasetPath, "**", "*.jpg"))).';
fileNames = data(:,1);
[~, f]    = fileparts(data(:,2));
folders   = string(f);
end

function [ch1, ch2, ch3] = getChannels(image)
if size(image,3) ~= 3
    error("Input image must have 3 channels.");
end
ch1 = image(:,:,1);
ch2 = image(:,:,2);
ch3 = image(:,:,3);
end

function outMask=enhanceMask(mask)
whiteCount = nnz(mask);
if whiteCount > numel(mask)/2
    mask = ~mask;
end
outMask = imclose(mask, strel('disk', 11));
% outMask = imopen(mask, strel('disk', 5));
%outMask = imfill(~outMask,"holes");
end

function saveImage(image, outputFolder, outputName)
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end
outputPath = fullfile(outputFolder, outputName);
imwrite(image, outputPath);
end

