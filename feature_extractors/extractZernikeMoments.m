function features = extractZernikeMoments(segmentedImg)
    % Estrae momenti di Zernike rotation-invariant per la forma della foglia
    % Input: Immagine segmentata (RGB o binaria)
    % Output: Vettore di 10 momenti di Zernike (ordine massimo 5)
    
    % Conversione in immagine binaria
    if size(segmentedImg,3) == 3
        binImg = im2gray(segmentedImg) > 0;
    else
        binImg = segmentedImg > 0;
    end
    
    % Parametri
    order = 5;  % Ordine massimo dei polinomi
    radius = 50; % Raggio di normalizzazione
    
    % Calcolo momenti
    [~, A] = zernike_moments(binImg, order, radius);
    
    % Selezione dei 10 momenti più significativi
    features = A(1:10);
    
    % Funzione helper per il calcolo
    function [Z, A] = zernike_moments(img, order, radius)
        [rows,cols] = size(img);
        [x,y] = meshgrid(1:cols,1:rows);
        x = (x - mean(x))/radius;
        y = (y - mean(y))/radius;
        mask = sqrt(x.^2 + y.^2) <= 1;
        
        Z = [];
        A = [];
        for n = 0:order
            for m = -n:2:n
                R = zernike_radial(n, abs(m), sqrt(x.^2 + y.^2));
                theta = atan2(y,x);
                V = R.*exp(1i*m*theta).*mask;
                Z(n+1, (m+n)/2+1) = sum(img(:).*V(:));
                A = [A abs(Z(n+1, (m+n)/2+1))];
            end
        end
    end
end