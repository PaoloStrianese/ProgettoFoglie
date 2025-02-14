function fd = extractContourFourier(maskImg)
    % Estrae descrittori di Fourier dal contorno
    % Input: Maschera binaria
    % Output: Primi 10 coefficienti normalizzati
    
    % Estrazione contorno
    contour = bwperim(maskImg);
    [y,x] = find(contour);
    
    % Ordina i punti del contorno
    [theta, ~] = cart2pol(x-mean(x), y-mean(y));
    [~, order] = sort(theta);
    x = x(order);
    y = y(order);
    
    % Conversione in segnale complesso
    z = complex(x, y);
    
    % Trasformata di Fourier
    Z = fft(z);
    
    % Normalizzazione e selezione coefficienti
    Z = Z(2:11); % Salta il componente DC
    fd = abs(Z)/abs(Z(1));
end