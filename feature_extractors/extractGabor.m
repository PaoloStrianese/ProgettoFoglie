function features = extractGabor(img)
    if size(img,3) == 3
        img = rgb2gray(img);
    end
    
    % Configurazione filtri Gabor
    wavelength = [2,4,8,16];
    orientation = 0:30:150;
    g = gabor(wavelength, orientation);
    
    % Applica filtri
    gabormag = imgaborfilt(im2double(img), g);
    
    % Estrai media e deviazione standard
    features = [mean(gabormag(:)), std(gabormag(:))];
end