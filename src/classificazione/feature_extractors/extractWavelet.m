function features = extractWavelet(img)

% Check if the image is RGB; if so, convert it to grayscale.
if size(img,3) > 1
    img = rgb2gray(img);
end

% Convert to double for proper processing.
img = im2double(img);

waveletName = 'db1';

level = 6;

% Perform 2D wavelet decomposition.
[C,S] = wavedec2(img, level, waveletName);

% Initialize the features vector.
features = [];

% For each level, extract the detailed coefficients:
% horizontal (H), vertical (V), and diagonal (D)
for i = 1:level
    [H, V, D] = detcoef2('all', C, S, i);
    % Compute the energy for each subband.
    energyH = sum(H(:).^2);
    energyV = sum(V(:).^2);
    energyD = sum(D(:).^2);
    % Concatenate the energies into the features vector.
    features = [features, energyH, energyV, energyD];
end

% Add the energy of the approximation coefficients at the final level.
A = appcoef2(C, S, waveletName, level);
energyA = sum(A(:).^2);
features = [features, energyA];
end
