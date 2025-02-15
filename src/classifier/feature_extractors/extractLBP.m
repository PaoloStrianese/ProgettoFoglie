function out=extractLBP(image)
image = rgb2gray(image);
out = extractLBPFeatures(image,'NumNeighbors',8,'Radius',1,'Upright',true);
end