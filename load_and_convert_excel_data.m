function [rgb_leaf, rgb_bg] = load_and_convert_excel_data()
    % Funzione per leggere e convertire i dati dai file Excel in array
    % Output:
    %   rgb_leaf - dati RGB relativi alle foglie
    %   rgb_bg - dati RGB relativi allo sfondo

    % Path fissi per i file Excel
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
end
