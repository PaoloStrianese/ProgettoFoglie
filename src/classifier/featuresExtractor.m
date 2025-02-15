function [combinedFeaturesContainers, labels, featuresNames] = featuresExtractor(...
    segmentedImagesFolder, maskImagesFolder, varargin)

if nargin < 3 || isempty(varargin{1})
    segmentedResizeFactor = 0.7;
else
    segmentedResizeFactor = varargin{1};
end

if nargin < 4 || isempty(varargin{2})
    maskResizeFactor = 0.7;
else
    maskResizeFactor = varargin{2};
end

segmentedPaths = collectImagePathsInDirectory(segmentedImagesFolder);
maskPaths      = collectImagePathsInDirectory(maskImagesFolder);
labels         = getLabelsFromFolder(segmentedImagesFolder);
imagesCount    = numel(labels);


assert(imagesCount == numel(maskPaths), ...
    sprintf("Mismatch between segmented images (%d) in '%s' and mask images (%d) in '%s'.", ...
    imagesCount, segmentedImagesFolder, numel(maskPaths), maskImagesFolder));
assert(imagesCount == numel(segmentedPaths), ...
    sprintf("Mismatch between segmented images count (%d) and labels count (%d) in '%s'.", ...
    imagesCount, numel(segmentedPaths), segmentedImagesFolder));

[segmentedFunctions, maskFunctions, segmentedFeatures, maskFeatures, featuresNames] = setup(imagesCount);

%% Extract features from every image
featureExtractionProgressBar = waitbar(0, "Starting features extraction...");
set(featureExtractionProgressBar, "Name", segmentedImagesFolder);
for i = 1:imagesCount
    waitbar(i/imagesCount, featureExtractionProgressBar, ...
        sprintf("Progress: %d %%\n%s", floor(i/imagesCount*100), labels(i)));

    % Extract segmented features
    segmentedImage = im2double(imread(segmentedPaths{i}));
    segmentedImage = processImage(segmentedImage);
    segmentedImage = imresize(segmentedImage, segmentedResizeFactor);


    for j = 1:numel(segmentedFunctions)
        segmentedFeatures{j}(i, :) = segmentedFunctions{j}(segmentedImage);
    end

    % Extract mask features
    maskImage = im2double(imread(maskPaths{i}));
    maskImage = processImage(maskImage);
    maskImage = imresize(maskImage, maskResizeFactor);

    for j = 1:numel(maskFunctions)
        maskFeatures{j}(i, :) = maskFunctions{j}(maskImage);
    end
end
close(featureExtractionProgressBar);

combinedFeaturesContainers = [segmentedFeatures, maskFeatures];

%% Normalize features
for i = 1:numel(combinedFeaturesContainers)
    combinedFeaturesContainers{i} = normalize(combinedFeaturesContainers{i}, "range");
end
end

function paths = collectImagePathsInDirectory(folder)
files = dir(fullfile(folder, "*.png"));
names = {files.name};
paths = fullfile(folder, names);
end


function labels = getLabelsFromFolder(folder)
files = dir(fullfile(folder, "*.png"));
labels = strings(numel(files), 1);
for idx = 1:numel(files)
    parts   = split(files(idx).name, "-");
    %nameExt = split(parts(2), ".");
    labels(idx) = string(parts(1));
end
end


function [outImage] = processImage(img)
targetSize = [512, 512];

    [origH, origW, ~] = size(img);

% Calcola il fattore di scala preservando il rapporto
scaleFactor = min(targetSize(1)/origH, targetSize(2)/origW);
newSize = round([origH, origW] * scaleFactor);

% Ridimensiona con metodo nearest (mantenendo binarietà)
imgResized = imresize(img, newSize, 'Method', 'nearest');

% Calcolo padding (per centrare l'immagine)
padRows = targetSize(1) - newSize(1);
padCols = targetSize(2) - newSize(2);
top    = floor(padRows/2);
bottom = padRows - top;
left   = floor(padCols/2);
right  = padCols - left;

% Aggiungi padding nero (valore 0)
imgPadded = padarray(imgResized, [top, left], 0, 'pre');
outImage = padarray(imgPadded, [bottom, right], 0, 'post');
end