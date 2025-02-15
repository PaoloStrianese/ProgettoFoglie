function mask = createEdgeMask(imgrgb)

% Enhance the image and store the result
imgEnhanced = enhancement(imgrgb);
% saveImage(imgEnhanced, "enhanced", "1.png");

% Convert to grayscale:
% - 'grayEnhanced' for the enhanced image
% - 'grayOriginal' for the original image
if size(imgEnhanced, 3) == 3
    grayEnhanced = rgb2gray(imgEnhanced);
    grayOriginal = rgb2gray(imgrgb);
else
    grayEnhanced = imgEnhanced;
    grayOriginal = imgrgb;
end

% Apply a median filter to reduce noise
grayEnhanced = medfilt2(grayEnhanced, [5, 5]);
grayOriginal = medfilt2(grayOriginal, [5, 5]);
% saveImage(grayEnhanced, "gray", "1.png");

% Compute edges using different filters:
% - Sobel on the original image
% - Canny on both versions (original and enhanced)
edgeSobel = edge(grayOriginal, 'Sobel');
edgeCannyOriginal = edge(grayOriginal, 'Canny', [0.08, 0.15]);
edgeCannyEnhanced = edge(grayEnhanced, 'Canny', [0.08, 0.15]);
% saveImage(edgeCannyOriginal, "canny", "1.png");

% Sum the binary edge images (convert to double for summation)
edgeSum = double(edgeSobel) + double(edgeCannyOriginal) + double(edgeCannyEnhanced);
% saveImage(edgeSum, "mask-pre", "1.png");

% Connect broken edges and fill holes
seClose = strel('disk', 15);
edgeSum = imclose(edgeSum, seClose);
edgeSum = imfill(edgeSum, 'holes');

% Perform a slight erosion to refine the edges
seErode = strel('disk', 3);
edgeSum = imerode(edgeSum, seErode);

% Binarize: all pixels > 0 become 1
mask = edgeSum > 0;

% Remove regions with fewer than 5000 pixels
mask = bwareaopen(mask, 5000);
%saveImage(mask, "mask", "1.png");
end