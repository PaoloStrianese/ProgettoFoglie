close all;
clear all;

featuresExtractorFolder = "feature_extractors";
segmentedImagesFolder   = "segmented_leaves";
maskImagesFolder        = "masked_leaves";
outputTrainTestFileName = "train-test.mat";

addpath("utils", genpath(featuresExtractorFolder));

% Collect image paths and labels
segmentedPaths = getImagePathsFromFolder(segmentedImagesFolder);
maskPaths      = getImagePathsFromFolder(maskImagesFolder);
labels         = getLabelsFromFolder(segmentedImagesFolder);
imagesCount    = numel(labels);

% Segmented feature extractors and preallocate storage
segmentedFunctions = { ...
    @extractLBP, ...
    @extractGLCM, ...
    % @extractTexture, ...
    % @extractShape, ...
    % @extractColor
    };
segmentedFeatures  = {
    zeros(imagesCount, 59), ... % LBP
    zeros(imagesCount, 64)    % GLCM
    };

% Mask feature extractors and preallocate storage
maskFunctions = { ...
    @extractHuMoments,
    % @extractArea, ...
    % @extractPerimeter, ...
    % @extractCentroid
    };
maskFeatures  = {
    zeros(imagesCount, 7)   % Hu Moments
    };


assert(numel(segmentedFunctions) == numel(segmentedFeatures), ...
    "Mismatch in segmented features arrays.");
assert(numel(maskFunctions) == numel(maskFeatures), ...
    "Mismatch in mask features arrays.");

featureExtractionProgressBar = waitbar(0, "Starting features extraction...");
for i = 1:imagesCount

    % Read segmented image
    segmentedImage = im2double(imread(segmentedPaths(i)));
    segmentedImage = imresize(segmentedImage, 0.1);

    % Read mask image
    maskImage = im2double(imread(maskPaths(i)));
    maskImage = imresize(maskImage, 0.1);

    for j = 1:numel(segmentedFunctions)
        segmentedFeatures{j}(i, :) = segmentedFunctions{j}(segmentedImage);
    end
    for j = 1:numel(maskFunctions)
        maskFeatures{j}(i, :) = maskFunctions{j}(maskImage);
    end

    waitbar(i/imagesCount, featureExtractionProgressBar, ...
        sprintf("Progress: %d %%\n%s", floor(i/imagesCount*100), labels(i)));
end
close(featureExtractionProgressBar);

% Extract feature names from function names: extractABC -> ABC
segmentedNames = string(cellfun(@(f) strrep(func2str(f), "extract", ""), ...
    segmentedFunctions, "UniformOutput", false));
maskNames      = string(cellfun(@(f) strrep(func2str(f), "extract", ""), ...
    maskFunctions, "UniformOutput", false));

% Combine mask and segmented features
combinedFeaturesContainers = [segmentedFeatures, maskFeatures];
featuresNames    = [segmentedNames, maskNames];

% Normalize features
for i = 1:numel(combinedFeaturesContainers)
    combinedFeaturesContainers{i} = normalize(combinedFeaturesContainers{i}, "range");
end

% qua sarebbe meglio fare il kfold per la cross validation nel training visto la poca quantità di foglie
CV = cvpartition(labels, "HoldOut", 0.1);

train = struct();
test = struct();

for i = 1:numel(featuresNames)
    train.(featuresNames(i)) = combinedFeaturesContainers{i}(CV.training, :);
    test.(featuresNames(i))  = combinedFeaturesContainers{i}(CV.test, :);
end

train.labels = labels(CV.training);
test.labels  = labels(CV.test);

save(outputTrainTestFileName, "train", "test", "featuresNames");


