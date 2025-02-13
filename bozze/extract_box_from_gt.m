addpath('bozze');

% Ottieni la lista di file immagine nella cartella 'X'
immagini = [dir(fullfile('.cache','gt_new', '*.png'))];

% Strofa i nomi dei file
for k = 1:length(immagini)
    name = immagini(k).name;
    parts = strsplit(name, '-');
    pianta = parts{1};
    mask = fullfile('.cache','gt_new',name);
    segmented = fullfile('.cache','gt segm_new',name);
    extract_leaf_region(segmented, mask, name);
end
