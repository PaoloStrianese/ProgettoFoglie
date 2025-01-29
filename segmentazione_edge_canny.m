clear all;

addpath("bozze/");
% Read the image
%img = imread('dataset/Pianta 10/03.jpg');
img = imread("composizioni/02.jpg");

filteredImg = enhancement(img);

% Convert the image to grayscale
filteredImg = rgb2gray(filteredImg);

% Apply a median filter
filteredImg = medfilt2(filteredImg, [15 15]);

% Convert the image to HSV
hsvImg = rgb2hsv(img);

% Extract the S channel
sChannel = hsvImg(:, :, 2);

% Apply Canny edge detector
edges = edge(filteredImg, 'Canny');

% Define the size of the region to close with a circular structuring element
se = strel('disk', 15);

% % Apply morphological closing
edges = imclose(edges, se);


% Fill holes in the edges
edges = imfill(edges, 'holes');

% Find connected components
cc = bwconncomp(edges);

% Get the area of each component
stats = regionprops(cc, 'Area');

% Define a threshold for the minimum area
minArea = 500;

% Create a binary image with only the large components
largeComponents = ismember(labelmatrix(cc), find([stats.Area] >= minArea));

% Update the edges image to only include large components
edges = largeComponents;


% Call the function
extract_leaf_region(img, edges, 'leaves_segmented_composition');

disp('Processing completed!');

% Display the original image and the edges
figure;
subplot(1, 2, 1);
imshow(filteredImg);
title('Original Image');

subplot(1, 2, 2);
imshow(edges);
title('Edges detected using Canny');