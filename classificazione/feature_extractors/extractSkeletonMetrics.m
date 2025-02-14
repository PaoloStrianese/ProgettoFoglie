function features = extractSkeletonMetrics(segmentedImg)
    % Analizza la venatura tramite skeletonizzazione 2D/3D
    % Input: Immagine segmentata (2D o 3D)
    % Output: [numNodi, avgBranchLength, avgAngle]
    
    % 1. Skeletonizzazione robusta
    binImg = im2gray(segmentedImg) > 0;
    if ndims(binImg) == 2 % Converti in pseudo-3D per Skel2Graph3D
        skel3D = bwskel(binImg > 0, 'MinBranchLength', 10);
        skel3D = reshape(skel3D, [size(binImg) 1]); % Aggiungi dimensione Z
    else
        skel3D = bwskel(binImg);
    end

    % 2. Analisi dei rami con gestione errori
    try
        [~,node,link] = Skel2Graph3D(skel3D, 5); % Threshold=5 per rimuovere artefatti
    catch
        error('Installare Skel2Graph3D da: https://github.com/phi-max/skel2graph3d-matlab');
    end

    % 3. Conteggio nodi validi :cite[1]
    numNodi = sum(arrayfun(@(n) length(n.conn) > 2, node)); % Solo nodi di biforcazione

    % 4. Lunghezza rami da strutture link :cite[5]
    branchLengths = arrayfun(@(l) length(l.point), link);
    avgBranchLength = mean(branchLengths(branchLengths > 5)); % Filtra micro-rami

    % 5. Calcolo angoli basato sulle connessioni reali :cite[4]
    angles = [];
    for n = node
        if length(n.conn) >= 3 % Solo nodi di biforcazione
            coords = [node(n.conn).comx; node(n.conn).comy]';
            vecs = coords - repmat([n.comx, n.comy], size(coords,1), 1);
            ang = atan2(vecs(:,2), vecs(:,1));
            ang_diff = diff(sort(ang));
            angles = [angles; ang_diff(ang_diff > 0)];
        end
    end
    avgAngle = rad2deg(mean(angles(~isnan(angles))));

    features = [numNodi, avgBranchLength, avgAngle];
end