function out = extractFourier(image)
% Convert the image to grayscale (if necessary)
if size(image, 3) == 3
    grayImage = rgb2gray(image);
else
    grayImage = image;
end

% Binarize the image (using simple adaptive thresholding)
bw = imbinarize(grayImage);

% Remove small objects
bw = bwareaopen(bw, 50);

% Extract contours
boundaries = bwboundaries(bw);

% Select the longest contour (assuming it represents the leaf)
maxBoundary = [];
maxLength = 0;
for k = 1:length(boundaries)
    boundary = boundaries{k};
    if length(boundary) > maxLength
        maxLength = length(boundary);
        maxBoundary = boundary;
    end
end

% Represent the contour as complex numbers: z = x + iy
z = double(maxBoundary(:,2)) + 1i * double(maxBoundary(:,1));

% Compute the Fourier transform of the contour
F = fft(z);

% Normalize to obtain translation and scale invariance:
% - The DC component (F(1)) is affected by translation, so it is discarded
% - Normalize by dividing by the magnitude of the second coefficient
F = F / abs(F(2));

% Discard the DC term and select the first N coefficients
N = 10;  % for example, extract 10 Fourier descriptors
out = double(F(2:(N+1)));
out = [real(out) imag(out)];
out = out(:)';  % returns a row vector
end
