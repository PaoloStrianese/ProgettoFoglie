function feature = extractColor(imgInput)
% extractColorEnhanced calculates advanced color features in HSV space
%
% Feature Vector Composition:
% - HSV Histogram (16+4+4 bins)
% - Mean and Std for each channel
% - Colorfulness Index
% - Dominant Hue Percentage
% - Hue Circular Variance
% - Saturation-Value Energy

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

%% 1. Istogramma HSV quantizzato
numHueBins = 16;  % Maggiore risoluzione per la tonalità
numSatBins = 4;
numValBins = 4;

% Calcola istogrammi
hHist = histcounts(h, linspace(0,1,numHueBins+1), 'Normalization', 'probability');
sHist = histcounts(s, linspace(0,1,numSatBins+1), 'Normalization', 'probability');
vHist = histcounts(v, linspace(0,1,numValBins+1), 'Normalization', 'probability');

%% 2. Moment statistici avanzati
% Mean e Std per canale
hMean = circ_mean(h(:)*2*pi);
sMean = mean(s(:));
vMean = mean(v(:));

hStd = circ_std(h(:)*2*pi)/(2*pi); % Converte in [0,1]
sStd = std(s(:));
vStd = std(v(:));

%% 3. Misure composite
% Colorfulness Index (Hasler et al.)
rg = double(img(:,:,1)) - double(img(:,:,2));
yb = 0.5*(double(img(:,:,1)) + double(img(:,:,2))) - double(img(:,:,3));
colorfulness = std(rg(:)) + std(yb(:)) + 0.3*sqrt(mean(rg(:).^2) + mean(yb(:).^2));

% Dominant Hue Analysis
[counts, ~] = histcounts(h, linspace(0,1,numHueBins+1));
dominantHuePct = max(counts)/sum(counts);

% Saturation-Value Energy
svEnergy = mean(s(:).*v(:));

%% Costruzione feature vector
feature = [...
    hHist, sHist, vHist, ...           % 16+4+4 = 24
    hMean, hStd, sMean, sStd, vMean, vStd, ... % 6
    colorfulness, dominantHuePct, svEnergy ...  % 3
    ]; % Totale: 33 features

% Funzione helper per media circolare
    function m = circ_mean(angles)
        m = angle(mean(exp(1i*angles)))/(2*pi);
        if m < 0, m = m + 1; end
    end

% Funzione helper per deviazione standard circolare
    function s = circ_std(angles)
        R = abs(mean(exp(1i*angles)));
        s = sqrt(-2*log(R));
    end
end