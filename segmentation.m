clear all;
close all;
clear;
clc;

% Cartelle di output e input
outputFolderSegmentedLeaves = "segmented_leaves";
outputFolderMaskedLeaves    = "masked_leaves";
datasetFolder               = "dataset";

[allImageNames, leafFolders] = getNamesOfImageAndLeaf(datasetFolder);
imageCount = numel(allImageNames);

segmentationProgressBar = waitbar(0, 'Starting segmentation...');

for idx = 1:imageCount
    % Costruzione del path per l'immagine corrente
    imagePath = fullfile(datasetFolder, leafFolders(idx), allImageNames(idx));
    imageRGB = im2double(imread(imagePath));

    % Nome del file di output
    outName = strcat(string(idx), "-", leafFolders(idx), ".jpg");
    
    % Ridimensionamento e enhancement dell'immagine
    imageRGB = imresize(imageRGB, [1024 1024]);
    %imageRGB = enhancement(imageRGB);
    %saveImage(imageRGB, "enhanced", outName);

    % Conversione in scala di grigi
    imageGray = rgb2gray(imageRGB);
    
% Applicazione di un filtro Sobel per il rilevamento dei bordi
sobelEdges = imfilter(imageGray, fspecial('sobel'));

% Creazione dell'immagine binaria dei bordi con una soglia
edgeThreshold = 0.1;  % Puoi regolare questo valore per controllare il risultato
edges = sobelEdges > edgeThreshold;

% Operazione di chiusura morfologica con un elemento strutturante circolare
se = strel('disk', 3);
edges = imclose(edges, se);

% Riempimento dei buchi nei bordi
edges = imfill(edges, 'holes');

% Rilevamento dei componenti connessi
cc = bwconncomp(edges);

% Calcolo delle aree dei componenti
stats = regionprops(cc, 'Area');

% Definizione della soglia per le aree minime
minArea = 500;

% Creazione di un'immagine binaria con solo i componenti grandi
largeComponents = ismember(labelmatrix(cc), find([stats.Area] >= minArea));

% Aggiornamento dell'immagine dei bordi per includere solo i componenti grandi
edges = largeComponents;

    
    % Creazione della maschera dei bordi
    maskedLeaf = edges;
    
    % Applicazione della maschera all'immagine originale
    segmentedLeaf = imageRGB .* repmat(maskedLeaf, [1 1 3]);
    
    % Salvataggio delle immagini segmentate e delle maschere
    saveImage(segmentedLeaf, outputFolderSegmentedLeaves, outName);
    saveImage(maskedLeaf, outputFolderMaskedLeaves, outName);
    
    waitbar(idx/imageCount, segmentationProgressBar, ...
        sprintf('Progress: %d %%\n Current folder: %s', floor(idx/imageCount*100), leafFolders(idx)));
end
close(segmentationProgressBar)

%% Funzione per ottenere i nomi delle immagini e dei rispettivi folder
function [fileNames, folders] = getNamesOfImageAndLeaf(datasetPath)
    data      = struct2cell(dir(fullfile(datasetPath, "**", "*.jpg"))).';
    fileNames = data(:,1);
    [~, f]    = fileparts(data(:,2));
    folders   = string(f);
end

%% Funzione per salvare un'immagine nella cartella di output
function saveImage(image, outputFolder, outputName)
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end
    outputPath = fullfile(outputFolder, outputName);
    imwrite(image, outputPath);
end
