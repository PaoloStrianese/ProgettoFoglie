function fd = extractContourFourier(maskImg)
% Extract contour
contour = bwperim(maskImg);
[y,x] = find(contour);

% Order contour points
[theta, ~] = cart2pol(x-mean(x), y-mean(y));
[~, order] = sort(theta);
x = x(order);
y = y(order);

% Convert to complex signal
z = complex(x, y);

% Fourier Transform
Z = fft(z);

% Normalize and select coefficients
Z = Z(2:11); % Skip DC component
fd = abs(Z)/abs(Z(1));
end