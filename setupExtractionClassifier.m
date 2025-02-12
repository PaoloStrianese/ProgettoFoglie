function [segmentedFunctions, maskFunctions, segmentedFeatures, maskFeatures, featuresNames] = setupExtractionClassifier(imagesCount)

featuresExtractorFolder = "feature_extractors";

addpath(genpath(featuresExtractorFolder));

%% Define feature extractors

% Segmented feature extractors
segmentedFunctions = { ...
    @extractLBP, ...
    @extractGLCM, ...
    @extractColor,...
    @extractLacunarity,...
    };

% Mask feature extractors
maskFunctions = { ...
    @extractHuMoments,...
    @extractPhysiologicalLength,...
    @extractPhysiologicalWidth,...
    @extractArea,...
    @extractEccentricity,...
    @extractCentroidCoordinates,...
    @extractAspectRatio,...
    @extractCompactness,...
    @extractRectangularity,...
    @extractNarrowFactor,...
    @extractPerimeterDiameterRatio,...
    @extractFourier,...
    %@extractPerimeter,...
    %@extractCircularity,...
    };

%% Define feature sizes for preallocation
segmentedFeaturesSizes = configureDictionary("string","uint8");
segmentedFeaturesSizes("LBP") = 59;
segmentedFeaturesSizes("GLCM") = 64;
segmentedFeaturesSizes("Color") = 9;
segmentedFeaturesSizes("Lacunarity") = 3;

maskFeaturesSizes = configureDictionary("string","uint8");
maskFeaturesSizes("HuMoments") = 7;
maskFeaturesSizes('PhysiologicalLength') = 1;
maskFeaturesSizes('PhysiologicalWidth') = 1;
maskFeaturesSizes('Area') = 1;
%maskFeaturesSizes('Perimeter') = 1;
maskFeaturesSizes('Eccentricity') = 1;
maskFeaturesSizes('CentroidCoordinates') = 2;
maskFeaturesSizes('AspectRatio') = 1;
%maskFeaturesSizes('Circularity') = 1;
maskFeaturesSizes('Compactness') = 1;
maskFeaturesSizes('Rectangularity') = 1;
maskFeaturesSizes('NarrowFactor') = 1;
maskFeaturesSizes('PerimeterDiameterRatio') = 1;
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