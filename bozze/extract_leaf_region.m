function extract_leaf_region(img, mask)
outputFolder = 'leaves_segmented_composition';


if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
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

    % Calculate rotation angle to make major axis vertical
    rotationAngle = 90 - stats(k).Orientation;

    % Rotate both images
    rotatedBinary = imrotate(leafBinary, rotationAngle, 'nearest', 'loose');
    rotatedOriginal = imrotate(leafOriginal, rotationAngle, 'bilinear', 'loose');

    % Resize the rotated binary mask to match the size of the rotated original image
    resizedBinary = imresize(rotatedBinary, size(rotatedOriginal(:,:,1)));

    % Mask the rotated original image with the resized binary mask
    maskedOriginal = rotatedOriginal .* uint8(resizedBinary);

    baseName = sprintf('%04d', k);
    % Save the masked image
    imwrite(maskedOriginal, fullfile(outputFolder, [baseName '_segmented.png']));
    % Create filenames and save
    imwrite(rotatedBinary, fullfile(outputFolder, [baseName '.png']));
end
end