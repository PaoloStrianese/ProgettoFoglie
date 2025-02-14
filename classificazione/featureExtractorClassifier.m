function [combinedFeaturesContainers, labels, featuresNames] = featureExtractorClassifier(...
    segmentedImagesFolder, maskImagesFolder, varargin)

if nargin < 3 || isempty(varargin{1})
    segmentedResizeFactor = 1;
else
    segmentedResizeFactor = varargin{1};
end

if nargin < 4 || isempty(varargin{2})
    maskResizeFactor = 1;
else
    maskResizeFactor = varargin{2};
end

segmentedPaths = getImagePathsFromFolder(segmentedImagesFolder);
maskPaths      = getImagePathsFromFolder(maskImagesFolder);
labels         = getLabelsFromFolder(segmentedImagesFolder);
imagesCount    = numel(labels);

assert(imagesCount == numel(maskPaths), "Number of segmented and mask images must be equal");
assert(imagesCount == numel(segmentedPaths), "Number of images and labels must be equal");

[segmentedFunctions, maskFunctions, segmentedFeatures, maskFeatures, featuresNames] = setupExtractionClassifier(imagesCount);

%% Extract features from every image
featureExtractionProgressBar = waitbar(0, "Starting features extraction...");
set(featureExtractionProgressBar, "Name", segmentedImagesFolder);
for i = 1:imagesCount
    waitbar(i/imagesCount, featureExtractionProgressBar, ...
        sprintf("Progress: %d %%\n%s", floor(i/imagesCount*100), labels(i)));

    % Extract segmented features
    segmentedImage = im2double(imread(segmentedPaths{i}));
    segmentedImage = imresize(segmentedImage, segmentedResizeFactor);

    for j = 1:numel(segmentedFunctions)
        segmentedFeatures{j}(i, :) = segmentedFunctions{j}(segmentedImage);
    end

    % Extract mask features
    maskImage = im2double(imread(maskPaths{i}));
    maskImage = imresize(maskImage, maskResizeFactor);

    for j = 1:numel(maskFunctions)
        maskFeatures{j}(i, :) = maskFunctions{j}(maskImage);
    end
end
close(featureExtractionProgressBar);

combinedFeaturesContainers = [segmentedFeatures, maskFeatures];

%% Normalize features
for i = 1:numel(combinedFeaturesContainers)
    combinedFeaturesContainers{i} = normalize(combinedFeaturesContainers{i}, "range");
end
end

function paths = getImagePathsFromFolder(folder)
files = dir(fullfile(folder, "*.png"));
names = {files.name};
paths = fullfile(folder, names);
end


function labels = getLabelsFromFolder(folder)
files = dir(fullfile(folder, "*.png"));
labels = strings(numel(files), 1);
for idx = 1:numel(files)
    parts   = split(files(idx).name, "-");
    %nameExt = split(parts(2), ".");
    labels(idx) = string(parts(1));
end
end