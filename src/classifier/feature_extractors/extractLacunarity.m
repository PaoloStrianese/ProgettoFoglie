function out = extractLacunarity(image)
% Convert the image to grayscale if it is in color
if size(image, 3) == 3
    image = rgb2gray(image);
end
% Convert the image to double format for calculations
img = double(image);

% Define a series of box sizes for multiscale calculation
boxSizes = [4, 8, 16];  % example: box sizes of 4x4, 8x8, and 16x16
lacunarityValues = zeros(1, length(boxSizes));

for i = 1:length(boxSizes)
    b = boxSizes(i);
    % Calculate the sum of pixels in each b x b block using blockproc
    fun = @(block_struct) sum(block_struct.data(:));
    blockSums = blockproc(img, [b b], fun);
    % Flatten the result into a vector
    blockSums = blockSums(:);
    % Calculate the mean and variance of block sums
    mu = mean(blockSums);
    sigma2 = var(blockSums);
    % Calculate lacunarity:
    % A common definition is: L = (variance)/(mean^2) + 1
    lacunarityValues(i) = sigma2 / (mu^2) + 1;
end

% Return a vector of lacunarity, one for each box size
out = lacunarityValues;
end