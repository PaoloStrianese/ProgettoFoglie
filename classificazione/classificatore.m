close all;
clear all;
clc;


mainFolder = "data";
segmentedImagesFolderTraining = fullfile(mainFolder,"gt_segmentate_dataset");
segmentedImagesFolderTesting  = fullfile(mainFolder,"gt_segmentate_composizioni");
maskImagesFolderTraining      = fullfile(mainFolder,"gt_maschere_dataset");
maskImagesFolderTesting       = fullfile(mainFolder,"gt_maschere_composizioni");

outFolder = "out";
if ~exist(outFolder, 'dir')
    mkdir(outFolder);
end

foo = "features.mat";
modelName = "model.mat";
outputTrainTestFileName = fullfile(outFolder, foo);

RESIZE_FACTOR_SEGMENTATE_TRAIN = 0.2;
RESIZE_FACTOR_MASK_TRAIN = 0.2;

RESIZE_FACTOR_SEGMENTATE_TEST = 0.7;
RESIZE_FACTOR_MASK_TEST = 0.7;



% Estrai le feature e le etichette per il set di training
[trainFeatures, trainLabels, featuresNames] = featureExtractorClassifier( ...
    segmentedImagesFolderTraining, maskImagesFolderTraining, ...
    RESIZE_FACTOR_SEGMENTATE_TRAIN, RESIZE_FACTOR_MASK_TRAIN);

% Estrai le feature e le etichette per il set di testing
[testFeatures, testLabels, ~] = featureExtractorClassifier( ...
    segmentedImagesFolderTesting, maskImagesFolderTesting, ...
    RESIZE_FACTOR_SEGMENTATE_TEST, RESIZE_FACTOR_MASK_TEST);

% Organizza le feature in strutture per un accesso agevole
train = cell2struct(trainFeatures, cellstr(featuresNames), 2);
test  = cell2struct(testFeatures, cellstr(featuresNames), 2);

% Aggiungi le etichette alle strutture
train.labels = trainLabels;
test.labels  = testLabels;

% Salva i dati elaborati per future esecuzioni
save(outputTrainTestFileName, "train", "test", "featuresNames");


numFeatures = numel(featuresNames);

trainFeatures = cell(1, numFeatures);
testFeatures  = cell(1, numFeatures);
for i = 1:numFeatures
    trainFeatures{i} = train.(featuresNames{i});
    testFeatures{i}  = test.(featuresNames{i});
end

trainFeatures = [trainFeatures{:}];
testFeatures  = [testFeatures{:}];


if ~exist(fullfile(outFolder, modelName), 'file')
    model = TreeBagger(1200, trainFeatures, train.labels, 'OOBPrediction', 'on', 'OOBPredictorImportance', 'on','MinLeafSize', 1,'NumPrint',200);
    save(fullfile(outFolder,modelName), "model");
else
    load(fullfile(outFolder, modelName));
end

% train
predTest = predict(model, trainFeatures);
cmTrain = confmat(train.labels(:),predTest(:));
fprintf('Train Acc: %f\n', cmTrain.accuracy);

% test
predTest = predict(model, testFeatures);

cmTest = confmat(test.labels(:),predTest(:));
figure("Name", "Test");
showConfmat(cmTest.cm_raw, cmTest.labels);


fprintf('Test Acc: %f\n', cmTest.accuracy);