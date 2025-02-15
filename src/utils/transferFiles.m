function transferFiles(inputFolder, outputFolder)
% copyFiles copies files from subfolders of the input folder to the output folder,
% renaming each file by prefixing it with its subfolder name.
%
% Example usage:
%    copyFiles('segmented_image', 'output_folder')
%
% Parameters:
%   inputFolder  - the folder containing subfolders with files to copy.
%   outputFolder - the folder where the renamed copies will be stored.
%
% If the output folder does not exist, it is created automatically.

% Check that both input and output folder parameters are provided.
if nargin < 2
    error('You must provide both the input folder and the output folder.');
end

% Create the output folder if it doesn't exist.
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% List all items in the input folder.
folderContents = dir(inputFolder);

% Loop over each item in the input folder.
for i = 1:length(folderContents)
    % Process only directories, skipping '.' and '..'.
    if folderContents(i).isdir && ~strcmp(folderContents(i).name, '.') && ~strcmp(folderContents(i).name, '..')
        subfolderName = folderContents(i).name;
        subfolderPath = fullfile(inputFolder, subfolderName);

        % List all items in the subfolder.
        files = dir(subfolderPath);
        for j = 1:length(files)
            % Process only files (skip directories).
            if ~files(j).isdir
                fileName = files(j).name;
                oldFilePath = fullfile(subfolderPath, fileName);

                % Separate the file name and extension.
                [~, baseName, extension] = fileparts(fileName);

                % Create the new file name by prefixing with the subfolder name.
                newName = [subfolderName '-' baseName extension];
                newFilePath = fullfile(outputFolder, newName);

                % Copy the file to the output folder with the new name.
                copyfile(oldFilePath, newFilePath);
            end
        end
    end
end
end
