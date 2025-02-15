function [segmentedFunctions, maskFunctions, segmentedFeatures, maskFeatures, featuresNames] = setup(imagesCount)

featuresExtractorFolder = "feature_extractors";

addpath(genpath(featuresExtractorFolder));

%% Define feature extractors

% Segmented feature extractors
segmentedFunctions = { ...
    @extractColor,...
    %@extractExG,...
    %@extractExGR,...
    % @extractHaralick,...
    %@extractCIVE,...
    % @extractCanny,...
    % @extractWavelet,...
    % @extractHOG,...
    % @extractVenation,...
    % @extractGabor,...
    % @extractTamuraTexture,...
    % @extractColorCorrelogram,...
    % @extractLBP, ...
    % @extractGLCM, ...
    % @extractLacunarity,...
    % @extractSkeletonMetrics, ..
    % @extractLawsEnergy,...
    };

% Mask feature extractors
maskFunctions = { ...
    @extractContourFourier,...
    @extractEdge,...
    @extractEccentricity,...
    @extractAspectRatio,...
    %@extractShapeRatios,...
    %@extractHuMoments,...
    %@extractPhysiologicalLength,...
    %@extractPhysiologicalWidth,..
    % @extractCentroidCoordinates,...
    % @extractNarrowFactor,...
    % @extractArea,...
    % @extractFractalDimension,...
    % @extractFourier,...
    };

%% Define feature sizes for preallocation
segmentedFeaturesSizes = configureDictionary("string","uint8");
segmentedFeaturesSizes("Color") = 33;
%segmentedFeaturesSizes("ExG") = 8;
%segmentedFeaturesSizes("ExGR") = 8;
% segmentedFeaturesSizes("Haralick") = 4;
%segmentedFeaturesSizes("CIVE") = 8;
% segmentedFeaturesSizes("Canny") = 16;
% segmentedFeaturesSizes("HOG") = 36;
% segmentedFeaturesSizes("TamuraTexture") = 3;
% segmentedFeaturesSizes("ColorCorrelogram") = 6;
% segmentedFeaturesSizes("Wavelet") = 19;
% segmentedFeaturesSizes("LawsEnergy") = 1;
% segmentedFeaturesSizes("SkeletonMetrics") = 3;
% segmentedFeaturesSizes("Venation") = 2;
% segmentedFeaturesSizes("LBP") = 59;
% segmentedFeaturesSizes("GLCM") = 64;
% segmentedFeaturesSizes("Lacunarity") = 3;
% segmentedFeaturesSizes("Gabor") = 2;

maskFeaturesSizes = configureDictionary("string","uint8");
% maskFeaturesSizes("ShapeRatios") = 4;
% maskFeaturesSizes("HuMoments") = 7;
maskFeaturesSizes('Edge') = 16;
% maskFeaturesSizes('PhysiologicalLength') = 1;
% maskFeaturesSizes('PhysiologicalWidth') = 1;
maskFeaturesSizes('ContourFourier') = 10;

maskFeaturesSizes('Eccentricity') = 1;
maskFeaturesSizes('AspectRatio') = 1;
% maskFeaturesSizes('FractalDimension') = 1;
% maskFeaturesSizes('Area') = 1;
% maskFeaturesSizes('NarrowFactor') = 1;
% maskFeaturesSizes('CentroidCoordinates') = 2;
% maskFeaturesSizes("Fourier") = 20;

%% Extract feature names from function names: extractABC -> ABC
segmentedNames = getFeatureNames(segmentedFunctions);
maskNames = getFeatureNames(maskFunctions);

featuresNames = [segmentedNames, maskNames];

validateFeatureDimensions(segmentedNames, segmentedFeaturesSizes, maskNames, maskFeaturesSizes);

%% Preallocate storage
segmentedNames = getFeatureNames(segmentedFunctions);
maskNames = getFeatureNames(maskFunctions);

segmentedFeatures = cellfun(@(name) zeros(imagesCount, segmentedFeaturesSizes(name)), segmentedNames, "UniformOutput", false);
maskFeatures = cellfun(@(name) zeros(imagesCount, maskFeaturesSizes(name)), maskNames, "UniformOutput", false);
end

function [names] = getFeatureNames(Functions)
names = string(cellfun(@(f) strrep(func2str(f), "extract", ""), ...
    Functions, "UniformOutput", false));
end

function validateFeatureDimensions(segmentedNames, segmentedFeaturesSizes, maskNames, maskFeaturesSizes)
for i = 1:numel(segmentedNames)
    assert(isKey(segmentedFeaturesSizes, segmentedNames(i)), ...
        "Missing size definition for segmented feature: " + segmentedNames(i));
end

for i = 1:numel(maskNames)
    assert(isKey(maskFeaturesSizes, maskNames(i)), ...
        "Missing size definition for mask feature: " + maskNames(i));
end
end