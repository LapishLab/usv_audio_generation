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

    usv = load_call_snippets(USV_folder);
    background = load_call_snippets(background_folder);
    
    %session time in seconds 
    total_session_time = opts.audio_duration*60;

    %how many audio session loops are needed
    session_creation_loops = ceil(total_session_time/opts.full_chunk_length);

    %initialize full session audio variable 
    full_session = cell(session_creation_loops,1);

    for i = 1:session_creation_loops
        %how long the USV part in an audio chunk will be. Chooses a number
        %within a random interval 
        usv_length = randi([opts.USV_chunk_length(1) , opts.USV_chunk_length(2)]);
        %determine background length 
        back_length = opts.full_chunk_length - usv_length;

        %generate audio chunks (table of USVs and their randomly assigned
        %background audio)
        [chunk, fs] = gen_chunk(usv, background, ...
            audio_duration=usv_length ...
            ,rate_power_scaling=0, ...
            target_usv_proportion=opts.target_usv_proportion);
        
        background_chunk = gen_chunk(background, background, ...
            audio_duration=back_length, ...
            rate_power_scaling=0);

        %concatenate stuff together 
        full_session{i} = cat(1, chunk, background_chunk);
    end
    full_session = cat(1, full_session{:});

    %% Pull out the usv and background audio from the table and concatonate into 1 big audio signal
    audio_chunks = full_session{:, {'audio','background_audio'}};
    audio_chunks = reshape(audio_chunks',[], 1); %interleave background chunks after usv chunks
    full_audio = cat(1, audio_chunks{:}); 

    %% Save the audio file and the full_session file used to make the audio
    audio_path = fullfile(USV_folder, opts.audio_file_name);
    audiowrite(audio_path, full_audio, fs);
    %TODO: we might want to strip out the audio data before saving this table so it isn't so big 

    % save(audio_path+".mat", "full_session")  %TODO: Choose a different location to save this file. Saving in the same folder as detection .mat files could be problematic
    fprintf('Audio saved: %s\n', audio_path)

end

