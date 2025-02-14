function [segmentedFunctions, maskFunctions, segmentedFeatures, maskFeatures, featuresNames] = setupExtractionClassifier(imagesCount)

featuresExtractorFolder = "feature_extractors";

addpath(genpath(featuresExtractorFolder));

%% Define feature extractors

% color, hu, length, width 0.541
% color, hu, length, width, ExG 0.633
% color, hu, length, width, ExG, ExGR 0.691667
% color, hu, length, width, ExG, ExGR, shapeRatio 0.7
% color, hu, length, width, ExG, ExGR, shapeRatio, haralick 0.70 0.725000 0.733
% color, hu, ExG, ExGR, shapeRatio, haralick, edge 0.766
% color, hu, ExG, ExGR, shapeRatio, haralick, edge, ContourFourier 0.76

% Segmented feature extractors
segmentedFunctions = { ...
    @extractCIVE,... %0.30 migliora la pianta 2
    @extractColor,... %0.425
    @extractExG,... %0.34
    @extractExGR,... %0.34
    @extractHaralick,... %0.20
    %@extractWavelet,... %0,24
    %@extractHOG,... %0.15
    %@extractVenation,... %0.13
    %@extractGabor,... %0.19
    %@extractTamuraTexture,... %0.23
    %@extractColorCorrelogram,... %0.15
    %@extractLBP, ...0.% 25
    %@extractGLCM, ... % 0.20
    %@extractSkeletonMetrics, ... 0.28
    %@extractLawsEnergy,... %0.06
    %@extractLacunarity,... %0.11

    };

% Mask feature extractors
maskFunctions = { ...
    @extractEdge,... %0.658
    @extractShapeRatios,... %0.40
    @extractHuMoments,... %0.54
    @extractContourFourier,... %0.53
    @extractEccentricity,... %0.47
    @extractAspectRatio,.... %0.4
    %@extractPhysiologicalLength,... %0.3
    %@extractPhysiologicalWidth,... %0.3
    % @extractCentroidCoordinates,... %0.09
    %@extractNarrowFactor,... %0.18
    % @extractArea,... %0.11
    %@extractFractalDimension,... %0.11
    %@extractFourier,... %0.075
    };

%% Define feature sizes for preallocation
segmentedFeaturesSizes = configureDictionary("string","uint8");
segmentedFeaturesSizes("Color") = 33;
segmentedFeaturesSizes("Haralick") = 4;
segmentedFeaturesSizes("ExG") = 8;
segmentedFeaturesSizes("ExGR") = 8;
%segmentedFeaturesSizes("HOG") = 36;
%segmentedFeaturesSizes("TamuraTexture") = 3;
%segmentedFeaturesSizes("ColorCorrelogram") = 6;
%segmentedFeaturesSizes("Wavelet") = 19;
%segmentedFeaturesSizes("LawsEnergy") = 1;
%segmentedFeaturesSizes("SkeletonMetrics") = 3;
segmentedFeaturesSizes("CIVE") = 8;
%segmentedFeaturesSizes("Venation") = 2;
% segmentedFeaturesSizes("LBP") = 59;
%segmentedFeaturesSizes("GLCM") = 64;
% segmentedFeaturesSizes("Lacunarity") = 3;
%segmentedFeaturesSizes("Gabor") = 2;

maskFeaturesSizes = configureDictionary("string","uint8");
maskFeaturesSizes("ShapeRatios") = 4;
maskFeaturesSizes("HuMoments") = 7;
%maskFeaturesSizes('PhysiologicalLength') = 1;
%maskFeaturesSizes('PhysiologicalWidth') = 1;
maskFeaturesSizes('Edge') = 16;
maskFeaturesSizes('ContourFourier') = 10;
%maskFeaturesSizes('FractalDimension') = 1;
maskFeaturesSizes('Eccentricity') = 1;
maskFeaturesSizes('AspectRatio') = 1;
% maskFeaturesSizes('Area') = 1;
% smaskFeaturesSizes('NarrowFactor') = 1;
%maskFeaturesSizes('CentroidCoordinates') = 2;
%maskFeaturesSizes("Fourier") = 20;

% Extract feature names from function names: extractABC -> ABC
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