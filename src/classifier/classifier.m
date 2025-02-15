close all;
clear all;
clc;

addpath(genpath(fullfile(".." , "utils")));

datasetPath = fullfile(".." , "dataset");
segmentedImagesFolderTraining = fullfile(datasetPath,"gt_segmented_single_leaves_cropped");
segmentedImagesFolderTesting  = fullfile(datasetPath,"gt_segmented_compositions_cropped");
maskImagesFolderTraining      = fullfile(datasetPath,"gt_mask_single_leaves_cropped");
maskImagesFolderTesting       = fullfile(datasetPath,"gt_mask_compositions_cropped");
modelName = "modelClassifier.mat";
outFolder = "out";

RESIZE_FACTOR_SEGMENTATE_TRAIN = 0.2;
RESIZE_FACTOR_MASK_TRAIN = 0.2;

RESIZE_FACTOR_SEGMENTATE_TEST = 0.7;
RESIZE_FACTOR_MASK_TEST = 0.7;

disp("Extracting features and labels for the training set...");
[trainFeatures, trainLabels, featuresNames] = featuresExtractor( ...
    segmentedImagesFolderTraining, maskImagesFolderTraining, ...
    RESIZE_FACTOR_SEGMENTATE_TRAIN, RESIZE_FACTOR_MASK_TRAIN);

disp("Extracting features and labels for the testing set...");
[testFeatures, testLabels, ~] = featuresExtractor( ...
    segmentedImagesFolderTesting, maskImagesFolderTesting, ...
    RESIZE_FACTOR_SEGMENTATE_TEST, RESIZE_FACTOR_MASK_TEST);

% Organize the features into structures for easier access
train = cell2struct(trainFeatures, cellstr(featuresNames), 2);
test  = cell2struct(testFeatures, cellstr(featuresNames), 2);

% Add labels to the structures
train.labels = trainLabels;
test.labels  = testLabels;

numFeatures = numel(featuresNames);

trainFeatures = cell(1, numFeatures);
testFeatures  = cell(1, numFeatures);
for i = 1:numFeatures
    trainFeatures{i} = train.(featuresNames{i});
    testFeatures{i}  = test.(featuresNames{i});
end

trainFeatures = [trainFeatures{:}];
testFeatures  = [testFeatures{:}];


% Train and save the model
disp("Start training the model...");
classificationModel = TreeBagger(1200, trainFeatures, train.labels, 'OOBPrediction', 'on', 'OOBPredictorImportance', 'on','MinLeafSize', 1,'NumPrint',200);
if ~exist(outFolder, 'dir')
    mkdir(outFolder);
end
save(fullfile(outFolder,modelName), "classificationModel");


% Predict and evaluate the model on the training set
predTest = predict(classificationModel, trainFeatures);
cmTrain = confmat(train.labels(:),predTest(:));
fprintf('Train Acc: %f\n', cmTrain.accuracy);


% Predict and evaluate the model on the test set
[predTest, score] = predict(classificationModel, testFeatures);
cmTest = confmat(test.labels(:),predTest(:));
figure("Name", "Test");
showConfmat(cmTest.cm_raw, cmTest.labels);
fprintf('Test Acc: %f\n', cmTest.accuracy);




threshold = 0.30;
correctHighScore = 0;
totalHighScore = 0;

for i = 1:size(score,1)
    % Trova l'indice della classe predetta nella lista di classi del modello
    predLabel = predTest{i};
    idx = find(strcmp(classificationModel.ClassNames, predLabel));
    % Ottieni il punteggio corrispondente
    predScore = score(i, idx);

    if predScore > threshold
        totalHighScore = totalHighScore + 1;
        % Confronta l'etichetta predetta con quella vera
        if strcmp(test.labels{i}, predLabel)
            correctHighScore = correctHighScore + 1;
        end
    end
end

if totalHighScore > 0
    perc = (correctHighScore / totalHighScore) * 100;
else
    perc = 0;
end
fprintf('Percentuale di predizioni giuste con score superiore a 0.30: %.2f%%\n', perc);