function correlogram = extractColorCorrelogram(segmentedImg)
    % Calcola il correlogramma per posizioni specifiche (5,8,3,21,29,45)
    % Input: Immagine segmentata RGB
    % Output: Vettore 1x6 [d1-c4, d1-c7, d1-c2, d3-c4, d3-c12, d5-c12]
    
    % 1. Riduzione colori e parametri
    quantizedImg = rgb2ind(segmentedImg, 16);
    correlogram = zeros(1,6);
    
    % 2. Mappatura diretta indice -> (distanza, colore)
    % Posizioni originali: 5,8,3,21,29,45
    % Conversione a (distanza, colore):
    params = [
        1, 4;   % Pos5: d=1, colore4
        1, 7;   % Pos8: d=1, colore7
        1, 2;   % Pos3: d=1, colore2
        3, 4;   % Pos21: d=3, colore4
        3, 12;  % Pos29: d=3, colore12
        5, 12;  % Pos45: d=5, colore12
    ];
    
    % 3. Calcolo mirato per ogni parametro
    for i = 1:size(params,1)
        d = params(i,1);
        c = params(i,2);
        
        % Maschera per il colore target
        mask = (quantizedImg == c);
        
        % Shift in 4 direzioni cardinali
        shifted = circshift(mask, [d 0]) | circshift(mask, [-d 0])...
               | circshift(mask, [0 d]) | circshift(mask, [0 -d]);
        
        % Probabilità con gestione errori
        totalPixels = sum(mask(:));
        if totalPixels > 0
            prob = sum(mask(:) & shifted(:)) / totalPixels;
        else
            prob = 0;
        end
        
        correlogram(i) = prob;
    end
end