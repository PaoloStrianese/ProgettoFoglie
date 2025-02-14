close all;
clear all;
clc;

cacheFolder = ".cache";
outputTrainTestFileName = fullfile(cacheFolder,"train-test.mat");
addpath('utils');

showBestFeatures = true;
showPrediction = true;
reExtractFeatures = true;
reTrainClassificator = true;

precisionClassifier = false;

RESIZE_FACTOR_SEGMENTATE_TRAIN = 1;
RESIZE_FACTOR_MASK_TRAIN = 1;

RESIZE_FACTOR_SEGMENTATE_TEST = 1;
RESIZE_FACTOR_MASK_TEST = 1;

segmentedImagesFolderTraining = "gt_segmentate_dataset_nuovo_croppate";
segmentedImagesFolderTesting  = "gt_segmentate_composizioni";
maskImagesFolderTraining      = "gt_maschere_dataset_nuovo_croppate";
maskImagesFolderTesting       = "gt_maschere_composizioni";

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

if ~exist(outputTrainTestFileName) || reExtractFeatures


    %% Extract features
    [trainFeatures, trainLabels, featuresNames] = featureExtractorClassifier(...
        segmentedImagesFolderTraining,...
        maskImagesFolderTraining,...
        RESIZE_FACTOR_SEGMENTATE_TRAIN,...
        RESIZE_FACTOR_MASK_TRAIN);

    [testFeatures, testLabels, ~] = featureExtractorClassifier(...
        segmentedImagesFolderTesting,...
        maskImagesFolderTesting,...
        RESIZE_FACTOR_SEGMENTATE_TEST,...
        RESIZE_FACTOR_MASK_TEST);

    train = cell2struct(trainFeatures, cellstr(featuresNames), 2);
    test  = cell2struct(testFeatures,  cellstr(featuresNames), 2);


    train.labels = trainLabels;
    test.labels  = testLabels;

    save(outputTrainTestFileName, "train", "test", "featuresNames");
end

load(outputTrainTestFileName);


numFeatures = numel(featuresNames);


trainFeatures = cell(1, numFeatures);
testFeatures  = cell(1, numFeatures);
for i = 1:numFeatures
    trainFeatures{i} = train.(featuresNames{i});
    testFeatures{i}  = test.(featuresNames{i});
end

trainFeatures = [trainFeatures{:}];
testFeatures  = [testFeatures{:}];


if reTrainClassificator

    if ~precisionClassifier
        model = TreeBagger(1200, trainFeatures, train.labels, 'OOBPrediction', 'on', 'OOBPredictorImportance', 'on','MinLeafSize', 1,'NumPrint',200);
    else
        % trova lui iparametri ottimali classificatore
        t = templateTree('Reproducible',true);
        model = fitcensemble(trainFeatures, train.labels,'OptimizeHyperparameters','auto','Learners',t,...
            'Learners', t);
    end
    save(fullfile(cacheFolder,"model.mat"), "model");
else
    load(fullfile(cacheFolder,"model.mat"));
end



if showBestFeatures
    [~, ~, segmentedFeatures, maskFeatures, featureNames] = setupExtractionClassifier(1);
    combinedFeatures = [segmentedFeatures, maskFeatures];

    % Create labels for each feature based on its corresponding extraction
    featureLabels = arrayfun(@(idx) ...
        repmat(featureNames(idx), size(combinedFeatures{idx}, 2), 1), ...
        1:numel(combinedFeatures), 'UniformOutput', false);
    featureLabels = vertcat(featureLabels{:});

    % Compute predictor importance using the out-of-bag error estimates
    importanceScores =  model.OOBPermutedPredictorDeltaError;
    % Plot the feature importance
    figure;
    bar(importanceScores);
    xticks(1:numel(importanceScores));
    xticklabels(featureLabels);
    xlabel('Feature');
    ylabel('Importance');
    title('Predictor Importance');

    figure;
    plot(model.oobError);
    xlabel('Number of Trees');
    ylabel('Out-of-Bag Classification Error');
    title('OOB Error vs. Number of Trees');
end

if showPrediction
    % predTest = predict(model, trainFeatures);

    % cmTrain = confmat(train.labels(:),predTest(:));
    % figure("Name","Train");
    % showConfmat(cmTrain.cm_raw, cmTrain.labels);
    %fprintf('Train Acc: %f\n', cmTrain.accuracy);

    % test
    predTest = predict(model, testFeatures);

    cmTest = confmat(test.labels(:),predTest(:));
    figure("Name", "Test");
    showConfmat(cmTest.cm_raw, cmTest.labels);


    fprintf('Test Acc: %f\n', cmTest.accuracy);
end