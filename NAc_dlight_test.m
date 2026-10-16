root = "/datastar/davidSwygart/USV_playback/2CAP_audio/";
low = root + "low";
high = root + "high";
background = root + "background/20241011";
gen_audio_folder = "/datastar/annaRemes/NAc_dlight/playback_audio/";
file_name = "happy_NAc_dlight_test";

%% Generate the rate shape of the audio
rand_scale = .2;
baseline_rate = 4;

[rate1, sr] = gen_decaying_rate( ...
    audio_duration = 3 * 60, ...
    baseline_rate = baseline_rate, ...
    time_constant = 1 * 60, ...
    decay_time_flipped =true, ...
    rand_scale = rand_scale ...
    );

rate2 = gen_decaying_rate( ...
    audio_duration = 5 * 60, ...
    baseline_rate = baseline_rate, ...
    time_constant = 0, ...
    decay_time_flipped = false, ...
    rand_scale = rand_scale ...
    );

rate3 = gen_decaying_rate( ...
    audio_duration = 33 * 60, ...
    baseline_rate = baseline_rate, ...
    time_constant = 15 * 60, ...
    decay_time_flipped = false, ...
    rand_scale = rand_scale ...
    );



rate = [rate1; rate2; rate3];
t = linspace(0, numel(rate)/sr, numel(rate));

figure(1)
plot(t,rate)
xlabel('Time (s)')
ylabel('USV rate (Hz)')


%% Generate audio using this rate shape
[audio, fs, metadata] = gen_audio_from_detections(high, background, rate);

%% Save sync signal
fprintf("Minnimum TTL duration should be at least 10 ms, probably better to be >50 ms \n")
fprintf("min duration of usv = %f ms \n", 1e3*min(metadata.usv_duration))
fprintf("min duration of whole usv+block = %f ms \n", 1e3*min(metadata.usv_duration+metadata.background_duration))

TTL_duration = 0.1;
call_inds = round(metadata.call_times*fs); % Indices of when USV starts

TTL_inds = 1:round(TTL_duration*fs); % Indices of fixed duration for TTL
TTL_inds = TTL_inds(:) + call_inds(:)'; % Add fixed duration TTL indices to all USV start indices
TTL_inds = TTL_inds(:); % Reshape to row vector
if any(TTL_inds>numel(audio))
    error("There should not be TTL indices longer than the audio")
end

audio = bitset(audio, 1, 0); % Set 1st bit to 0 for all the audio
audio(TTL_inds) = bitset(audio(TTL_inds), 1, 1); % Set the 1st bit to 1 for TTL indices
%% Save the audio file
fname = fullfile(gen_audio_folder,'happy_test.wav');
audiowrite(fname, audio, fs);



