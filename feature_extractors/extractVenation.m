function [out] = extractVenation(img)
% extractVenationFeatures Estrae le caratteristiche della rete venosa di una foglia.
%
% Sintassi:
%   [veinDensity, branchDensity] = extractVenationFeatures(img)
%
% Input:
%   img - Immagine della foglia (RGB o in scala di grigi)
%
% Output:
%   veinDensity   - Densità delle venature (rapporto tra pixel della venatura e pixel totali)
%   branchDensity - Densità dei punti di ramificazione (numero di branchpoints normalizzato per l'area)
%
% Descrizione:
%   La funzione esegue i seguenti passaggi:
%     1. Converte l'immagine in scala di grigi (se necessario) e la normalizza.
%     2. Applica un filtro mediano per ridurre il rumore.
%     3. Segmenta l'immagine mediante una soglia (Otsu) per ottenere una mappa binaria.
%        (Viene effettuata una inversione se le venature appaiono scure su sfondo chiaro.)
%     4. Pulisce la mappa binaria rimuovendo oggetti troppo piccoli.
%     5. Esegue la skeletonizzazione per ottenere la struttura monolineare della rete venosa.
%     6. Calcola la densità delle venature e dei punti di ramificazione.

% Se l'immagine è RGB, convertila in scala di grigi
if size(img,3) == 3
    imgGray = rgb2gray(img);
else
    imgGray = img;
end

% Conversione a double per una migliore precisione
imgGray = im2double(imgGray);

% Riduzione del rumore con filtro mediano
imgFiltered = medfilt2(imgGray, [3 3]);

% Segmentazione mediante soglia di Otsu
threshold = graythresh(imgFiltered);
bw = imbinarize(imgFiltered, threshold);

% Se le venature sono scure su sfondo chiaro, invertire l'immagine binaria
% (la maggior parte dei metodi assume venature bianche su fondo nero)
if mean(bw(:)) > 0.5
    bw = ~bw;
end

% Rimozione di piccoli oggetti per eliminare il rumore
bw = bwareaopen(bw, 50);

% Skeletonizzazione: riduce la rete venosa a una linea sottile
skel = bwmorph(bw, 'skel', Inf);

% Calcola la densità delle venature: rapporto tra pixel della skeleton e pixel totali
veinDensity = sum(skel(:)) / numel(skel);

% Estrazione dei punti di ramificazione dalla skeleton
branchPoints = bwmorph(skel, 'branchpoints');
branchCount = sum(branchPoints(:));

% Calcola la densità dei branchpoints: normalizzazione per l'area totale
branchDensity = branchCount / numel(skel);

out = [veinDensity, branchDensity];
end
