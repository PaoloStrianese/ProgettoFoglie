close all;
clear all;
clc;
if exist('.cache', 'dir')
    rmdir('.cache', 's');
end

%Select the image that you want to analize (from folder /src/dataset/compositions)
selectedImg = "20.jpg";

disp("Process Starting...")

load(fullfile('src','pretrained model','modelClassifier.mat'));
load(fullfile('src','pretrained model','modelLocalizer.mat'));

composizione = fullfile('src','dataset','compositions', selectedImg);

singleLeavesMaskPath = fullfile('.cache','main_segmented');
singleLeavesSegmentedPath = fullfile('.cache','main_mask');

addpath(genpath(fullfile('src')));

imageRGB = im2double(correctOrientation(composizione));
original = imageRGB;


% Resize for processing (optional)
imageRGB = imresize(imageRGB, 0.6, "bilinear", "Antialiasing", true);
imageRGBLoc = imresize(imageRGB, 0.1, "bilinear", "Antialiasing", true);

%% Mask obtained with Canny
disp("Generating Canny Mask...");
maskCanny = createEdgeMask(imageRGB);

cannyEdgeMask = maskCanny;

% Processing to remove regions that deviate too much from the average color
cc = bwconncomp(maskCanny);
threshold = 0.3;  % Variance threshold (adjust as needed)
numPixels = numel(maskCanny);  % Number of pixels per channel

for i = 1:cc.NumObjects
    regionIdx = cc.PixelIdxList{i};
    % Calculate the mean value for each channel
    if size(imageRGB, 3) == 3
        meanR = mean(imageRGB(regionIdx));
        meanG = mean(imageRGB(regionIdx + numPixels));
        meanB = mean(imageRGB(regionIdx + 2*numPixels));
        regionMean = [meanR, meanG, meanB];
    else
        regionMean = mean(imageRGB(regionIdx));
    end
    % Calculate the difference from the saved average leaf color
    diff = norm(regionMean - avgLeafColor);
    if diff > threshold
        % If the difference exceeds the threshold, zero out the entire region
        maskCanny(regionIdx) = 0;
    end
end

disp("Canny Mask Created");

%% Segmentation based on the predicted model (KNN)
disp("Generating KNN Mask...");
predictedLeafMask = predictMask(imageRGBLoc, modelLocalizer);
predictedLeafMask = imresize(predictedLeafMask, [size(original, 1) size(original, 2)], "bilinear", "Antialiasing", true);
disp("KNN resized");

% Morphological operations to improve the KNN mask
predictedLeafMask = imopen(predictedLeafMask, strel('disk', 5));
predictedLeafMask = imclose(predictedLeafMask, strel('disk', 5));
predictedLeafMask = imfill(predictedLeafMask, 'holes');
predictedLeafMask = imerode(predictedLeafMask, strel('disk', 5));

% Resize the Canny mask to the original dimensions
maskCanny_resized = imresize(maskCanny, [size(original, 1), size(original, 2)], "bilinear", "Antialiasing", true);
disp("Canny resized");

cannyEdgeMask= imresize(cannyEdgeMask, [size(original, 1), size(original, 2)], "bilinear", "Antialiasing", true);

% Combine both masks to obtain the final mask and remove imperfections
oggetti = cannyEdgeMask - maskCanny_resized;
finalMask = (maskCanny_resized & predictedLeafMask);
disp("Creating Final Mask...");


disp('Extracting leaf regions...');
leafBoundingBoxes = extract_leaf_region_return_box(original, finalMask, singleLeavesMaskPath, singleLeavesSegmentedPath);

unknownBonduingBoxes = extract_leaf_region_return_box(original, oggetti, fullfile('.cache', "oggettimask"), fullfile('.cache', "oggettisegm"));

disp('Extracting features...');
[testFeatures, ~, featuresNames] = featuresExtractor(...
    singleLeavesSegmentedPath, ...
    singleLeavesMaskPath);

test = cell2struct(testFeatures, cellstr(featuresNames), 2);

numFeatures = numel(featuresNames);

testFeatures = cell(1, numFeatures);
for i = 1:numFeatures
    testFeatures{i} = test.(featuresNames{i});
end

testFeatures = [testFeatures{:}];

disp('Predicting leaf classes...');
[prediction, score] = predict(classificationModel, testFeatures);

disp('Displaying results...');
figure; imshow(original);
hold on;
for k = 1:size(leafBoundingBoxes, 1)
    % Get score value
    scoreValue = max(score(k, :));

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

    % Draw bounding box and display text on the image
    rectangle('Position', leafBoundingBoxes(k, :), 'EdgeColor', edgeColor, 'LineWidth', 2);
    text(leafBoundingBoxes(k, 1), leafBoundingBoxes(k, 2)-40, label, 'Color', edgeColor, 'FontSize', 20, 'FontWeight', 'bold');
end

for k = 1:size(unknownBonduingBoxes, 1)

    % Draw bounding box and display text on the image
    rectangle('Position', unknownBonduingBoxes(k, :), 'EdgeColor', "m", 'LineWidth', 2);
    text(unknownBonduingBoxes(k, 1), unknownBonduingBoxes(k, 2)-40, "Unknown", 'Color', "m", 'FontSize', 20, 'FontWeight', 'bold');
end
hold off;

disp("Process Completed")
