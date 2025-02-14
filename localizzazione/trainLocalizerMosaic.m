function trainLocalizerMosaic(outFolder, datasetFolder, groundTruthFolder)

mosaicLeafName = 'mosaic_leaf.png';
mosaicBGName = 'mosaic_background.png';
modelFileName = fullfile(outFolder, 'localizerModelMosaic.mat');

if ~exist(fullfile(outFolder,mosaicLeafName), 'file') && ~exist(fullfile(outFolder,mosaicBGName), 'file')
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


disp('Extracting features for training...');

leaf_values = extractFeaturesLocalizer(mosaicLeaf);
bg_values = extractFeaturesLocalizer(mosaicBG);

train_values = [leaf_values; bg_values];

% Normalize training values to the range [0, 1]
train_values = normalize(train_values, 'range');

disp('Starting training...');
% Train and save new model
localizerModel = TreeBagger(500, train_values, train_labels, 'Method', 'classification', 'NumPrint', 50);
save(modelFileName, 'localizerModel', '-v7.3');
disp('Trained and saved new localizer model.');
end


