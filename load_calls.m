function allCalls = load_calls(folder)
    arguments
        folder string = pwd() % Path to folder containing detection files
    end
    matfiles = {dir(fullfile(folder, "*.mat")).name}';
    if isempty(matfiles)
        error('No .mat files in: %s', folder);
    end
    allCalls = table();
    for i=1:length(matfiles)
        d = load(fullfile(folder,matfiles{i}));
        d.Calls.file(:) = repmat(string(d.audiodata.Filename), [height(d.Calls), 1]);
        allCalls = cat(1, allCalls,d.Calls);
    end
end