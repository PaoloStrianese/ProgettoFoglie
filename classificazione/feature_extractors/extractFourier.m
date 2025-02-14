function out = extractFourier(image)
% Converte l'immagine in scala di grigi (se necessario)
if size(image, 3) == 3
    grayImage = rgb2gray(image);
else
    grayImage = image;
end

% Binarizza l'immagine (threshold adattivo semplice)
bw = imbinarize(grayImage);

% Rimuove piccoli oggetti
bw = bwareaopen(bw, 50);

% Estrae i contorni
boundaries = bwboundaries(bw);

% Seleziona il contorno più lungo (supponendo che sia la foglia)
maxBoundary = [];
maxLength = 0;
for k = 1:length(boundaries)
    boundary = boundaries{k};
    if length(boundary) > maxLength
        maxLength = length(boundary);
        maxBoundary = boundary;
    end
end

% Rappresenta il contorno come numeri complessi: z = x + iy
z = double(maxBoundary(:,2)) + 1i * double(maxBoundary(:,1));

% Calcola la trasformata di Fourier sul contorno
F = fft(z);

% Normalizza per ottenere invarianti rispetto a traslazione e scala:
% - Il DC (F(1)) è influenzato dalla traslazione, quindi lo si scarta
% - Si normalizza dividendo per la magnitudine del secondo coefficiente
F = F / abs(F(2));


% Scarta il termine DC e seleziona i primi N coefficienti
N = 10;  % ad esempio, estraiamo 10 Fourier descriptors
out = double(F(2:(N+1)));
out = [real(out) imag(out)];
out = out(:)';  % restituisce un vettore riga
end
