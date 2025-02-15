function localizerAccuracy(maskDir, gtDir)
% Set default directories if not provided
if nargin < 1 || isempty(maskDir)
    maskDir = fullfile('maschere composizioni predette');
end
if nargin < 2 || isempty(gtDir)
    gtDir = fullfile('dataset', 'gt composizioni');
end

% Get the list of .png files in the mask directory
maskFiles = dir(fullfile(maskDir, '*.png'));
if isempty(maskFiles)
    error('No images found in directory %s', maskDir);
end

% Initialize global counters and per-image metric arrays
totalTP = 0;
totalFP = 0;
totalFN = 0;
totalTN = 0;
numImages = length(maskFiles);
precisionArr = zeros(numImages, 1);
recallArr    = zeros(numImages, 1);
f1Arr        = zeros(numImages, 1);


% Loop through each image in the mask directory
for i = 1:numImages
    maskName = maskFiles(i).name;
    predPath = fullfile(maskDir, maskName);
    gtPath   = fullfile(gtDir, maskName);

    if ~isfile(gtPath)
        disp(1);
        warning('File %s does not exist in directory %s. Skipping image.', maskName, gtDir);
        continue;
    end

    % Load the masks using correctOrientation (assumed defined elsewhere)
    predMask = correctOrientation(predPath);
    gtMask   = correctOrientation(gtPath);

    % Ensure sizes match: if not, resize ground truth mask to predicted mask size
    if ~isequal(size(predMask), size(gtMask))
        gtMask = imresize(gtMask, size(predMask));
    end

    % Convert color images to grayscale if needed
    if ndims(predMask) > 2
        predMask = rgb2gray(predMask);
    end
    if ndims(gtMask) > 2
        gtMask = rgb2gray(gtMask);
    end

    % Check dimensions again; if different, resize predicted mask to ground truth size
    if ~isequal(size(predMask), size(gtMask))
        warning('Different dimensions between predMask and gtMask for %s. Resizing predMask.', maskName);
        predMask = imresize(predMask, size(gtMask));
    end

    % Convert to binary images if they are not already
    if ~islogical(predMask)
        predMask = imbinarize(predMask);
    end
    if ~islogical(gtMask)
        gtMask = imbinarize(gtMask);
    end

    % Calculate pixel-wise confusion matrix components
    TP = sum((predMask == 1) & (gtMask == 1), 'all');
    FP = sum((predMask == 1) & (gtMask == 0), 'all');
    FN = sum((predMask == 0) & (gtMask == 1), 'all');
    TN = sum((predMask == 0) & (gtMask == 0), 'all');

    % Update global counters
    totalTP = totalTP + TP;
    totalFP = totalFP + FP;
    totalFN = totalFN + FN;
    totalTN = totalTN + TN;

    % Calculate precision, recall, and F1 score for the current image
    if (TP + FP) == 0
        precision = 0;
    else
        precision = TP / (TP + FP);
    end

    if (TP + FN) == 0
        recall = 0;
    else
        recall = TP / (TP + FN);
    end

    if (precision + recall) == 0
        f1 = 0;
    else
        f1 = 2 * (precision * recall) / (precision + recall);
    end

    % Save per-image results
    precisionArr(i) = precision;
    recallArr(i)    = recall;
    f1Arr(i)        = f1;

    % Display current image metrics
    fprintf('Image: %s\n', maskName);
    fprintf('TP: %d, FP: %d, FN: %d, TN: %d\n', TP, FP, FN, TN);
    fprintf('Precision: %.4f, Recall: %.4f, F1 Score: %.4f\n\n', precision, recall, f1);
end

% Compute overall metrics across all images
if (totalTP + totalFP) == 0
    overallPrecision = 0;
else
    overallPrecision = totalTP / (totalTP + totalFP);
end

if (totalTP + totalFN) == 0
    overallRecall = 0;
else
    overallRecall = totalTP / (totalTP + totalFN);
end

if (overallPrecision + overallRecall) == 0
    overallF1 = 0;
else
    overallF1 = 2 * (overallPrecision * overallRecall) / (overallPrecision + overallRecall);
end

% Display global metrics
fprintf('-----------------------------\n');
fprintf('Overall Metrics:\n');
fprintf('Total TP: %d, Total FP: %d, Total FN: %d, Total TN: %d\n', totalTP, totalFP, totalFN, totalTN);
fprintf('Overall Precision: %.4f\n', overallPrecision);
fprintf('Overall Recall:    %.4f\n', overallRecall);
fprintf('Overall F1 Score:  %.4f\n', overallF1);
end
