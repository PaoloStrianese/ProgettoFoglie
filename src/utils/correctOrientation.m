function imgCorrected = correctOrientation(imagePath)
warning('off');
info = imfinfo(imagePath);
imgCorrected = imread(imagePath);
if isfield(info, 'Orientation')
    switch info.Orientation
        case 1  % Normal, no rotation needed.
            return;
        case 3  % 180 degree rotation.
            imgCorrected = imrotate(imgCorrected, 180);
        case 6  % 90 degrees clockwise.
            imgCorrected = imrotate(imgCorrected, -90);
        case 8  % 90 degrees counterclockwise.
            imgCorrected = imrotate(imgCorrected, 90);
        otherwise
            warning('Orientation %d not specifically handled.', info.Orientation);
    end
end
end