function trainLocalizerMosaic(outFolder, datasetFolder, groundTruthFolder)

mosaicLeafName = 'mosaic_leaf.png';
mosaicBGName = 'mosaic_background.png';
modelFileName = fullfile(outFolder, 'modelLocalizer.mat');

if ~exist(fullfile(outFolder, mosaicLeafName), 'file') && ~exist(fullfile(outFolder, mosaicBGName), 'file')
    disp('Mosaic images not found. Generating new ones.');
    [mosaicLeaf, mosaicBG] = generateMosaicImage(mosaicLeafName, mosaicBGName, datasetFolder, groundTruthFolder, outFolder);
    disp('Mosaic images generated.');
else
    disp('Mosaic images found. Loading them.');
    mosaicLeaf = imread(fullfile(outFolder, mosaicLeafName));
    mosaicBG   = imread(fullfile(outFolder, mosaicBGName));
end

mosaicLeaf = im2double(mosaicLeaf);
mosaicBG   = im2double(mosaicBG);

% Calcolo del valore medio del colore dei pixel delle foglie
if size(mosaicLeaf, 3) == 3
    % Per un'immagine RGB, calcola la media per ciascun canale
    avgLeafColor = [mean2(mosaicLeaf(:,:,1)), mean2(mosaicLeaf(:,:,2)), mean2(mosaicLeaf(:,:,3))];
else
    % Per immagini in scala di grigi
    avgLeafColor = mean2(mosaicLeaf);
end

disp('Extracting features for training...');

leafValues = extractFeaturesLocalizer(mosaicLeaf);
bgValues = extractFeaturesLocalizer(mosaicBG);

train_values = [leafValues; bgValues];

% Normalizza i valori per il training nell'intervallo [0, 1]
train_values = normalize(train_values, 'range');

% Creiamo le etichette per il training: 1 = foglia
train_labels = ones(size(train_values, 1), 1);
nrs = size(leafValues, 1);
train_labels(nrs + 1:end) = 0;


if ~exist(outFolder, 'dir')
    mkdir(outFolder);
end

disp('Starting training...');
% Addestra il modello e salvalo insieme al valore medio del colore
modelLocalizer = TreeBagger(1200, train_values, train_labels, 'Method', 'classification', 'NumPrint', 100);
save(modelFileName, 'modelLocalizer', 'avgLeafColor', '-v7.3');
disp('Trained and saved new localizer model.');
end
