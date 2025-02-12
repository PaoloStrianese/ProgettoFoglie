function [segmentedFunctions, maskFunctions, segmentedFeatures, maskFeatures, featuresNames] = setupExtractionClassifier(imagesCount)

featuresExtractorFolder = "feature_extractors";

addpath(genpath(featuresExtractorFolder));

%% Define feature extractors

% color, hu, length, width 0.541
% color, hu, length, width, ExG 0.633

% Segmented feature extractors
segmentedFunctions = { ...
    @extractExGR,... %0.34
    @extractExG,... %0.34
    @extractColor,... %0.425
    %@extractCIVE,... %0.30
    %@extractLBP, ...0.% 25
    %@extractGLCM, ... % 0.20
    %@extractLacunarity,... %0.11
    %     %@extractHaralick,...
    %     %@extractGabor,...

    };

% Mask feature extractors
maskFunctions = { ...
    @extractHuMoments,... %0.54
    @extractPhysiologicalLength,... %0.3
    @extractPhysiologicalWidth,... %0.3
    % @extractRectangularity,...
    % @extractEccentricity,...
    % @extractCentroidCoordinates,...
    % @extractAspectRatio,...
    % @extractCompactness,...
    % @extractNarrowFactor,...
    % @extractPerimeterDiameterRatio,...
    %@extractArea,... %0.11
    %@extractFourier,... %0.075
    %@extractPerimeter,...
    %@extractCircularity,...
    };

%% Define feature sizes for preallocation
segmentedFeaturesSizes = configureDictionary("string","uint8");
% segmentedFeaturesSizes("LBP") = 59;
%segmentedFeaturesSizes("GLCM") = 64;
segmentedFeaturesSizes("Color") = 33;
segmentedFeaturesSizes("ExG") = 8;
segmentedFeaturesSizes("ExGR") = 8;
%segmentedFeaturesSizes("CIVE") = 8;
%segmentedFeaturesSizes("Lacunarity") = 3;
% segmentedFeaturesSizes("Haralick") = 4;
% segmentedFeaturesSizes("Gabor") = 2;

maskFeaturesSizes = configureDictionary("string","uint8");
maskFeaturesSizes("HuMoments") = 7;
maskFeaturesSizes('PhysiologicalLength') = 1;
maskFeaturesSizes('PhysiologicalWidth') = 1;
%maskFeaturesSizes('Area') = 1;
% %maskFeaturesSizes('Perimeter') = 1;
% maskFeaturesSizes('Eccentricity') = 1;
% maskFeaturesSizes('CentroidCoordinates') = 2;
% maskFeaturesSizes('AspectRatio') = 1;
% %maskFeaturesSizes('Circularity') = 1;
% maskFeaturesSizes('Compactness') = 1;
%maskFeaturesSizes('Rectangularity') = 1;
% maskFeaturesSizes('NarrowFactor') = 1;
% maskFeaturesSizes('PerimeterDiameterRatio') = 1;
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