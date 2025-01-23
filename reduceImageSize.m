function resizedImg = reduceImageSize(imagePath, targetSize)
    % Carica l'immagine
    img = imread(imagePath);
    
    % Riduci la dimensione dell'immagine
    resizedImg = imresize(img, targetSize);
    
    % Visualizza l'immagine originale e ridotta
    figure;
    subplot(1, 2, 1);
    imshow(img);
    title('Immagine originale');
    
    subplot(1, 2, 2);
    imshow(resizedImg);
    title(['Immagine ridotta a ', num2str(targetSize(1)), 'x', num2str(targetSize(2))]);
end
function [outputArg1,outputArg2] = untitled2(inputArg1,inputArg2)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
outputArg1 = inputArg1;
outputArg2 = inputArg2;
end