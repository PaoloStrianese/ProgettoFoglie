
tempo estrazione features training: ~45-50 sec
tempo estrazione features testing: ~70-80 sec
tempo training modello: ~15 sec

## estrazione su foglie segmentate
extractColor = 25%
extractExG = 34%
extractExGR = 34%
extractCIVE = 30%
extractCanny = 19%
extractHaralick = 20%
extractWavelet = 24%
extractHOG = 15%
extractVenation = 13%
extractGabor = 19%
extractTamuraTexture = 23%
extractColorCorrelogram = 15%
extractLBP = 25%
extractGLCM = 20%
extractLacunarity = 11%
extractSkeletonMetrics = 28%
extractLawsEnergy = 6%

## estrazione sulle maschere di foglie
extractEdge = 66%
extractShapeRatios = 40%
extractHuMoments = 54%
extractContourFourier = 53%
extractEccentricity = 47%
extractAspectRatio =. 40%
extractPhysiologicalLength = 30%
extractPhysiologicalWidth = 30%
extractCentroidCoordinates = 09%
extractNarrowFactor = 18%
extractArea = 11%
extractFractalDimension = 11%
extractFourier = 7%

## combinazioni piu promettenti

color, hu, length, width 54.1%
color, hu, length, width, ExG 63.3%
color, hu, length, width, ExG, ExGR 69%
color, hu, length, width, ExG, ExGR, shapeRatio 70%
color, hu, length, width, ExG, ExGR, shapeRatio, haralick 72.5%
color, hu, ExG, ExGR, shapeRatio, haralick, edge, eccentricity, aspectRatio,ContourFourier 73%
color, hu, ExG, ExGR, shapeRatio, haralick, edge, ContourFourier 76%
color, hu, ExG, ExGR, shapeRatio, haralick, edge 78%
color, hu, length, width, ExG, ExGR, shapeRatio, edge 75%
color, hu, length, width, ExG, ExGR, shapeRatio, edge, haralick 76%