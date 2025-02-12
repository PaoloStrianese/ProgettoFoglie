function out = extractLacunarity(image)
% Converte l'immagine in scala di grigi se è a colori
if size(image, 3) == 3
    image = rgb2gray(image);
end
% Converte l'immagine in formato double per il calcolo
img = double(image);

% Definisce una serie di dimensioni di "box" per il calcolo su scale diverse
boxSizes = [4, 8, 16];  % esempio: box di dimensione 4x4, 8x8 e 16x16
lacunarityValues = zeros(1, length(boxSizes));

for i = 1:length(boxSizes)
    b = boxSizes(i);
    % Calcola la somma dei pixel in ciascun blocco bxb tramite blockproc
    fun = @(block_struct) sum(block_struct.data(:));
    blockSums = blockproc(img, [b b], fun);
    % Appiattisce il risultato in un vettore
    blockSums = blockSums(:);
    % Calcola la media e la varianza delle somme nei blocchi
    mu = mean(blockSums);
    sigma2 = var(blockSums);
    % Calcola la lacunarità:
    % Una definizione comune è: L = (varianza)/(media^2) + 1
    lacunarityValues(i) = sigma2 / (mu^2) + 1;
end

% Restituisce un vettore di lacunarità, uno per ciascuna dimensione di box
out = lacunarityValues;
end