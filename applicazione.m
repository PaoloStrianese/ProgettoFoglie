close all;
clear all;

load(fullfile('pretrained model','modelClassifier.mat'), 'model');
load(fullfile('pretrained model','modelLocalizer.mat'), 'localizerModel');


composizione = fullfile('localizzazione','dataset','composizioni','11.jpg');

singleLeavesMaskPath = fullfile('.cache','main_segmented');
singleLeavesSegmentedPath = fullfile('.cache','main_mask');

addpath('utils','classificazione');
addpath(genpath(fullfile('classificazione','feature_extractors')));
addpath(genpath(fullfile('localizzazione')));


img = correctOrientation(composizione);

original = img;

img = imresize(img, 0.15, "bilinear", "Antialiasing", true);

disp('Predicting mask...');
mask = predictMask(img, localizerModel, 1);

% questa parte bisogna metterla in un'altra funzione (anche nel localizzatore)
mask = imresize(mask, [size(original,1) size(original,2)], "bilinear","Antialiasing",true);

mask = imopen(mask, strel('disk', 5));
mask = imclose(mask, strel('disk', 5));
mask = imfill(mask, 'holes');
mask = imerode(mask, strel('disk', 3));

disp('Extracting leaf regions...');
boxs = extract_leaf_region_return_box(original, mask, singleLeavesMaskPath, singleLeavesSegmentedPath);

disp('Extracting features...');
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

disp('Predicting leaf classes...');
[prediction, score] = predict(model, testFeatures);

disp('Displaying results...');
figure; imshow(original);
hold on;
for k = 1:size(boxs,1)
    % Get score value
    scoreValue = max(score(k,:));

    % Determine the color and label
    if scoreValue < 0.15
        edgeColor = 'r';
        label = prediction{k};
    elseif scoreValue < 0.25
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
