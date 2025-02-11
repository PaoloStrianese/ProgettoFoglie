function [mosaicLeaf, mosaicBackground]=generateMosaicImage(mosaicLeafName, mosaicBackgroundName, datasetFolder, groundtruthFolder, cacheFolder)
%% Parametri generali
patchSize = 10;         % dimensione del patch (20x20 pixel)
patchSizeBG = 50;       % dimensione del patch per il background
numRows = 8;           % numero di righe della griglia
numCols = 10;           % numero di colonne della griglia
maxPatches = numRows * numCols;  % numero massimo di patch (100)

% Cartelle di lavoro

masksFolder = fullfile(cacheFolder,'mask');
imagesFolder = fullfile(cacheFolder,'images');
mosaicLeafName= fullfile(cacheFolder,mosaicLeafName);
mosaicBGName= fullfile(cacheFolder, mosaicBackgroundName);


if ~exist(imagesFolder, 'dir')
    transferFiles(datasetFolder, imagesFolder);
end
if ~exist(masksFolder, 'dir')
    transferFiles(groundtruthFolder, masksFolder);
end



% Leggi la lista delle maschere (si assume formato PNG) e ordinale
maskFiles = dir(fullfile(masksFolder, '*.png'));
[~, idx] = sort({maskFiles.name});
maskFiles = maskFiles(idx);

% Inizializza i contatori e le variabili per i due mosaici
patchCountLeaf = 0;
patchCountBG   = 0;
mosaicLeafInitialized = false;
mosaicBGInitialized   = false;

