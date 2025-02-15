function [mosaicLeaf, mosaicBackground]=generateMosaicImage(mosaicLeafName, mosaicBackgroundName, datasetFolder, groundtruthFolder, outFolder)
%% General parameters
patchSize = 10;         % patch dimension (20x20 pixels)
patchSizeBG = 50;       % patch dimension for background
numRows = 8;            % number of grid rows
numCols = 10;           % number of grid columns
maxPatches = numRows * numCols;  % maximum number of patches (100)

% Working folders
cacheFolder = fullfile(outFolder, 'cache');
masksFolder = fullfile(cacheFolder,'mask');
imagesFolder = fullfile(cacheFolder,'images');
mosaicLeafName= fullfile(outFolder,mosaicLeafName);
mosaicBGName= fullfile(outFolder, mosaicBackgroundName);

if ~exist(outFolder, 'dir')
    mkdir(outFolder);
end
% Initialize mosaicLeaf and mosaicBackground as empty arrays
mosaicLeaf = [];
mosaicBackground = [];

transferFiles(datasetFolder, imagesFolder);
transferFiles(groundtruthFolder, masksFolder);

% Read the list of masks (assumed PNG format) and sort them
maskFiles = dir(fullfile(masksFolder, '*.png'));
[~, idx] = sort({maskFiles.name});
maskFiles = maskFiles(idx);

% Initialize counters and variables for both mosaics
patchCountLeaf = 0;
patchCountBG   = 0;
mosaicLeafInitialized = false;
mosaicBGInitialized   = false;

