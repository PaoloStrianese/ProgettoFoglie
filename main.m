close all;
clear all;

composizione = 'img.jpg';
singleLeavesMaskPath = fullfile('.cache','main_segmented');
singleLeavesSegmentedPath = fullfile('.cache','main_mask');

addpath('bozze');

img = correctOrientation(composizione);

mask = correctOrientation("mask.png");

boxs = extract_leaf_region_return_box(img, mask, singleLeavesMaskPath, singleLeavesSegmentedPath);

[testFeatures, ~, featuresNames] = featureExtractorClassifier(...
    singleLeavesSegmentedPath,...
    singleLeavesMaskPath,...
    0.8);

test  = cell2struct(testFeatures,  cellstr(featuresNames), 2);

numFeatures = numel(featuresNames);

testFeatures  = cell(1, numFeatures);
for i = 1:numFeatures
    testFeatures{i}  = test.(featuresNames{i});
end

testFeatures  = [testFeatures{:}];

load(fullfile('.cache','model.mat'), 'model');

prediction = predict(model, testFeatures);

figure; imshow(img);
hold on;
for k = 1:size(boxs,1)
    % Draw bounding box
    rectangle('Position', boxs(k,:), 'EdgeColor', 'g', 'LineWidth', 2);
    % Add label (assuming prediction{k} is a string or char array)
    label = prediction{k};
    % Adjust text position slightly above the box
    text(boxs(k,1), boxs(k,2)-40, label, 'Color', 'g', 'FontSize', 20, 'FontWeight', 'bold');
end
hold off;
