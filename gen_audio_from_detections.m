function gen_audio_from_detections(USV_folder, background_folder)
    arguments
        USV_folder string % Path to folder containing detection files
        background_folder string % Path to folder containing detection files
    end

    rng(0);

    usv = load_call_snippets(USV_folder);
    background = load_call_snippets(background_folder);

    % calculator background durations
    fs = audioinfo(load_calls(USV_folder).file(1)).SampleRate;
    avg_usv_dur = mean(cellfun(@length, usv)) / fs;
    avg_background_dur = avg_usv_dur*4;
    n_calls = ceil(35*60/(avg_usv_dur+avg_background_dur));
    x = linspace(0,1,n_calls).^.4;
    background_dur = x * avg_background_dur / mean(x);
    rand_scale = abs(1+randn(size(background_dur))/2);
    background_dur = rand_scale .* background_dur;

    % collect random backgrounds
    rand_back = cat(1, background{randperm(length(background))});
    start_ind = randi(length(rand_back), 1, n_calls);
    stop_ind = start_ind+round(background_dur*fs);

    full_back = cell(1,n_calls);
    for i=1:n_calls
        inds = 1+mod(start_ind(i):stop_ind(i), length(rand_back));
        full_back{i} =  rand_back(inds);
    end

    % get USVs
    n_repeats = ceil(n_calls / length(usv));
    full_usv = cell(length(usv), n_repeats);
    for i=1:n_repeats
        full_usv(randperm(length(usv)), i) = usv;
    end
    full_usv = full_usv(1:n_calls); % reshape into 1D and shrink to expected size
    all = cat(1, full_usv, full_back);
    all = cat(1, all{:});


    

    audiowrite(fullfile(USV_folder, 'combined_audio.wav'), all, fs);

    %% Plotting USV ON proportion and rate
    len_On = cellfun(@length, full_usv);
    len_Off = cellfun(@length, full_back);
    len_both = len_On + len_Off;

    prop_on = len_On ./ len_both;
    t = cumsum(len_both)/fs;
    t = [0, t(1:end-1)];

    % proportion of time ON
    figure(1); clf; hold on;
    % scatter(t,prop_on,'filled', MarkerFaceAlpha=.1, DisplayName="Per USV");
    scatter(t,prop_on,'.', DisplayName="USV+noise audio segment");
    xlabel('Time (s)')
    ylabel({'Proportion of audio segment duration', 'containing an active USV emission'})

    bins = 0:5:max(t)+5; %rebin at 1s
    g = discretize(t, bins);
    avg_prop = accumarray(g', prop_on', [], @mean, 0);
    avg_t = bins(1:length(avg_prop));
    plot(avg_t,avg_prop,DisplayName="Average (5s)", LineWidth=2)
    legend()
    xlim([0 32*60])

    % USV rate
    figure(2); clf; hold on;
    % scatter(t(1:end-1),1./diff(t'),'filled', MarkerFaceAlpha=.1, DisplayName="Instantaneous rate per USV");
    scatter(t(2:end),1./diff(t'),'.', DisplayName="Instantaneous rate per USV");
    xlabel('Time (s)')
    ylabel('USV rate (Hz)')
    % y = histcounts(t, bins)/diff(bins(1:2));
    % x = bins(2:end);

    window = 5;
    step = .1;
    avg_t = 0:step:max(t);
    y = zeros(size(avg_t));
    for i=1:length(avg_t)
        y(i) = sum(t>avg_t(i) & t<(avg_t(i)+window))/window;
    end
    y = movmean(y,window/step);
    x=avg_t;
    
    plot(x,y,DisplayName="Average rate (5s)",LineWidth=2)
    legend()
    xlim([0 32*60])
    % yscale('log')
    yscale('linear')
    ylim([0 ,max(y)*1.2])
end

function audio = load_call_snippets(folder)
    arguments
        folder string = pwd() % Path to folder containing detection files
    end

    calls = load_calls(folder);
    audio = cell(height(calls),1);
    current_file = "";
    for i = 1:height(calls)   
        if current_file ~= calls.file(i)
            current_file = calls.file(i);
            % [y, fs] = audioread(calls.file(i));
            % current_audio = spectral_whitening(y, fs, 1);
            % current_audio = zscore(current_audio) / 50; % normalization
       
            % histogram(current_audio)
            % yscale('log')
            % pause(.01)

            [current_audio, fs] = audioread(calls.file(i));
        end
        start = calls.Box(i,1);
        stop = sum(calls.Box(i,[1,3]));
        audio{i} = current_audio(round(start*fs) : round(stop*fs));
    end
end
