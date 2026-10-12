root = "/datastar/davidSwygart/USV_playback/2CAP_audio/";
low = root + "low";
high = root + "high";
background = root + "background/20241011";
gen_audio_folder = "/datastar/annaRemes/NAc_dlight/playback_audio/";
file_name = "happy_NAc_dlight_test";




gen_audio_from_detections(high, background, audio_file_save = gen_audio_folder, ...
    make_plots=true, decreasing_shape=true,audio_file_name='happy_test_end')

%% combine audio files 
% 3 minute start, 38 minute end 
start_audio_name = "happy_test_start";
end_audio_name = "happy_test_end";

%load audio if needed
[audio_start, fs1] = audioread(fullfile(gen_audio_folder, start_audio_name + '.wav'));
[audio_end, fs2] = audioread(fullfile(gen_audio_folder, end_audio_name + '.wav'));

% Sample rates must match
if fs1 ~= fs2
    audio_end = resample(audio_end, fs1, fs2);
end

%load info files if needed 
start_audio_info = load(fullfile(gen_audio_folder, start_audio_name + "_squeak_info.mat")).metadata;
end_audio_info = load(fullfile(gen_audio_folder, end_audio_name + "_squeak_info.mat")).metadata;

% % Offset = exact length of the starting audio file, in seconds
% offset = size(audio_start, 1) / fs1;
% 
% % Shift the end audio file usv specific times 
% end_audio_info.usv_duration = end_audio_info.usv_duration + offset;
% end_audio_info.background_duration = end_audio_info.background_duration + offset;

metadata = [start_audio_info;end_audio_info];
metadata_pat = fullfile(gen_audio_folder, "happy_NAc_dlight_test_squeak_info.mat");
save(metadata_pat, 'metadata');


combined = [audio_start; audio_end];    % stack vertically = end to end
audiowrite('happy_NAc_dlight_test.wav', combined, fs1);



