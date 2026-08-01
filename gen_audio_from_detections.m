function gen_audio_from_detections(USV_folder, background_folder, opts)
    arguments
        USV_folder {mustBeTextScalar} % Path to folder containing detection files for USVs of interest
        background_folder {mustBeTextScalar} % Path to folder containing detection files for background audio (to fill in gaps)
        opts.audio_duration double = 22; % Duration of audio in minutes
        opts.target_usv_proportion double = .2; % Proportion of full audio that should be USVs
        opts.audio_file_name {mustBeTextScalar} = 'combined_audio.wav' % Output file name (placed in USV_folder)
        opts.full_chunk_length double = 60; % Chunk size in seconds
        opts.USV_chunk_length double = [10 20]; % Range of the USV portion of the chunk in seconds
    end
    
    %session time in seconds 
    total_session_time = opts.audio_duration*60;

    %how many audio session loops are needed
    session_creation_loops = ceil(total_session_time/opts.full_chunk_length);

    %initialize full session audio variable 
    full_session_audio = cell(session_creation_loops,1);

    for i = 1:session_creation_loops
        %how long the USV part in an audio chunk will be. Chooses a number
        %within a random interval 
        usv_length = randi([opts.USV_chunk_length(1) , opts.USV_chunk_length(2)]);
        %determine background length 
        back_length = opts.full_chunk_length - usv_length;

        %generate audio chunks
        [chunk, fs] = gen_chunk(USV_folder, background_folder, ...
            audio_duration=usv_length ...
            ,rate_power_scaling=0, ...
            target_usv_proportion=opts.target_usv_proportion);
        
        background_chunk = gen_chunk(background_folder, background_folder, ...
            audio_duration=back_length, ...
            rate_power_scaling=0);

        %concatenate stuff together 
        full_session_audio{i} = cat(1, chunk(:), background_chunk(:));

    end
    all = cat(1, full_session_audio{:});
    audio_path = fullfile(USV_folder, opts.audio_file_name);
    audiowrite(audio_path, all, fs);
    fprintf('Audio saved: %s\n', audio_path)

    % if  opts.make_plots
    %     %% Plotting USV ON proportion and rate
    %     len_On = cellfun(@length, full_usv);
    %     len_Off = cellfun(@length, full_back);
    %     len_both = len_On + len_Off;
    % 
    %     prop_on = len_On ./ len_both;
    %     t = cumsum(len_both)/fs;
    %     t = [0, t(1:end-1)];
    % 
    %     % proportion of time ON
    %     figure(1); clf; hold on;
    %     scatter(t,prop_on,'.', DisplayName="USV+noise audio segment");
    %     xlabel('Time (s)')
    %     ylabel({'Proportion of audio segment duration', 'containing an active USV emission'})
    % 
    %     bins = 0:5:max(t)+5; %rebin at 1s
    %     g = discretize(t, bins);
    %     avg_prop = accumarray(g', prop_on', [], @mean, 0);
    %     avg_t = bins(1:length(avg_prop));
    %     plot(avg_t,avg_prop,DisplayName="Average (5s)", LineWidth=2)
    %     legend()
    % 
    %     % USV rate
    %     figure(2); clf; hold on;
    %     scatter(t(2:end),1./diff(t'),'.', DisplayName="Instantaneous rate per USV");
    %     xlabel('Time (s)')
    %     ylabel('USV rate (Hz)')
    % 
    %     window = 5;
    %     step = .1;
    %     avg_t = 0:step:max(t);
    %     y = zeros(size(avg_t));
    %     for i=1:length(avg_t)
    %         y(i) = sum(t>avg_t(i) & t<(avg_t(i)+window))/window;
    %     end
    %     y = movmean(y,window/step);
    %     x=avg_t;
    % 
    %     plot(x,y,DisplayName="Average rate (5s)",LineWidth=2)
    %     legend()
    %     % yscale('log')
    %     yscale('linear')
    %     ylim([0 ,max(y)*1.2])
    % end
end

