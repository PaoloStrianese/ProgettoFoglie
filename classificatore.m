close all;
clear all;

cacheFolder = ".cache";
outputTrainTestFileName = fullfile(cacheFolder,"train-test.mat");
addpath('utils');


segmentedImagesFolderTraining = "gt_segmented";
segmentedImagesFolderTesting  = "gt_segmented";
maskImagesFolderTraining      = "gt";
maskImagesFolderTesting       = "gt";

if ~isfolder(fullfile(cacheFolder, segmentedImagesFolderTraining))
    transferFiles(segmentedImagesFolderTraining, fullfile(cacheFolder, segmentedImagesFolderTraining));
end

if ~isfolder(fullfile(cacheFolder, segmentedImagesFolderTesting))
    transferFiles(segmentedImagesFolderTesting, fullfile(cacheFolder, segmentedImagesFolderTesting));
end

if ~isfolder(fullfile(cacheFolder, maskImagesFolderTraining))
    transferFiles(maskImagesFolderTraining, fullfile(cacheFolder, maskImagesFolderTraining));
end

if ~isfolder(fullfile(cacheFolder, maskImagesFolderTesting))
    transferFiles(maskImagesFolderTesting, fullfile(cacheFolder, maskImagesFolderTesting));
end

segmentedImagesFolderTraining = fullfile(cacheFolder, segmentedImagesFolderTraining);
segmentedImagesFolderTesting  = fullfile(cacheFolder, segmentedImagesFolderTesting);
maskImagesFolderTraining      = fullfile(cacheFolder, maskImagesFolderTraining);
maskImagesFolderTesting       = fullfile(cacheFolder, maskImagesFolderTesting);


%% Extract features
[trainFeatures, trainLabels, featuresNames] = featureExtractorClassifier(...
    segmentedImagesFolderTraining,...
    maskImagesFolderTraining...
    );

[testFeatures, testLabels, ~] = featureExtractorClassifier(...
    segmentedImagesFolderTesting,...
    maskImagesFolderTesting...
    );

train = cell2struct(trainFeatures, cellstr(featuresNames), 2);
test  = cell2struct(testFeatures,  cellstr(featuresNames), 2);

train.labels = trainLabels;
test.labels  = testLabels;

save(outputTrainTestFileName, "train", "test", "featuresNames");

numFeatures = numel(featuresNames);

%combination of features and test performance
trainFeatures = cell(numFeatures);
testFeatures  = cell(numFeatures);
for i=1:numFeatures
    trainFeatures{i} = train.(featuresNames(i));
    testFeatures{i}  = test.(featuresNames(i));
end

trainFeatures = trainFeatures{:};
testFeatures  = testFeatures{:};

model = TreeBagger(200, trainFeatures, train.labels);


predTest = predict(model, trainFeatures);

cmTrain = confmat(train.labels(:),predTest(:));
figure("Name","Train");
showConfmat(cmTrain.cm_raw, cmTrain.labels);

% test
predTest = predict(model, testFeatures);

cmTest = confmat(test.labels(:),predTest(:));
figure("Name", "Test");
showConfmat(cmTest.cm_raw, cmTest.labels);

fprintf('Train Acc: %f\n', cmTrain.accuracy);
fprintf('Test Acc: %f\n', cmTest.accuracy);