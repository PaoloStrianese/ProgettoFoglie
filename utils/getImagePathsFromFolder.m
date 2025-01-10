function paths = getImagePathsFromFolder(folder)
    files = dir(fullfile(folder, "*.jpg"));
    names = {files.name};
    paths = fullfile(folder, names);
    end
    