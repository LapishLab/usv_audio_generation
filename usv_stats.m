function stats = usv_stats(folder)
    arguments
        folder string = pwd() % Path to folder containing detection files
    end
    calls = load_calls(folder);

    stats = struct();

    dur = calls.Box(:,3) * 1000; % duration in ms
    bandwidth = calls.Box(:,4); % bandwidth in kHz
    min_freq = calls.Box(:,2);
    peak_freq = min_freq + bandwidth;
    middle_freq = min_freq + bandwidth ./ 2;
    

    stats.totalCalls = height(calls.Box);
    stats.avg_duration = mean(dur);
    stats.total_duration = sum(dur);
    stats.bandwidth = mean(bandwidth);
    stats.avgPeakFreq = mean(peak_freq);

    figure(1); clf
    histogram(dur)
    xlabel('USV duration (ms)')

    figure(2); clf
    histogram(bandwidth)
    xlabel('Bandwith (kHz)')

    figure(3); clf
    histogram(peak_freq)
    xlabel('Peak Frequency (kHz)')

    figure(4); clf
    histogram(middle_freq)
    xlabel('Middle Frequency (kHz)')
end






