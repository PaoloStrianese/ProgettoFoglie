function feature = extractColor(imgInput)
% Read image
if ischar(imgInput) || isstring(imgInput)
    img = imread(imgInput);
else
    img = imgInput;
end

% Convert to HSV and normalize
hsvImg = rgb2hsv(img);
h = hsvImg(:,:,1);
s = hsvImg(:,:,2);
v = hsvImg(:,:,3);

%% 1. Quantized HSV Histogram
numHueBins = 16;  % Higher resolution for hue
numSatBins = 4;
numValBins = 4;

% Calculate histograms
hHist = histcounts(h, linspace(0,1,numHueBins+1), 'Normalization', 'probability');
sHist = histcounts(s, linspace(0,1,numSatBins+1), 'Normalization', 'probability');
vHist = histcounts(v, linspace(0,1,numValBins+1), 'Normalization', 'probability');

%% 2. Advanced Statistical Moments
% Mean and Std for each channel
hMean = circ_mean(h(:)*2*pi);
sMean = mean(s(:));
vMean = mean(v(:));

hStd = circ_std(h(:)*2*pi)/(2*pi); % Converts to [0,1]
sStd = std(s(:));
vStd = std(v(:));

%% 3. Composite Measures
% Colorfulness Index (Hasler et al.)
rg = double(img(:,:,1)) - double(img(:,:,2));
yb = 0.5*(double(img(:,:,1)) + double(img(:,:,2))) - double(img(:,:,3));
colorfulness = std(rg(:)) + std(yb(:)) + 0.3*sqrt(mean(rg(:).^2) + mean(yb(:).^2));

% Dominant Hue Analysis
[counts, ~] = histcounts(h, linspace(0,1,numHueBins+1));
dominantHuePct = max(counts)/sum(counts);

% Saturation-Value Energy
svEnergy = mean(s(:).*v(:));

%% Construct feature vector
feature = [...
    hHist, sHist, vHist, ...           % 16+4+4 = 24
    hMean, hStd, sMean, sStd, vMean, vStd, ... % 6
    colorfulness, dominantHuePct, svEnergy ...  % 3
    ]; % Total: 33 features

% Helper function for circular mean
    function m = circ_mean(angles)
        m = angle(mean(exp(1i*angles)))/(2*pi);
        if m < 0, m = m + 1; end
    end

% Helper function for circular standard deviation
    function s = circ_std(angles)
        R = abs(mean(exp(1i*angles)));
        s = sqrt(-2*log(R));
    end
end