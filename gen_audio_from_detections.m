
function gen_audio_from_detections(USV_folder, background_folder, opts)
    arguments
        USV_folder {mustBeTextScalar} % Path to folder containing detection files for USVs of interest
        background_folder {mustBeTextScalar} % Path to folder containing detection files for background audio (to fill in gaps)
        opts.audio_duration double = 35*60; % Duration of audio in seconds
        opts.target_usv_proportion double = 0.2; % Proportion of full audio that should be USVs
        opts.rate_power_scaling double = 0.4; % Power scaling applied to linear increase gaps between USVs
        opts.target_max_usv_proportion double = 0.9; % MUST BE HIGHER THAN target_usv_proportion; Maximum proportion that individual USV should make up of usv+background pairing
        opts.audio_file_name {mustBeTextScalar} = 'combined_audio.wav' % Output file name (placed in USV_folder)
        opts.rand_scale double = 0.5; % How much random scaling to apply to gaps between USVs
        opts.audio_file_save {mustBeTextScalar} = USV_folder %where the audio file is saved
        opts.make_plots logical = false; % Should I make rate plots?
        opts.decreasing_shape logical = true; %if true, USV rate starts high and decreases
    end

    rng(0);

    [usv_t, usv] = load_call_snippets(USV_folder);
    [~, background] = load_call_snippets(background_folder);

    metadata = table();

    % calculator background durations
    fs = audioinfo(load_calls(USV_folder).file(1)).SampleRate;
    avg_usv_dur = mean(cellfun(@length, usv)) / fs;
    avg_background_dur = avg_usv_dur/opts.target_usv_proportion - avg_usv_dur;
    n_calls = ceil(opts.audio_duration/(avg_usv_dur+avg_background_dur));
    x = linspace(0,1,n_calls).^opts.rate_power_scaling;

    if ~opts.decreasing_shape
        x = fliplr(x); % large gaps first (slow rate), small gaps last (fast rate)
    end

    background_dur = x * avg_background_dur / mean(x);

    % Add a small baseline gap and normalize the mean duration.
    background_dur = background_dur + (1-opts.target_max_usv_proportion);
    
    rand_scale = 1+randn(size(background_dur))*opts.rand_scale;
    rand_scale(rand_scale<0) = 0;
    background_dur = rand_scale .* background_dur;
    background_dur = background_dur / mean(background_dur) * avg_background_dur;


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
    usv_idx  = zeros(length(usv), n_repeats);
    for i=1:n_repeats
        usv_loc = randperm(length(usv));
        full_usv(usv_loc, i) = usv;
        usv_idx(usv_loc, i)  = 1:length(usv);   % contains indexes for the calls 
    end
    full_usv = full_usv(1:n_calls); % reshape into 1D and shrink to expected size
    usv_idx = usv_idx(1:n_calls); %reshape call info table into 1D and shrink to expected size
    all = cat(1, full_usv, full_back);
    all = cat(1, all{:});

    %calculate length of each section 
    background_length = cellfun(@length, full_back(:)) / fs;
    usv_length = cellfun(@length, full_usv(:)) / fs;

    audio_path = fullfile(opts.audio_file_save, opts.audio_file_name + ".wav");
    audiowrite(audio_path, all, fs);
    fprintf('Audio saved: %s\n', audio_path)

    metadata = usv_t(usv_idx(:), :); %concat USV data information on top of each other. table is organized by how the calls are present in the file 
    metadata.background_duration = background_length; %save length of background after each squeak 
    metadata.usv_duration = usv_length; %save length of background after each squeak 

    metadata_pat = fullfile(opts.audio_file_save, opts.audio_file_name + "_squeak_info.mat");
    save(metadata_pat,'metadata');

    if  opts.make_plots
        %% Plotting USV ON proportion and rate
        len_On = cellfun(@length, full_usv);
        len_Off = cellfun(@length, full_back);
        len_both = len_On + len_Off;
    
        prop_on = len_On ./ len_both;
        t = cumsum(len_both)/fs;
        t = [0, t(1:end-1)];
    
        % proportion of time ON
        figure(1); clf; hold on;
        scatter(t,prop_on,'.', DisplayName="USV+noise audio segment");
        xlabel('Time (s)')
        ylabel({'Proportion of audio segment duration', 'containing an active USV emission'})
    
        bins = 0:5:max(t)+5; %rebin at 1s
        g = discretize(t, bins);
        avg_prop = accumarray(g', prop_on', [], @mean, 0);
        avg_t = bins(1:length(avg_prop));
        plot(avg_t,avg_prop,DisplayName="Average (5s)", LineWidth=2)
        legend()
    
        % USV rate
        figure(2); clf; hold on;
        scatter(t(2:end),1./diff(t'),'.', DisplayName="Instantaneous rate per USV");
        xlabel('Time (s)')
        ylabel('USV rate (Hz)')
    
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
        % yscale('log')
        yscale('linear')
        ylim([0 ,max(y)*1.2])
    end
end

function [calls_t, audio] = load_call_snippets(folder)
    arguments
        folder string = pwd() % Path to folder containing detection files
    end

    calls_t = {};

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
    %save call table with call identifying information 
    calls.usv_duration = calls.Box(:,3);
    calls_t = calls(:, {'Box', 'file', 'usv_duration'});
end

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