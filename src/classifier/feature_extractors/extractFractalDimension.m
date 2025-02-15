function fd = extractFractalDimension(maskImg)
    % 1. Image preparation
    targetSize = 128; % Fixed dimension for consistency
    binImg = imresize(im2gray(maskImg), [targetSize targetSize]) > 0;
    
    % 2. Controlled parameters
    minBoxSize = 8; % Minimum box size
    maxBoxSize = 64; % Maximum box size
    scales = 2.^(log2(minBoxSize):1:log2(maxBoxSize)); % Geometric scales
    
    % 3. Robust box-counting
    counts = zeros(size(scales));
    for k = 1:length(scales)
        boxSize = scales(k);
        [rows, cols] = size(binImg);
        
        % Adaptive grid computation
        xBlocks = floor(cols/boxSize);
        yBlocks = floor(rows/boxSize);
        
        if xBlocks == 0 || yBlocks == 0
            counts(k) = NaN;
            continue;
        end
        
        count = 0;
        for i = 1:yBlocks
            for j = 1:xBlocks
                yRange = (i-1)*boxSize+1 : min(i*boxSize, rows);
                xRange = (j-1)*boxSize+1 : min(j*boxSize, cols);
                
                if any(any(binImg(yRange, xRange)))
                    count = count + 1;
                end
            end
        end
        counts(k) = count;
    end
    
    % 4. Regression with validation
    validIdx = ~isnan(counts) & (counts > 0);
    if sum(validIdx) < 2
        fd = 0; % Fallback for degenerate cases
    else
        p = polyfit(log(1./scales(validIdx)), log(counts(validIdx)), 1);
        fd = abs(p(1)); % Force positive value
    end
    
    % 5. Final normalization
    fd = max(0, min(fd, 2)); % Theoretical range 0-2
end