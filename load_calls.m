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
        d.Calls.audio_file(:) = d.audiodata.Filename;
        d.Calls.detection_file(:) = string(matfiles{i});
        allCalls = cat(1, allCalls,d.Calls);
    end
end