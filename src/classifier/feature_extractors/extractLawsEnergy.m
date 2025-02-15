function energy = extractLawsEnergy(segmentedImg)
    % L5E5 filters
    L5 = [1 4 6 4 1];         % Level
    E5 = [-1 -2 0 2 1];       % Edge
    kernel = L5' * E5;        % 2D kernel
    
    % Apply filter
    filtered = imfilter(im2gray(segmentedImg), kernel, 'conv');
    
    % Calculate energy
    energy = mean2(abs(filtered));
end