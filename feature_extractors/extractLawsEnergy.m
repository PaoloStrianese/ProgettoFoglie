function energy = extractLawsEnergy(segmentedImg)
    % Estrae energia texture con filtri di Laws
    % Input: Immagine segmentata RGB
    % Output: Energia texture normalizzata
    
    % Filtri L5E5
    L5 = [1 4 6 4 1];         % Livello
    E5 = [-1 -2 0 2 1];       % Bordo
    kernel = L5' * E5;        % Kernel 2D
    
    % Applicazione filtro
    filtered = imfilter(im2gray(segmentedImg), kernel, 'conv');
    
    % Calcolo energia
    energy = mean2(abs(filtered));
end