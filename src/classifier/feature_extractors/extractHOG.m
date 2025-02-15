function features = extractHOG(maskImg)
    % Resize image to a fixed dimension (e.g., 64x64)
    targetSize = [64, 64]; 
    resizedImg = imresize(maskImg, targetSize);
    
    % Convert to grayscale
    grayImg = im2uint8(resizedImg);
    
    % Optimized parameters for 64x64 images
    cellSize = [16 16];   % 4 cells per side (64/16)
    blockSize = [2 2];    % 2x2 cells per block
    numBins = 9;          % Number of orientation bins
    
    % Compute HOG features ensuring 36 features
    features = extractHOGFeatures(grayImg,...
        'CellSize', cellSize,...
        'BlockSize', blockSize,...
        'NumBins', numBins);
    
    % Force the feature vector to 36 elements
    features = features(1:36); 
end