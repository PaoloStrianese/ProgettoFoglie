function labels = getLabelsFromFolder(folder)
files = dir(fullfile(folder, "*.png"));
labels = strings(numel(files), 1);
for idx = 1:numel(files)
    parts   = split(files(idx).name, "-");
    %nameExt = split(parts(2), ".");
    labels(idx) = string(parts(1));
end
end