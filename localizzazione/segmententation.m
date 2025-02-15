close all;
clear all;
clc;

% Carica il modello esistente e la media dei colori delle foglie
load(fullfile('out','localizerModelMosaic.mat'), 'localizerModel', 'avgLeafColor');
disp('Loaded existing localizer.');

outputFolderSegmentedLeaves  = fullfile('out', 'segmented_leaves');
outputFolderSegmentedLeavesC = fullfile('out', 'segmented_leavesC');
outputFolderMaskedLeaves     = fullfile('maschere composizioni predette');

composizioniFolder = fullfile('dataset','composizioni');
imgFiles = dir(fullfile(composizioniFolder, '*.jpg'));
allImageNames = {imgFiles.name};
imageCount = numel(allImageNames);

segmentationProgressBar = waitbar(0, 'Starting segmentation...');
for idx = 1:imageCount
    waitbar(idx/imageCount, segmentationProgressBar, ...
        sprintf('Progress: %d %%', floor(idx/imageCount*100)));

    imagePath = fullfile(composizioniFolder, allImageNames{idx});
    outName = strcat(string(idx), ".png");

    imageRGB = im2double(correctOrientation(imagePath));
    original = imageRGB;
    
    % Ridimensiona per il processing (opzionale)
    imageRGB = imresize(imageRGB, 0.5, "bilinear", "Antialiasing", true);
    
    %% Maschera ottenuta con Canny
    disp("Generating Canny Mask...");
    maskCanny = createEdgeMask(imageRGB, outName);
    
    % Elaborazione per rimuovere le regioni che si discostano troppo dal colore medio
    cc = bwconncomp(maskCanny);
    threshold = 0.5;  % Soglia di varianza (modifica questo valore secondo necessità)
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
    maskedLeaf = predictMask(imageRGB, localizerModel);
    maskedLeaf = imresize(maskedLeaf, [size(original,1) size(original,2)], "bilinear", "Antialiasing", true);
    disp("KNN resized");
    
    % Operazioni morfologiche per migliorare la maschera KNN
    maskedLeaf = imopen(maskedLeaf, strel('disk', 5));
    maskedLeaf = imclose(maskedLeaf, strel('disk', 5));
    maskedLeaf = imfill(maskedLeaf, 'holes');
    maskedLeaf = imerode(maskedLeaf, strel('disk', 3));
    
    % Ridimensiona la maschera Canny alla dimensione originale
    maskCanny_resized = imresize(maskCanny, [size(original,1), size(original,2)], "bilinear", "Antialiasing", true);
    disp("Canny resized");
    
    % Combina le due maschere per ottenere la maschera finale e rimuovere le imperfezioni
    finalMask = maskCanny_resized & maskedLeaf;
    disp("Creating Final Mask...");
    
    % Applica la maschera finale all'immagine originale
    segmentedLeaf = original .* finalMask;
    
    % Salva le immagini risultanti
    saveImage(segmentedLeaf, outputFolderSegmentedLeaves, outName);
    saveImage(segmentedLeafCanny, outputFolderSegmentedLeavesC, outName);
    saveImage(maskedLeaf, outputFolderMaskedLeaves, outName);
end
close(segmentationProgressBar)
