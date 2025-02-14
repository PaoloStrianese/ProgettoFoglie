function features = extractWavelet(img)
% extractWaveletFeatures estrae le caratteristiche wavelet da un'immagine.
%
% INPUT:
%   img         - Immagine in ingresso (grayscale o RGB).
%   waveletName - Nome della wavelet da utilizzare (default: 'haar').
%   level       - Numero di livelli di decomposizione (default: 2).
%
% OUTPUT:
%   features    - Vettore contenente le energie dei coefficienti di dettaglio
%                 per ogni livello e l'energia dei coefficienti di approssimazione
%                 dell'ultimo livello.
%
% Esempio d'uso:
%   I = imread('foglia.jpg');
%   feats = extractWaveletFeatures(I, 'db1', 3);

% Verifica se l'immagine è RGB; in tal caso, converte in grayscale.
if size(img,3) > 1
    img = rgb2gray(img);
end

% Conversione a double per la corretta elaborazione.
img = im2double(img);


waveletName = 'db1';


level = 6;


% Esegue la decomposizione wavelet 2D.
[C,S] = wavedec2(img, level, waveletName);

% Inizializza il vettore delle features.
features = [];

% Per ogni livello, estrai i coefficienti di dettaglio:
% orizzontale (H), verticale (V) e diagonale (D)
for i = 1:level
    [H, V, D] = detcoef2('all', C, S, i);
    % Calcola l'energia per ciascun sottobanda.
    energyH = sum(H(:).^2);
    energyV = sum(V(:).^2);
    energyD = sum(D(:).^2);
    % Concatenazione delle energie nel vettore features.
    features = [features, energyH, energyV, energyD];
end

% Aggiunge l'energia dei coefficienti di approssimazione al livello finale.
A = appcoef2(C, S, waveletName, level);
energyA = sum(A(:).^2);
features = [features, energyA];
end
