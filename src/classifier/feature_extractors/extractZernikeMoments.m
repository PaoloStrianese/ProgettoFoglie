function features = extractZernikeMoments(segmentedImg)
% Convert image to binary image
if size(segmentedImg,3) == 3
    binImg = im2gray(segmentedImg) > 0;
else
    binImg = segmentedImg > 0;
end

% Parameters
order = 5;  % Maximum order of the polynomials
radius = 50; % Normalization radius

% Calculate moments
[~, A] = zernike_moments(binImg, order, radius);

% Select the 10 most significant moments
features = A(1:10);

% Helper function for the calculation
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