%% Single loop: for each mask extract the "leaf" patch and the "background" patch
for k = 1:length(maskFiles)
    % Exit the loop if both mosaics have collected 100 patches
    if (patchCountLeaf >= maxPatches) && (patchCountBG >= maxPatches)
        break;
    end

    % -------------------- LEAF part --------------------
    % Read the mask image
    maskName = maskFiles(k).name;
    maskPath = fullfile(masksFolder, maskName);
    maskImg = imread(maskPath);

    % If the image is in color, convert it to grayscale
    if size(maskImg,3) == 3
        maskImg = rgb2gray(maskImg);
    end

    % Binarize the mask (assumes pixels > 0 represent the region)
    binaryMask = maskImg > 0;

    % Find connected components
    cc = bwconncomp(binaryMask);
    if cc.NumObjects == 0
        warning('No region found in %s. Skipping LEAF part.', maskName);
    else
        % Select the region with the maximum area
        stats_temp = regionprops(cc, 'Area');
        areas = [stats_temp.Area];
        [~, idxMax] = max(areas);
        % Keep only the largest component
        cc.PixelIdxList = cc.PixelIdxList(idxMax);
        cc.NumObjects = 1;
        % Extract properties of the region
        stats = regionprops(cc, 'BoundingBox');
        bbox = stats.BoundingBox;  % [x, y, width, height]

        % Calculate the center of the bounding box (rounded)
        centerX = round(bbox(1) + bbox(3)/2);
        centerY = round(bbox(2) + bbox(4)/2);

        % Load the corresponding image from the "dataset" folder
        [~, name, ~] = fileparts(maskName);
        imagePath = fullfile(imagesFolder, strcat(name, '.jpg'));
        if ~exist(imagePath, 'file')
            warning('Image %s not found in %s. Skipping LEAF part.', imagePath, imagesFolder);
        else

            imgOriginal = correctOrientation(imagePath);

            imgOriginal = correggiBilanciamentoBianco(imgOriginal);

            % For the LEAF part, resize the image so that dimensions match the mask
            imgResized = imresize(imgOriginal, [size(maskImg,1), size(maskImg,2)]);

            % Define a 20x20 region centered on the calculated center
            half = patchSize / 2;  % for 20 pixels, half = 10
            rowStart = centerY - (half - 1);
            rowEnd   = centerY + half;
            colStart = centerX - (half - 1);
            colEnd   = centerX + half;

            % Check that the LEAF patch is entirely within the resized image
            [imgH_resized, imgW_resized, ~] = size(imgResized);
            if rowStart < 1 || rowEnd > imgH_resized || colStart < 1 || colEnd > imgW_resized
                warning('The LEAF patch of %s exceeds image limits. Skipping this image.', maskName);
            else
                patchLeaf = imgResized(rowStart:rowEnd, colStart:colEnd, :);
                patchCountLeaf = patchCountLeaf + 1;
                % Initialize the LEAF mosaic grid with the first valid patch
                if ~mosaicLeafInitialized
                    if ndims(patchLeaf) == 3
                        mosaicLeaf = zeros(numRows*patchSize, numCols*patchSize, 3, class(patchLeaf));
                    else
                        mosaicLeaf = zeros(numRows*patchSize, numCols*patchSize, class(patchLeaf));
                    end
                    mosaicLeafInitialized = true;
                end
                % Calculate the position of the patch in the LEAF grid
                rowIdx = floor((patchCountLeaf - 1) / numCols) + 1;
                colIdx = mod((patchCountLeaf - 1), numCols) + 1;
                mosaicRowStart = (rowIdx - 1) * patchSize + 1;
                mosaicRowEnd   = rowIdx * patchSize;
                mosaicColStart = (colIdx - 1) * patchSize + 1;
                mosaicColEnd   = colIdx * patchSize;
                mosaicLeaf(mosaicRowStart:mosaicRowEnd, mosaicColStart:mosaicColEnd, :) = patchLeaf;
            end
            % Note: the variable imgOriginal is also used for the BG part
        end
    end

    % -------------------- BACKGROUND part --------------------
    % If the original image was loaded, extract a patch from the border
    if exist('imgOriginal','var')
        [imgH_orig, imgW_orig, nChannels] = size(imgOriginal);
        if imgH_orig < patchSize || imgW_orig < patchSize
            warning('Image %s too small for BG patch. Skipping.', imagePath);
        else
            % Randomly choose one of the 4 borders:
            % 1 = top border, 2 = bottom border, 3 = left border, 4 = right border
            borderChoice = randi(4);

            switch borderChoice
                case 1  % Top border
                    rowStartBG = 1;
                    rowEndBG   = patchSizeBG;
                    colStartBG = randi(imgW_orig - patchSizeBG + 1);
                    colEndBG   = colStartBG + patchSizeBG - 1;
                case 2  % Bottom border
                    rowEndBG   = imgH_orig;
                    rowStartBG = imgH_orig - patchSizeBG + 1;
                    colStartBG = randi(imgW_orig - patchSizeBG + 1);
                    colEndBG   = colStartBG + patchSizeBG - 1;
                case 3  % Left border
                    colStartBG = 1;
                    colEndBG   = patchSizeBG;
                    rowStartBG = randi(imgH_orig - patchSizeBG + 1);
                    rowEndBG   = rowStartBG + patchSizeBG - 1;
                case 4  % Right border
                    colEndBG   = imgW_orig;
                    colStartBG = imgW_orig - patchSizeBG + 1;
                    rowStartBG = randi(imgH_orig - patchSizeBG + 1);
                    rowEndBG   = rowStartBG + patchSizeBG - 1;
            end

            % Extract the BG patch from the original image
            patchBG = imgOriginal(rowStartBG:rowEndBG, colStartBG:colEndBG, :);
            patchCountBG = patchCountBG + 1;
            % Initialize the BG mosaic grid with the first valid patch
            if ~mosaicBGInitialized
                if nChannels == 3
                    mosaicBackground = zeros(numRows*patchSizeBG, numCols*patchSizeBG, 3, class(patchBG));
                else
                    mosaicBackground = zeros(numRows*patchSizeBG, numCols*patchSizeBG, class(patchBG));
                end
                mosaicBGInitialized = true;
            end
            % Calculate the position of the patch in the BG grid
            rowIdxBG = floor((patchCountBG - 1) / numCols) + 1;
            colIdxBG = mod((patchCountBG - 1), numCols) + 1;
            mosaicRowStartBG = (rowIdxBG - 1) * patchSizeBG + 1;
            mosaicRowEndBG   = rowIdxBG * patchSizeBG;
            mosaicColStartBG = (colIdxBG - 1) * patchSizeBG + 1;
            mosaicColEndBG   = colIdxBG * patchSizeBG;
            mosaicBackground(mosaicRowStartBG:mosaicRowEndBG, mosaicColStartBG:mosaicColEndBG, :) = patchBG;
        end
        % Remove the variable imgOriginal to avoid reuse
        clear imgOriginal
    end
end

%% Save the results
if mosaicLeafInitialized
    imwrite(mosaicLeaf, mosaicLeafName);
    fprintf('LEAF mosaic saved as "mosaicLeaf.png"\n');
else
    warning('No valid LEAF patch extracted.');
end

if mosaicBGInitialized
    imwrite(mosaicBackground, mosaicBGName);
    fprintf('BACKGROUND mosaic saved as "mosaic_background.png"\n');
else
    warning('No valid BACKGROUND patch extracted.');
end
end
