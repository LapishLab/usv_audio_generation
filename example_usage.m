%% Enter correct paths
background_dir = "Path to folder containing background detection files";
usv_dir = "Path to folder containing usv detection files";

%% Generate audio file with USVs
gen_audio_from_detections(usv_dir, background_dir, ...
    audio_duration=10*60, ...
    make_plots = true)
% View gen_audio_from_detections for full list of optional arguments

%% Generate audio file to use as background control
gen_audio_from_detections(background_dir, background_dir, ...
    audio_duration=10*60, ...
    make_plots = true)


