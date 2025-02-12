addpath('bozze')

% Ottieni la lista di file immagine nella cartella 'X'
immagini = [dir(fullfile('.cache','gt_old', '*.png'))];

% Strofa i nomi dei file
for k = 1:length(immagini)
    name = immagini(k).name;
    parts = strsplit(name, '-');
    pianta = parts{1};
    mask = fullfile('.cache','gt_old',name);
    segmented = fullfile('.cache','gt_segmented_old',name);
    extract_leaf_region(segmented, mask, name);
end
