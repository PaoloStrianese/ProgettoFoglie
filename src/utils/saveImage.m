function saveImage(image, outputFolder, outputName)
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end
outputPath = fullfile(outputFolder, outputName);
imwrite(image, outputPath);
end