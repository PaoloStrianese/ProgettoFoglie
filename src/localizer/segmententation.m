close all;
clear all;
clc;

addpath(genpath(fullfile('..', 'utils')));
outFolder = "out";
cacheFolder = fullfile(outFolder, 'cache');
outputFolderMaskedLeaves     = fullfile(outFolder, 'maschere composizioni predette');
groundTruthFolderMaskedCompositions = fullfile('..','dataset','gt_compositions');
datasetFolder = fullfile('..','dataset','single_leaves');
groundTruthFolder = fullfile('..','dataset','gt_single_leaves');


if ~exist(outFolder, 'dir')
    mkdir(outFolder);
end

disp('Training with mosaic images.');
trainLocalizerMosaic(outFolder, datasetFolder, groundTruthFolder);

% Load the existing model and the average color of the leaves
load(fullfile(outFolder,'modelLocalizer.mat'), 'modelLocalizer', 'avgLeafColor');
disp('Loaded existing localizer.');

composizioniFolder = fullfile('..','dataset','compositions');
imgFiles = dir(fullfile(composizioniFolder, '*.jpg'));
allImageNames = {imgFiles.name};
imageCount = numel(allImageNames);

segmentationProgressBar = waitbar(0, 'Starting segmentation...', 'Name', 'Segmentation Progress');
for idx = 1:imageCount
    waitbar(idx/imageCount, segmentationProgressBar, ...
        sprintf('Progress: %d %%', floor(idx/imageCount*100)));

    disp("Processing image " + string(idx) + " of " + string(imageCount));

    imagePath = fullfile(composizioniFolder, allImageNames{idx});
    [~, name, ~] = fileparts(allImageNames{idx});
    outName = strcat(name, ".png");

    imageRGB = im2double(correctOrientation(imagePath));
    original = imageRGB;

    % Ridimensiona per il processing (opzionale)
    imageRGB = imresize(imageRGB, 0.6, "bilinear", "Antialiasing", true);
    imageRGBKNN = imresize(imageRGB, 0.1, "bilinear", "Antialiasing", true);

    %% Maschera ottenuta con Canny
    disp("Generating Canny Mask...");
    maskCanny = createEdgeMask(imageRGB);

    % Elaborazione per rimuovere le regioni che si discostano troppo dal colore medio
    cc = bwconncomp(maskCanny);
    threshold = 0.4;  % Soglia di varianza (modifica questo valore secondo necessità)
    numPixels = numel(maskCanny);  % Numero di pixel per un singolo canale

    for i = 1:cc.NumObjects
        regionIdx = cc.PixelIdxList{i};
        % Calcola il valore medio per ogni canale
        if size(imageRGB, 3) == 3
            meanR = mean(imageRGB(regionIdx));
            meanG = mean(imageRGB(regionIdx + numPixels));
            meanB = mean(imageRGB(regionIdx + 2*numPixels));
            regionMean = [meanR, meanG, meanB];
        else
            regionMean = mean(imageRGB(regionIdx));
        end

        % Calcola la differenza dalla media delle foglie salvata
        diff = norm(regionMean - avgLeafColor);

        if diff > threshold

            % Se la differenza supera la soglia, azzera l'intera regione
            maskCanny(regionIdx) = 0;
        end
    end

    % Applica la maschera Canny modificata all'immagine
    segmentedLeafCanny = imageRGB .* maskCanny;
    disp("Canny Mask Created");

    %% Segmentazione basata sul modello predetto (KNN)
    disp("Generating KNN Mask...");
    predictedMaskedLeaf = predictMask(imageRGBKNN, modelLocalizer);
    predictedMaskedLeaf = imresize(predictedMaskedLeaf, [size(original,1) size(original,2)], "bilinear", "Antialiasing", true);
    disp("KNN resized");

    % Operazioni morfologiche per migliorare la maschera KNN
    predictedMaskedLeaf = imopen(predictedMaskedLeaf, strel('disk', 5));
    predictedMaskedLeaf = imclose(predictedMaskedLeaf, strel('disk', 5));
    predictedMaskedLeaf = imfill(predictedMaskedLeaf, 'holes');
    predictedMaskedLeaf = imerode(predictedMaskedLeaf, strel('disk', 5));

    % Ridimensiona la maschera Canny alla dimensione originale
    maskCanny = imresize(maskCanny, [size(original,1), size(original,2)], "bilinear", "Antialiasing", true);
    disp("Canny resized");

    % Combina le due maschere per ottenere la maschera finale e rimuovere le imperfezioni
    finalMask = maskCanny & predictedMaskedLeaf;
    disp("Creating Final Mask...");


    segmentedLeaf = original .* finalMask;

    % Salva le immagini risultanti
    % outputFolderSegmentedLeaves = fullfile(outFolder, 'segmented_leaves');
    % outputFolderSegmentedLeavesC = fullfile(outFolder, 'segmented_leaves_canny');
    % saveImage(segmentedLeaf, outputFolderSegmentedLeaves, outName);
    % saveImage(segmentedLeafCanny, outputFolderSegmentedLeavesC, outName);
    saveImage(finalMask, outputFolderMaskedLeaves, outName);
end
close(segmentationProgressBar)

localizerAccuracy(outputFolderMaskedLeaves, groundTruthFolderMaskedCompositions);