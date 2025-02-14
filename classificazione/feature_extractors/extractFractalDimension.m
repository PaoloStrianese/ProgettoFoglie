function fd = extractFractalDimension(maskImg)
    % Calcola la dimensione frattale tramite box-counting
    % Input: Maschera binaria (qualsiasi dimensione)
    % Output: Valore scalare 1x1 tra 0 e 2
    
    % 1. Preparazione immagine
    targetSize = 128; % Dimensione fissa per consistenza
    binImg = imresize(im2gray(maskImg), [targetSize targetSize]) > 0;
    
    % 2. Parametri controllati
    minBoxSize = 8; % Dimensione minima del box
    maxBoxSize = 64; % Dimensione massima del box
    scales = 2.^(log2(minBoxSize):1:log2(maxBoxSize)); % Scale geometriche
    
    % 3. Box-counting robusto
    counts = zeros(size(scales));
    for k = 1:length(scales)
        boxSize = scales(k);
        [rows, cols] = size(binImg);
        
        % Calcolo griglia adattativo
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
    
    % 4. Regressione con validazione
    validIdx = ~isnan(counts) & (counts > 0);
    if sum(validIdx) < 2
        fd = 0; % Fallback per casi degeneri
    else
        p = polyfit(log(1./scales(validIdx)), log(counts(validIdx)), 1);
        fd = abs(p(1)); % Forza valore positivo
    end
    
    % 5. Normalizzazione finale
    fd = max(0, min(fd, 2)); % Range teorico 0-2
end