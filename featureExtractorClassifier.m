
function [combinedFeaturesContainers, labels, featuresNames] = featureExtractorClassifier(...
    segmentedImagesFolder,...
    maskImagesFolder, varargin)


if nargin < 3 || isempty(varargin{1})
    resizeFactor = 0.1;
else
    resizeFactor = varargin{1};
end

addpath("utils");

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
    segmentedImage = im2double(imread(segmentedPaths(i)));
    segmentedImage = imresize(segmentedImage, resizeFactor);


    for j = 1:numel(segmentedFunctions)
        segmentedFeatures{j}(i, :) = segmentedFunctions{j}(segmentedImage);
        %disp (segmentedFunctions{j});
        %disp(segmentedFeatures{j});
    end

    % Extract mask features
    maskImage = im2double(imread(maskPaths(i)));
    maskImage = imresize(maskImage, resizeFactor);

    for j = 1:numel(maskFunctions)
        maskFeatures{j}(i, :) = maskFunctions{j}(maskImage);
        %disp(maskFunctions{j});
        %disp(maskFeatures{j});
    end
end
close(featureExtractionProgressBar);

combinedFeaturesContainers = [segmentedFeatures, maskFeatures];
% for i = 1:numel(combinedFeaturesContainers)
%     disp(combinedFeaturesContainers{i});
% end


%% Normalize features
for i = 1:numel(combinedFeaturesContainers)
    combinedFeaturesContainers{i} = normalize(combinedFeaturesContainers{i}, "range");
end
end
