close all;
clear all;

addpath('utils');

load(fullfile('cache','train-test.mat'));

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

% model = fitcauto(train_features, train.labels,"HyperparameterOptimizationOptions", hyperparameterOptimizationOptions(MaxTime=120));
model = TreeBagger(200, trainFeatures, train.labels);
% train
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