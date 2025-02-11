function paths = getImagePathsFromFolder(folder)
files = dir(fullfile(folder, "*.png"));
names = {files.name};
paths = fullfile(folder, names);
end
