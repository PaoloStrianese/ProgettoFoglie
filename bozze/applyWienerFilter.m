function filteredImg = applyWienerFilter(inputImg, windowSize)
    if size(inputImg, 3) == 3
        grayImg = rgb2gray(inputImg);
    else
        grayImg = inputImg;
    end
    
    filteredImg = wiener2(grayImg, [windowSize windowSize]);
    
    figure;
    subplot(1, 2, 1);
    imshow(grayImg);
    title('Immagine originale');
    subplot(1, 2, 2);
    imshow(filteredImg);
    title('Immagine filtrata con Wiener');
end
