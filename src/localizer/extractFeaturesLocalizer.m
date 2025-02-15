function allFeatures = extractFeaturesLocalizer(imageRGB)
% Convert image to double and normalize to [0,1]
imageRGB = im2double(imageRGB);

imageRGB(imageRGB > 1) = 1;

% Convert to different color spaces
imageHSV = rgb2hsv(imageRGB);
imageLAB = rgb2lab(imageRGB);
imageYCbCr = rgb2ycbcr(imageRGB);

% Extract RGB channels
R = imageRGB(:,1);
G = imageRGB(:,2);
B = imageRGB(:,3);

% Compute features
ExG = 2 * G - R - B;
ExR = 1.4 * R - G;

% Extract HSV channels (if needed)
H = imageHSV(:,1);
S = imageHSV(:,2);
V = imageHSV(:,3);

% Extract LAB channels (if needed)
L_lab = imageLAB(:,1);
a_lab = imageLAB(:,2);
b_lab = imageLAB(:,3);

% Extract YCbCr channels (if needed)
Y = imageYCbCr(:,1);
Cb = imageYCbCr(:,2);
Cr = imageYCbCr(:,3);

% Return selected features
allFeatures = [R, G, B, ExR, ExG, H, S, V, L_lab, a_lab, b_lab, Y, Cb, Cr];
end
