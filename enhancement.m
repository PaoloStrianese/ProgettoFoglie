function [imgEnhanced] = enhancement(imgRGB)
% Conversione in HSV
imgHSV = rgb2hsv(imgRGB);

% Rimozione delle ombre
saturation = imgHSV(:, :, 2); % Canale di saturazione
shadowMask = saturation < 0.2; % Maschera delle ombre
imgHSV(:, :, 3) = imgHSV(:, :, 3) .* ~shadowMask + 0.2 * shadowMask; % Aumento della luminosità

% Conversione in RGB
imgEnhanced = hsv2rgb(imgHSV);
end
