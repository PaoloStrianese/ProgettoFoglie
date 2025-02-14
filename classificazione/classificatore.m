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
modelName = "modelClassifier.mat";
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



model = TreeBagger(1200, trainFeatures, train.labels, 'OOBPrediction', 'on', 'OOBPredictorImportance', 'on','MinLeafSize', 1,'NumPrint',200);
save(fullfile(outFolder,modelName), "model");


% train
predTest = predict(model, trainFeatures);
cmTrain = confmat(train.labels(:),predTest(:));
fprintf('Train Acc: %f\n', cmTrain.accuracy);

% test
% score =riga la foglia e la colonna la probalilita ad appartenere ad un pianta
[predTest, score] = predict(model, testFeatures);

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
    idx = find(strcmp(model.ClassNames, predLabel));
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