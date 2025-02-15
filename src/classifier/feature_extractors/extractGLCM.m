function out = extractGLCM(image)
image = rgb2gray(image);
m = graycomatrix(image);
out = m(:)' / sum(m(:));
end