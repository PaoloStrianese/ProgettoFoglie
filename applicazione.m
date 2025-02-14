close all;
clear all;

load(fullfile('pretrained model','modelClassifier.mat'), 'model');
%load(fullfile('pretrained model','modelLocalizer.mat'), 'localizerModel');

composizione = 'composizione.jpg';
singleLeavesMaskPath = fullfile('.cache','main_segmented');
singleLeavesSegmentedPath = fullfile('.cache','main_mask');

addpath('utils','classificazione');
addpath(genpath(fullfile('classificazione','feature_extractors')));

img = correctOrientation(composizione);
mask = correctOrientation("maschera.png");

se = strel('disk', 5);
mask = imclose(mask, se);
mask = imopen(mask, se);

boxs = extract_leaf_region_return_box(img, mask, singleLeavesMaskPath, singleLeavesSegmentedPath);

[testFeatures, ~, featuresNames] = featureExtractorClassifier(...
    singleLeavesSegmentedPath,...
    singleLeavesMaskPath,...
    0.8,0.8);

test  = cell2struct(testFeatures,  cellstr(featuresNames), 2);

numFeatures = numel(featuresNames);

testFeatures  = cell(1, numFeatures);
for i = 1:numFeatures
    testFeatures{i}  = test.(featuresNames{i});
end

testFeatures  = [testFeatures{:}];

[prediction, score] = predict(model, testFeatures);

figure; imshow(img);
hold on;
for k = 1:size(boxs,1)
    % Get score value
    scoreValue = max(score(k,:));

    % Determine the color and label
    if scoreValue < 0.20
        edgeColor = 'r';
        label = prediction{k};
    elseif scoreValue < 0.30
        edgeColor = 'y';
        label = [prediction{k} ' indiceiso'];
    else
        edgeColor = 'g';
        label = prediction{k};
    end

    % Draw bounding box and display text on image
    rectangle('Position', boxs(k,:), 'EdgeColor', edgeColor, 'LineWidth', 2);
    text(boxs(k,1), boxs(k,2)-40, label, 'Color', edgeColor, 'FontSize', 20, 'FontWeight', 'bold');
end
hold off;
