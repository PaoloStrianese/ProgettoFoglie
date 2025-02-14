close all;
clear all;

TRAIN_WITH_MOSAIC = true;
TRAIN_WITHOUT_MOSAIC = false;


outFolder = "out";
datasetFolder = fullfile('dataset','foglie_singole');
groundTruthFolder = fullfile('dataset','gt_foglie_singole');

if ~exist(outFolder, 'dir')
    mkdir(outFolder);
end

[allImageNames, leafFolders] = getNamesOfImageAndLeaf(datasetFolder);

imageCount = numel(allImageNames);


if (TRAIN_WITHOUT_MOSAIC == true) && (TRAIN_WITH_MOSAIC == false)
    disp('Training without mosaic images but with the whole dataset.');
    trainLocalizerAll(outFolder, datasetFolder, groundTruthFolder, allImageNames, leafFolders, imageCount);
end

if (TRAIN_WITH_MOSAIC == true) && (TRAIN_WITHOUT_MOSAIC == false)
    disp('Training with mosaic images.');
    trainLocalizerMosaic(outFolder, datasetFolder, groundTruthFolder);
end

if (TRAIN_WITH_MOSAIC == true) && (TRAIN_WITHOUT_MOSAIC == true) || (TRAIN_WITH_MOSAIC == false) && (TRAIN_WITHOUT_MOSAIC == false)
    disp('Scegliere se fare il training con i mosaici o senza.');
    return;
end

function [fileNames, folders] = getNamesOfImageAndLeaf(datasetPath)
data      = struct2cell(dir(fullfile(datasetPath, "**", "*.jpg"))).';
fileNames = data(:,1);
[~, f]    = fileparts(data(:,2));
folders   = string(f);
end
