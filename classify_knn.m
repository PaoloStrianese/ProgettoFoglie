clear all;
close all;

excel_path_leaf = 'C:\Users\Utente\git\ProgettoFoglie\dataset\leaf_mosaic.xlsx';
excel_path_bg = 'C:\Users\Utente\git\ProgettoFoglie\dataset\bg_mosaic.xlsx';

% Lettura dati RGB dall'Excel
disp('Inizio Lettura dati RGB da Excel...');
leaf_data = readtable(excel_path_leaf);
bg_data = readtable(excel_path_bg);
disp('Fine Lettura dati RGB da Excel.');

% Conversione tabella in array
disp('Conversione delle tabelle in array...');
rgb_leaf = table2array(leaf_data);
rgb_bg = table2array(bg_data);
disp('Conversione completata.');

disp('Dati RGB caricati da Excel');

rgb_leaf = rgb_leaf(1:1000,:);
rgb_bg = rgb_bg(1:1000,:);

% Concateniamo i dati in un unico array per l'addestramento
train_values = [rgb_leaf; rgb_bg];

% Creiamo le etichette per il training: 1 = foglia
train_labels = ones(size(train_values, 1), 1);
nrs = size(rgb_leaf, 1);
train_labels(nrs + 1:end) = 0;

% Addestramento del classificatore KNN
disp('Inizio Addestramento classificatore KNN...');
classifier_knn = fitcknn(train_values, train_labels, 'NumNeighbors', 11);
disp('Fine Addestramento classificatore KNN.');

% Caricamento immagine di test
disp('Caricamento immagine di test...');
image = im2double(imread('C:\Users\Utente\git\ProgettoFoglie\dataset\Pianta 10\04.jpg'));
[ir, ic, ich] = size(image);
test_values = reshape(image, ir * ic, ich);
disp('Immagine di test caricata e riorganizzata.');

% Classificazione dei dati di test con il classificatore
disp('Classificazione dei dati di test con il classificatore KNN...');
test_predicted = predict(classifier_knn, test_values);
disp('Classificazione completata.');

% Ristrutturazione del vettore delle etichette in una immagine
mask_predicted = reshape(test_predicted, ir, ic);

% Visualizzazione dei risultati
disp('Visualizzazione dei risultati...'); 
show_result(image, mask_predicted);

% Calcolo delle performance di classificazione
%gt = imread('test1-gt.png');
%cm = confmat(gt > 0, mask_predicted > 0);
