function [filter, frequency] = gen_filter(detection_file)
    arguments
        detection_file string % Path to detection file
    end
    d = load(detection_file);
    [full_audio, fs] = audioread(d.audiodata.Filename);
    start_ind = round(d.Calls.Box(:,1)*fs);
    stop_ind = start_ind + round(d.Calls.Box(:,3)*fs);

    all_ind = cell(size(start_ind));
    for i=1:height(start_ind)
        all_ind{i} = start_ind(i):stop_ind(i);
    end
    all_ind = cat(2,all_ind{:});

    box_audio = full_audio(all_ind);

    
    % get power from fft
    n = length(box_audio);
    X = fftshift(fft(box_audio)); % fftshift so that 0 frequency in middle
    f = fs/n*(-n/2:n/2); % frequency in units of Hz
    f = f(1:end-1)+1/fs/2;
    power = abs(X).^2 / n;

    % downsample by averaging
    resample_rate = 100; %rate in Hz
    t_bins = -fs/2 : resample_rate : fs/2; % new frequency in units of Hz
    binIndices = discretize(f, t_bins)';
    new_power = accumarray(binIndices, power, [], @mean);
    frequency=t_bins(1:end-1) + resample_rate/2;
    frequency=frequency(:);%reshape into rows

    % plot original and downsampled power
    figure(1); clf; hold on;
    plot(f,power)
    plot(frequency,new_power)
    yscale('log')

    % create filter from power
    filter = 1 ./ (sqrt(new_power));
    plot(frequency,filter)
end