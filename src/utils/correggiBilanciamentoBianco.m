function I_corr = correggiBilanciamentoBianco(I, rect)
% correggiBianco applica una correzione del colore basata su una regione
% di riferimento che si assume essere bianca.
%
% USO:
%   I_corr = correggiBianco(I, rect)
%
%   - I: immagine in ingresso (può essere uint8 o double). Se non è di
%        tipo double con valori fra 0 e 1, verrà convertita.
%   - rect: vettore [riga, colonna, altezza, larghezza] che definisce la
%           regione in alto a sinistra da considerarsi come bianco reale.
%
%   - I_corr: immagine corretta in formato double, con valori normalizzati
%             fra 0 e 1.
%
% Esempio:
%   I = imread('immagineFoglie.jpg');
%   % Supponendo che la regione [1, 1, 50, 50] debba essere bianca:
%   I_corr = correggiBianco(I, [1, 1, 50, 50]);
%   imshow(I_corr);
I_corr = I;
return;
% Se l'immagine non è in formato double o i suoi valori superano 1,
% viene effettuata la conversione
if ~isfloat(I) || max(I(:)) > 1
    I = im2double(I);
end

if nargin < 2
    % Definisce una regione che occupa il 10% dell'immagine in alto a sinistra
    [nr, nc, ~] = size(I);
    rect = [1, 1, floor(nr*0.02), floor(nc*0.02)];
end

% Estrazione della regione di riferimento
r0 = rect(1);
c0 = rect(2);
h  = rect(3);
w  = rect(4);

% Verifica che la regione non esca dai limiti dell'immagine
[nr, nc, ~] = size(I);
if r0 + h - 1 > nr || c0 + w - 1 > nc
    error('La regione definita esce dai limiti dell''immagine.');
end

whiteRegion = I(r0 : r0 + h - 1, c0 : c0 + w - 1, :);

% Calcolo del valore medio della regione per ciascun canale
if size(I,3) == 1
    % Caso in scala di grigi
    mediaWhite = mean(whiteRegion(:));
    gain = 1 / mediaWhite;
    I_corr = I * gain;
else
    % Caso RGB (o multicanale)
    numCanali = size(I,3);
    gain = zeros(1, numCanali);
    for k = 1 : numCanali
        mediaWhite = mean2( whiteRegion(:,:,k) );
        gain(k) = 1 / mediaWhite;
    end

    % Applica la correzione canale per canale
    I_corr = zeros(size(I));
    for k = 1 : numCanali
        I_corr(:,:,k) = I(:,:,k) * gain(k);
    end
end

% Assicura che i valori siano compresi tra 0 e 1
I_corr(I_corr > 1) = 1;
I_corr(I_corr < 0) = 0;
end
