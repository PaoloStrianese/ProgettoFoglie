function trainLocalizer(cacheFolder, datasetFolder, groundTruthFolder, allImageNames, leafFolders, imageCount)
modelFileName = fullfile(cacheFolder, 'localizer_model.mat');

% Define separate height and width
height = 128;
width  = 128;
features = 2; % RGB HSV LAB YCbCr
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
localizerModel = TreeBagger(5, train_values, train_labels, 'Method', 'classification');
save(modelFileName, 'localizerModel');
disp('Trained and saved new localizer model.');
end

function imgCorrected = correctOrientation(imagePath)
info = imfinfo(imagePath);
imgCorrected = imread(imagePath);
if isfield(info, 'Orientation')
    switch info.Orientation
        case 1  % Normal, no rotation needed.
            return;
        case 3  % 180 degree rotation.
            imgCorrected = imrotate(imgCorrected, 180);
        case 6  % 90 degrees clockwise.
            imgCorrected = imrotate(imgCorrected, -90);
        case 8  % 90 degrees counterclockwise.
            imgCorrected = imrotate(imgCorrected, 90);
        otherwise
            warning('Orientation %d not specifically handled.', info.Orientation);
    end
end
end
