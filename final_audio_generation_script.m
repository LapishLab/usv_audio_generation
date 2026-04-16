root = "/home/lapishla/Desktop/usv_playback/curated_squeaks_truitt/";
%% make filters and generate new audio files using the background detection files
back_folder = root+"/background_original";
filtered_audio_folder = root+"/filtered_audio";
back_files = {dir(back_folder+"/*.mat").name};
%
for i=1:length(back_files)
    f=fullfile(back_folder,back_files{i});
    filter= gen_filter(f);
    whiten(f, filtered_audio_folder, filter);
end

%% reset audioData.file for detection files
% filtered_wav = {dir(root+"/filtered_audio/*.wav").name};
filtered_audio_folder = root+"/filtered_audio";
% filtered_audio_folder= "/datastar/audio_rec/Truitt_audio/data";
det_folder = root+"/high";
% det_folder = root+"/low";
% det_folder = root+"/background";

mats = {dir(det_folder+"/*.mat").name};
%
for i=1:length(mats)
    f=fullfile(det_folder, mats{i});
    d = load(f);
    [~,old_name,~] = fileparts(d.audiodata.Filename);
    d.audiodata.Filename = fullfile(filtered_audio_folder,old_name+".wav");
    if(~exist(d.audiodata.Filename,'file'))
        error("%s doesn't exist", d.audiodata.Filename)
    end
    save(f, '-struct', 'd');
end
%% generating merged audio from detections
gen_audio_from_detections(root+"/high", root+"/background")
%%
gen_audio_from_detections(root+"/low", root+"/background")
%%
gen_audio_from_detections(root+"/background", root+"/background")




