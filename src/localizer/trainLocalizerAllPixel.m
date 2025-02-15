function trainLocalizerAll(outFolder, datasetFolder, groundTruthFolder, allImageNames, leafFolders, imageCount)
modelFileName = fullfile(outFolder, 'localizer_model.mat');

% Define separate height and width
height = 128;
width  = 128;
features = 14; % RGB HSV LAB YCbCr
labels = 1;
train_values = zeros(imageCount * height * width, features);
train_labels = zeros(imageCount * height * width, labels);

segmentationProgressBar = waitbar(0, 'Starting segmentation...');
for idx = 1:imageCount
    imagePath = fullfile(datasetFolder, leafFolders(idx), allImageNames(idx));
    imageNamePNG = replace(allImageNames(idx), '.jpg', '.png');
    gtPath = fullfile(groundTruthFolder, leafFolders(idx), imageNamePNG);

    imageRGB = correctOrientation(imagePath);
    gt = correctOrientation(gtPath);

    imageRGB = imresize(imageRGB, [height width]);
    gt       = imresize(gt, [height width]);

    imageRGB = reshape(imageRGB, height * width, 3);
    gt = reshape(gt, 1, []);

    allFeatures = extractFeaturesLocalizer(imageRGB);

    pixelCount = height * width;
    train_values((idx-1)*pixelCount+1 : idx*pixelCount, :) = allFeatures;
    train_labels((idx-1)*pixelCount+1 : idx*pixelCount) = gt;

    waitbar(idx/imageCount, segmentationProgressBar, ...
        sprintf('Progress: %d %%\n Current folder: %s', ...
        floor(idx/imageCount*100), ...
        leafFolders(idx)));
end
close(segmentationProgressBar)

% Normalize training values to the range [0, 1]
train_values = normalize(train_values, 'range');

perm = randperm(size(train_values, 1));
train_values = train_values(perm, :);

% save(fullfile(cacheFolder, 'train_values_loc.mat'), 'train_values');
% save(fullfile(cacheFolder, 'train_labels_loc.mat'), 'train_labels');

disp('Starting training...');
% Train and save new model
localizerModel = TreeBagger(50, train_values, train_labels, 'Method', 'classification', 'NumPrint', 1);
save(modelFileName, 'localizerModel', '-v7.3');
disp('Trained and saved new localizer model.');
end