%% Ciclo unico: per ogni maschera si estraggono la patch "leaf" e quella "background"
for k = 1:length(maskFiles)
    % Esci dal ciclo se entrambi i mosaici hanno raccolto 100 patch
    if (patchCountLeaf >= maxPatches) && (patchCountBG >= maxPatches)
        break;
    end

    % -------------------- Parte LEAF --------------------
    % Leggi l'immagine di maschera
    maskName = maskFiles(k).name;
    maskPath = fullfile(masksFolder, maskName);
    maskImg = imread(maskPath);

    % Se l'immagine è a colori la converto in scala di grigi
    if size(maskImg,3) == 3
        maskImg = rgb2gray(maskImg);
    end

    % Binarizza la maschera (si assume che i pixel > 0 rappresentino la regione)
    binaryMask = maskImg > 0;

    % Trova le componenti connesse
    cc = bwconncomp(binaryMask);
    if cc.NumObjects == 0
        warning('Nessuna regione trovata in %s. Skip per la parte LEAF.', maskName);
    else
        % Seleziona la regione con area massima
        stats_temp = regionprops(cc, 'Area');
        areas = [stats_temp.Area];
        [~, idxMax] = max(areas);
        % Mantieni solo la più grande
        cc.PixelIdxList = cc.PixelIdxList(idxMax);
        cc.NumObjects = 1;
        % Estrai le proprietà della regione
        stats = regionprops(cc, 'BoundingBox');
        bbox = stats.BoundingBox;  % [x, y, width, height]

        % Calcola il centro della bounding box (arrotondato)
        centerX = round(bbox(1) + bbox(3)/2);
        centerY = round(bbox(2) + bbox(4)/2);

        % Carica l'immagine corrispondente dalla cartella "dataset"
        [~, name, ~] = fileparts(maskName);
        imagePath = fullfile(imagesFolder, strcat(name, '.jpg'));
        if ~exist(imagePath, 'file')
            warning('Immagine %s non trovata in %s. Skip per la parte LEAF.', imagePath, imagesFolder);
        else
            % Leggi le informazioni e l'immagine originale (non ridimensionata)
            info = imfinfo(imagePath);
            imgOriginal = imread(imagePath);

            % Correggi l'orientamento se necessario (sia per leaf che per background)
            if isfield(info, 'Orientation')
                switch info.Orientation
                    case 1
                        % Nessuna operazione
                    case 3
                        imgOriginal = imrotate(imgOriginal, 180);
                    case 6
                        imgOriginal = imrotate(imgOriginal, -90);
                    case 8
                        imgOriginal = imrotate(imgOriginal, 90);
                    otherwise
                        warning('Orientamento non gestito: %d', info.Orientation);
                end
            end
            imgOriginal = correggiBilanciamentoBianco(imgOriginal);

            % Per la parte LEAF si ridimensiona l'immagine in modo che le dimensioni
            % corrispondano a quelle della maschera
            imgResized = imresize(imgOriginal, [size(maskImg,1), size(maskImg,2)]);

            % Definisce la regione 20x20 centrata sul centro calcolato
            half = patchSize / 2;  % per 20 pixel, half = 10
            rowStart = centerY - (half - 1);
            rowEnd   = centerY + half;
            colStart = centerX - (half - 1);
            colEnd   = centerX + half;

            % Verifica che il patch sia interamente contenuto nell'immagine ridimensionata
            [imgH_resized, imgW_resized, ~] = size(imgResized);
            if rowStart < 1 || rowEnd > imgH_resized || colStart < 1 || colEnd > imgW_resized
                warning('Il patch LEAF di %s eccede i limiti. Skip per questa immagine.', maskName);
            else
                patchLeaf = imgResized(rowStart:rowEnd, colStart:colEnd, :);
                patchCountLeaf = patchCountLeaf + 1;
                % Inizializza la griglia per il mosaico LEAF alla prima patch valida
                if ~mosaicLeafInitialized
                    if ndims(patchLeaf) == 3
                        mosaicLeaf = zeros(numRows*patchSize, numCols*patchSize, 3, class(patchLeaf));
                    else
                        mosaicLeaf = zeros(numRows*patchSize, numCols*patchSize, class(patchLeaf));
                    end
                    mosaicLeafInitialized = true;
                end
                % Calcola la posizione del patch nella griglia LEAF
                rowIdx = floor((patchCountLeaf - 1) / numCols) + 1;
                colIdx = mod((patchCountLeaf - 1), numCols) + 1;
                mosaicRowStart = (rowIdx - 1) * patchSize + 1;
                mosaicRowEnd   = rowIdx * patchSize;
                mosaicColStart = (colIdx - 1) * patchSize + 1;
                mosaicColEnd   = colIdx * patchSize;
                mosaicLeaf(mosaicRowStart:mosaicRowEnd, mosaicColStart:mosaicColEnd, :) = patchLeaf;
            end
            % Nota: la variabile imgOriginal viene utilizzata anche per la parte BG
        end
    end

    % -------------------- Parte BACKGROUND --------------------
    % Se è stata caricata l'immagine originale, estrai un patch dal bordo
    if exist('imgOriginal','var')
        [imgH_orig, imgW_orig, nChannels] = size(imgOriginal);
        if imgH_orig < patchSize || imgW_orig < patchSize
            warning('Immagine %s troppo piccola per patch BG. Skip.', imagePath);
        else
            % Scegli casualmente uno dei 4 bordi:
            % 1 = bordo superiore, 2 = bordo inferiore, 3 = bordo sinistro, 4 = bordo destro
            borderChoice = randi(4);

            switch borderChoice
                case 1  % Bordo superiore
                    rowStartBG = 1;
                    rowEndBG   = patchSizeBG;
                    colStartBG = randi(imgW_orig - patchSizeBG + 1);
                    colEndBG   = colStartBG + patchSizeBG - 1;
                case 2  % Bordo inferiore
                    rowEndBG   = imgH_orig;
                    rowStartBG = imgH_orig - patchSizeBG + 1;
                    colStartBG = randi(imgW_orig - patchSizeBG + 1);
                    colEndBG   = colStartBG + patchSizeBG - 1;
                case 3  % Bordo sinistro
                    colStartBG = 1;
                    colEndBG   = patchSizeBG;
                    rowStartBG = randi(imgH_orig - patchSizeBG + 1);
                    rowEndBG   = rowStartBG + patchSizeBG - 1;
                case 4  % Bordo destro
                    colEndBG   = imgW_orig;
                    colStartBG = imgW_orig - patchSizeBG + 1;
                    rowStartBG = randi(imgH_orig - patchSizeBG + 1);
                    rowEndBG   = rowStartBG + patchSizeBG - 1;
            end

            % Estrai il patch BG dall'immagine originale
            patchBG = imgOriginal(rowStartBG:rowEndBG, colStartBG:colEndBG, :);
            patchCountBG = patchCountBG + 1;
            % Inizializza la griglia per il mosaico BG alla prima patch valida
            if ~mosaicBGInitialized
                if nChannels == 3
                    mosaicBackground = zeros(numRows*patchSizeBG, numCols*patchSizeBG, 3, class(patchBG));
                else
                    mosaicBackground = zeros(numRows*patchSizeBG, numCols*patchSizeBG, class(patchBG));
                end
                mosaicBGInitialized = true;
            end
            % Calcola la posizione del patch nella griglia BG
            rowIdxBG = floor((patchCountBG - 1) / numCols) + 1;
            colIdxBG = mod((patchCountBG - 1), numCols) + 1;
            mosaicRowStartBG = (rowIdxBG - 1) * patchSizeBG + 1;
            mosaicRowEndBG   = rowIdxBG * patchSizeBG;
            mosaicColStartBG = (colIdxBG - 1) * patchSizeBG + 1;
            mosaicColEndBG   = colIdxBG * patchSizeBG;
            mosaicBackground(mosaicRowStartBG:mosaicRowEndBG, mosaicColStartBG:mosaicColEndBG, :) = patchBG;
        end
        % Elimina la variabile imgOriginal per evitare di riutilizzarla
        clear imgOriginal
    end
end

%% Salvataggio dei risultati
if mosaicLeafInitialized
    imwrite(mosaicLeaf, mosaicLeafName);
    fprintf('Mosaico LEAF salvato in "mosaicLeaf.png"\n');
else
    warning('Nessun patch LEAF valido estratto.');
end

if mosaicBGInitialized
    imwrite(mosaicBackground, mosaicBGName);
    fprintf('Mosaico BACKGROUND salvato in "mosaic_background.png"\n');
else
    warning('Nessun patch BACKGROUND valido estratto.');
end


info = imfinfo(imagePath);
imgOriginal = imread(imagePath);

% Correggi l'orientamento se necessario (sia per leaf che per background)
if isfield(info, 'Orientation')
    switch info.Orientation
        case 1
            % Nessuna operazione
        case 3
            imgOriginal = imrotate(imgOriginal, 180);
        case 6
            imgOriginal = imrotate(imgOriginal, -90);
        case 8
            imgOriginal = imrotate(imgOriginal, 90);
        otherwise
            warning('Orientamento non gestito: %d', info.Orientation);
    end
end