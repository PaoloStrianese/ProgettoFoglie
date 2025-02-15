


load(fullfile('out', 'modelClassifier.mat'), "classificationModel");

plotBestFeatures(classificationModel);

function plotBestFeatures(model)
[~, ~, segmentedFeatures, maskFeatures, featureNames] = setupExtractionClassifier(1);
combinedFeatures = [segmentedFeatures, maskFeatures];

% Create labels for each feature based on its corresponding extraction
featureLabels = arrayfun(@(idx) ...
    repmat(featureNames(idx), size(combinedFeatures{idx}, 2), 1), ...
    1:numel(combinedFeatures), 'UniformOutput', false);
featureLabels = vertcat(featureLabels{:});

% Compute predictor importance using the out-of-bag error estimates
importanceScores = model.OOBPermutedPredictorDeltaError;

% Plot the feature importance
figure;
bar(importanceScores);
xticks(1:numel(importanceScores));
xticklabels(featureLabels);
xlabel('Feature');
ylabel('Importance');
title('Predictor Importance');

% Plot the out-of-bag error vs. number of trees
figure;
plot(model.oobError);
xlabel('Number of Trees');
ylabel('Out-of-Bag Classification Error');
title('OOB Error vs. Number of Trees');
end