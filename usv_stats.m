function stats = usv_stats(folder)
    arguments
        folder string = pwd() % Path to folder containing detection files
    end
    calls = load_calls(folder);

    stats = struct();

    dur = calls.Box(:,3) * 1000; % duration in ms
    bandwidth = calls.Box(:,4); % bandwidth in kHz
    min_freq = calls.Box(:,2);
    middle_freq = min_freq + bandwidth ./ 2;
    

    stats.totalCalls = height(calls.Box);
    stats.avg_duration = mean(dur);
    stats.total_duration = sum(dur);
    stats.bandwidth = mean(bandwidth);
    stats.middle_freq = mean(middle_freq);
    stats.freq_min = min(middle_freq);
    stats.freq_max = max(middle_freq);

    figure(1); clf
    histogram(dur)
    xlabel('USV duration (ms)')

    figure(2); clf
    histogram(bandwidth)
    xlabel('Bandwith (kHz)')

    figure(4); clf
    histogram(middle_freq)
    xlabel('Middle Frequency (kHz)')
end


function calls = load_calls(folder)
files = string({dir(fullfile(folder, "*.mat")).name})';
files = fullfile(folder, files);
calls = table();
for i=1:height(files)
    d = load(files(i));
    % c = d.Calls;
    % c.file = d.audiodata.Filename;
    if isempty(d.Calls)
        fprintf("empyt %s:\n", files(i))
    end
    calls = cat(1,calls, d.Calls);
end

end