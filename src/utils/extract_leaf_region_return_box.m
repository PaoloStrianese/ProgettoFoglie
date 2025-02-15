function [boxs]=extract_leaf_region_return_box(img, mask, singleLeavesMaskPath, singleLeavesSegmentationPath)
outputFolderSegm = singleLeavesSegmentationPath;
outputFolderMask = singleLeavesMaskPath;

if ~isequal(size(mask,1), size(img,1)) || ~isequal(size(mask,2), size(img,2))
    mask = imresize(mask, [size(img,1) size(img,2)], 'nearest');
end

% Ensure the output folders exist, create subfolders if needed
if ~exist(outputFolderSegm, 'dir')
    mkdir(outputFolderSegm);
end

if ~exist(outputFolderMask, 'dir')
    mkdir(outputFolderMask);
end

labeledImage = bwlabel(mask);
stats = regionprops(labeledImage, 'Area', 'Image', 'BoundingBox');

minArea = 100;
nValid = sum([stats.Area] > minArea);
boxs = zeros(nValid, 4);
validIndex = 1;

% Process each leaf
for k = 1:numel(stats)
    % Skip small regions (adjust area threshold as needed)
    if stats(k).Area < minArea
        continue;
    end


    % Get binary leaf image and bounding box
    leafBinary = stats(k).Image;
    bb = stats(k).BoundingBox;

    boxs(validIndex, :) = bb;
    validIndex = validIndex + 1;

    % Crop corresponding region from original image
    leafOriginal = imcrop(img, bb);

    % Check that the cropped region is valid
    if isempty(leafOriginal) || any(size(leafOriginal(:,:,1)) <= 0)
        warning('Cropped region for leaf %d is empty or invalid. Skipping this region.', k);
        continue;
    end

    % Resize the binary mask to match size of the cropped original image
    origSize = size(leafOriginal(:,:,1));
    resizedBinary = imresize(leafBinary, origSize);

    % Mask the original image with the resized binary mask
    maskedOriginal = leafOriginal .* resizedBinary;

    baseName = sprintf('%02d.png', k);
    % Save the masked image
    imwrite(maskedOriginal, fullfile(outputFolderSegm, baseName));
    % Save the binary mask image
    imwrite(leafBinary, fullfile(outputFolderMask, baseName));
end
end