function features = extractGabor(img)
    if size(img,3) == 3
        img = rgb2gray(img);
    end
    
    % Gabor filter configuration
    wavelength = [2,4,8,16];
    orientation = 0:30:150;
    g = gabor(wavelength, orientation);
    
    % Apply filters
    gabormag = imgaborfilt(im2double(img), g);
    
    % Extract mean and standard deviation
    features = [mean(gabormag(:)), std(gabormag(:))];
end