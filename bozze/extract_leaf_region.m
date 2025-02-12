function extract_leaf_region(img, mask, compName)
outputFolderSegm = 'leaves_segmented_composition';
outputFolderMask = 'leaves_masked_composition';

img = correctOrientation(img);
mask = correctOrientation(mask);

% Ensure the output folders exist, create subfolders if needed
if ~exist(outputFolderSegm, 'dir')
    mkdir(outputFolderSegm);
end
if ~exist(fullfile(outputFolderSegm, compName), 'dir')
    mkdir(fullfile(outputFolderSegm, compName));
end


if ~exist(outputFolderMask, 'dir')
    mkdir(outputFolderMask);
end
if ~exist(fullfile(outputFolderMask, compName), 'dir')
    mkdir(fullfile(outputFolderMask, compName));
end

labeledImage = bwlabel(mask);
stats = regionprops(labeledImage, 'Area', 'Image', 'Orientation', 'BoundingBox');

% Process each leaf
for k = 1:numel(stats)
    % Skip small regions (adjust area threshold as needed)
    if stats(k).Area < 100
        continue;
    end

    % Get binary leaf image and bounding box
    leafBinary = stats(k).Image;
    bb = stats(k).BoundingBox;

    % Crop corresponding region from original image
    leafOriginal = imcrop(img, bb);

    % Resize the rotated binary mask to match the size of the rotated original image
    resizedBinary = imresize(leafBinary, size(leafOriginal(:,:,1)));

    % Mask the rotated original image with the resized binary mask
    maskedOriginal = rotatedOriginal .* uint8(resizedBinary);

    baseName = sprintf('%04d', k);
    % Save the masked image
    imwrite(maskedOriginal, fullfile(outputFolderSegm, compName, [baseName '.png']));
    % Create filenames and save
    imwrite(rotatedBinary, fullfile(outputFolderMask, compName, [baseName '.png']));
end
end