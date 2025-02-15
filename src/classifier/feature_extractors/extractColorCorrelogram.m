function correlogram = extractColorCorrelogram(segmentedImg)
% 1. Color reduction and parameters
quantizedImg = rgb2ind(segmentedImg, 16);
correlogram = zeros(1,6);

% 2. Direct mapping index -> (distance, color)
% Original positions: 5,8,3,21,29,45
% Conversion to (distance, color):
params = [
    1, 4;   % Pos5: d=1, color4
    1, 7;   % Pos8: d=1, color7
    1, 2;   % Pos3: d=1, color2
    3, 4;   % Pos21: d=3, color4
    3, 12;  % Pos29: d=3, color12
    5, 12;  % Pos45: d=5, color12
    ];

% 3. Targeted computation for each parameter
for i = 1:size(params,1)
    d = params(i,1);
    c = params(i,2);

    % Mask for the target color
    mask = (quantizedImg == c);

    % Shift in 4 cardinal directions
    shifted = circshift(mask, [d 0]) | circshift(mask, [-d 0]) ...
        | circshift(mask, [0 d]) | circshift(mask, [0 -d]);

    % Probability with error handling
    totalPixels = sum(mask(:));
    if totalPixels > 0
        prob = sum(mask(:) & shifted(:)) / totalPixels;
    else
        prob = 0;
    end

    correlogram(i) = prob;
end
end