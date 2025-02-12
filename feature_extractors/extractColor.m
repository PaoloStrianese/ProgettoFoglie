function feature = extractColor(imgInput)
% extractColor calculates color moments (mean, variance, skewness) from an image.
%
% USAGE:
%   feature = extractColor(imgInput)
%
% INPUT:
%   imgInput : either the path to an image file or an image array.
%
% OUTPUT:
%   feature : a 1x9 vector [mR, varR, skewR, mG, varG, skewG, mB, varB, skewB]
%
% Example:
%   features = extractColor('myimage.jpg');

% Read the image if a file name is provided
if ischar(imgInput) || isstring(imgInput)
    img = imread(imgInput);
else
    img = imgInput;
end

% Check that image is RGB
if size(img, 3) ~= 3
    error('Input image must be an RGB image.');
end

% Convert to double for numerical computations
img = double(img);

% Preallocate feature vector [mean, variance, skewness] for each channel
feature = zeros(1,9);

% Process each channel: R, G, B
for channel = 1:3
    % Extract channel data
    data = img(:,:,channel);
    % Reshape channel into vector
    dataVec = data(:);
    
    % Mean
    m = mean(dataVec);
    
    % Variance
    v = var(dataVec); % sample variance
    
    % Skewness (calculate population skewness)
    s = mean((dataVec - m).^3) / (std(dataVec)^3 + eps);
    
    % Save results in corresponding positions:
    idx = (channel-1)*3 + 1;
    feature(idx:idx+2) = [m, v, s];
end
end