% Definisci il percorso dove vuoi salvare il modello
modelPath = 'knn_model.mat';

% Controlla se il modello esiste già
if exist(modelPath, 'file')
    % Carica il modello esistente
    load(modelPath, 'classifier_knn');
    disp('Modello KNN caricato.');
else
    % Addestra il modello KNN
    classifier_knn = fitcknn(train_values, train_labels, 'NumNeighbors', 11);
    % Salva il modello
    save(modelPath, 'classifier_knn');
    disp('Fine Addestramento classificatore KNN e modello salvato.');
end
