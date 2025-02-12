function extract_leaf_region(img, mask, compName)
outputFolderSegm = '1gt_segmented';
outputFolderMask = '1gt';

img = correctOrientation(img);
mask = correctOrientation(mask);

if ~isequal(size(mask,1), size(img,1)) || ~isequal(size(mask,2), size(img,2))
    mask = imresize(mask, [size(img,1) size(img,2)], 'nearest');
end
% Convert mask to grayscale if it is not 2D
if ndims(mask) > 2
    mask = rgb2gray(mask);
end

mask = imbinarize(mask);

% Ensure the output folders exist, create subfolders if needed
if ~exist(outputFolderSegm, 'dir')
    mkdir(outputFolderSegm);
end

if ~exist(outputFolderMask, 'dir')
    mkdir(outputFolderMask);
end

labeledImage = bwlabel(mask);
stats = regionprops(labeledImage, 'Area', 'Image', 'BoundingBox');

% Process each leaf
for k = 1:numel(stats)
    % Skip small regions (adjust area threshold as needed)
    if stats(k).Area < 100
        continue;
    end

    % Get binary leaf image and bounding box
    leafBinary = stats(k).Image;
    bb = stats(k).BoundingBox;

    % figure;
    % subplot(1,2,1);
    % imshow(img);
    % hold on;
    % rectangle('Position', bb, 'EdgeColor', 'r', 'LineWidth', 2);
    % title('Original Image with Bounding Box');
    % hold off;

    % subplot(1,2,2);
    % imshow(mask);
    % hold on;
    % rectangle('Position', bb, 'EdgeColor', 'r', 'LineWidth', 2);
    % title('Binary Mask with Bounding Box');
    % hold off;
    % drawnow;
    % return;

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
    maskedOriginal = leafOriginal .* uint8(resizedBinary);

    baseName = sprintf('%02d', k);
    % Save the masked image
    imwrite(maskedOriginal, fullfile(outputFolderSegm, [compName]));
    % Save the binary mask image
    imwrite(leafBinary, fullfile(outputFolderMask, [compName]));
end
end