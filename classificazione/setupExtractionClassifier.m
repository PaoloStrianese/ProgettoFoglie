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


% edge + ContourFourier = 70%
% edge + ContourFourier + color = 75%
% edge + ContourFourier + color = 77.5%
% edge + ContourFourier + color + Hu= 72.5%
% edge + ContourFourier + color + Shape = 77.5%
% edge + ContourFourier + color + Eccentricity = 75.8%
% edge + ContourFourier + color + Area = 77.5%
% edge + ContourFourier + Area = 72.5%
% edge + ContourFourier + TamuraTexture= 72% ma 91%


% edge + ContourFourier + Eccentricy = 73 e 83
% hu + ContourFourier  = 60 e 60
% edge + ContourFourier + hu = 65 e 85
% edge + ContourFourier + hu + color = 71 e 82
% edge + ContourFourier + hu + exG = schifo


% edge + ContourFourier + Eccentricy + color = 74 e 85
% edge + ContourFourier + Eccentricy + + color + extractExG = 73 e 83
% edge + ContourFourier + Eccentricy + color + aspectradio = 75 e 84,4
% edge + ContourFourier + Eccentricy + color + extractExG = 74 e 88,4

% Segmented feature extractors
segmentedFunctions = { ...
    @extractColor,... %0.45
    @extractExG,... 0.37
    % DA TOGLIERE @extractExGR,... 0.35
    % DA TOGLIERE @extractCanny,... 0.3
    % DA TOGLIERE @extractHaralick,... 0.3
    % DA TOGLIERE @extractCIVE,... 0.3
    % DA TOGLIERE @extractWavelet,... 0.1
    % DA TOGLIERE @extractHOG,... 0.25
    % DA TOGLIERE @extractVenation,... 0.16
    % DA TOGLIERE @extractGabor,... 0.20
    % DA TOGLIERE @extractTamuraTexture,... 0.18
    % DA TOGLIERE @extractColorCorrelogram,... 0.09
    %@extractLBP, ... 0.35
    % DA TOGLIERE @extractGLCM, ... 0.22
    % DA TOGLIERE @extractLacunarity,... 0.26
    % DA TOGLIERE @extractSkeletonMetrics, ... 0.09
    % DA TOGLIERE @extractLawsEnergy,... 0.09

    };

% Mask feature extractors
maskFunctions = { ...
    @extractEdge,... %0.55
    @extractContourFourier,... %0.60
    @extractEccentricity,... %0.42
    %@extractAspectRatio,.... %0.39
    %@extractHuMoments,... 0.33
    % DA TOGLIERE @extractArea,... 0.18
    % DA TOGLIERE @extractShapeRatios,... %0.38
    % DA TOGLIERE @extractPhysiologicalLength,... 0.10
    % DA TOGLIERE @extractPhysiologicalWidth,... 0.30
    % DA TOGLIERE @extractCentroidCoordinates,... 0.10
    % DA TOGLIERE @extractNarrowFactor,... 0.10
    % DA TOGLIERE @extractFractalDimension,... 0.10
    };

%% Define feature sizes for preallocation
segmentedFeaturesSizes = configureDictionary("string","uint8");
%segmentedFeaturesSizes("Canny") = 16;
segmentedFeaturesSizes("Color") = 33;
segmentedFeaturesSizes("ExG") = 8;
% segmentedFeaturesSizes("ExGR") = 8;
% segmentedFeaturesSizes("CIVE") = 8;
% segmentedFeaturesSizes("Haralick") = 4;

% segmentedFeaturesSizes("HOG") = 36;
% segmentedFeaturesSizes("TamuraTexture") = 3;
% segmentedFeaturesSizes("ColorCorrelogram") = 6;
% segmentedFeaturesSizes("Wavelet") = 19;
%segmentedFeaturesSizes("LawsEnergy") = 1;
%segmentedFeaturesSizes("SkeletonMetrics") = 3;
%segmentedFeaturesSizes("Venation") = 2;
%segmentedFeaturesSizes("LBP") = 59;
%segmentedFeaturesSizes("GLCM") = 64;
% segmentedFeaturesSizes("Lacunarity") = 3;
%segmentedFeaturesSizes("Gabor") = 2;

maskFeaturesSizes = configureDictionary("string","uint8");
%maskFeaturesSizes("ShapeRatios") = 4;

%maskFeaturesSizes("HuMoments") = 7;
maskFeaturesSizes('Edge') = 16;
maskFeaturesSizes('ContourFourier') = 10;
maskFeaturesSizes('Eccentricity') = 1;

maskFeaturesSizes('AspectRatio') = 1;
%maskFeaturesSizes('PhysiologicalLength') = 1;
%maskFeaturesSizes('PhysiologicalWidth') = 1;
%maskFeaturesSizes('FractalDimension') = 1;
%maskFeaturesSizes('Area') = 1;
% maskFeaturesSizes('NarrowFactor') = 1;
% maskFeaturesSizes('CentroidCoordinates') = 2;

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