function [out] = extractVenation(img)

% If the image is RGB, convert it to grayscale
if size(img,3) == 3
    imgGray = rgb2gray(img);
else
    imgGray = img;
end

% Convert to double for better precision
imgGray = im2double(imgGray);

% Noise reduction using a median filter
imgFiltered = medfilt2(imgGray, [3 3]);

% Segmentation using Otsu's thresholding method
threshold = graythresh(imgFiltered);
bw = imbinarize(imgFiltered, threshold);

% If the veins are dark on a light background, invert the binary image
% (most methods assume white veins on a black background)
if mean(bw(:)) > 0.5
    bw = ~bw;
end

% Remove small objects to eliminate noise
bw = bwareaopen(bw, 50);

% Skeletonization: reduces the venation to a thin line
skel = bwmorph(bw, 'skel', Inf);

% Calculate vein density: ratio of skeleton pixels to total pixels
veinDensity = sum(skel(:)) / numel(skel);

% Extract branch points from the skeleton
branchPoints = bwmorph(skel, 'branchpoints');
branchCount = sum(branchPoints(:));

% Calculate branch point density: normalized to the total area
branchDensity = branchCount / numel(skel);

out = [veinDensity, branchDensity];
end
