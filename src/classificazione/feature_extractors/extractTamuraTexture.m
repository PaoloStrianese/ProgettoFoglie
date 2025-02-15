function features = extractTamuraTexture(segmentedImg)
    grayImg = im2gray(segmentedImg);
    
    % Coarseness
    Sbest = zeros(size(grayImg));
    for k = 1:5
        windowSize = 2^k;
        kernel = ones(windowSize)/(windowSize^2);
        avg = imfilter(grayImg, kernel, 'replicate');
        diff = grayImg - avg;
        S = abs(imfilter(diff, ones(3)/9));
        Sbest(S > Sbest) = windowSize;
    end
    coarseness = mean(Sbest(:));
    
    % Contrast
    sigma = std2(grayImg);
    kurt = kurtosis(double(grayImg(:)));
    contrast = sigma/(kurt^0.25);
    
    % Directionality
    [Gx, Gy] = imgradientxy(grayImg);
    theta = atan2(Gy, Gx);
    thetaQuantized = round(theta*(16/(2*pi))); % 16 bin
    directionality = entropy(thetaQuantized);
    
    features = [coarseness, contrast, directionality];
end