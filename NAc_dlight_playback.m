root = "/datastar/davidSwygart/USV_playback/2CAP_audio/";
low = root + "low";
high = root + "high";
background = root + "background/20241011";
gen_audio_folder = "/datastar/annaRemes/NAc_dlight/playback_audio/";
file_name = "happy_NAc_dlight_test";


gen_audio_from_detections(high, background, ...
    audio_duration=60, target_usv_proportion=0.15, ...
    gen_audio_folder=gen_audio_folder, ...
    audio_file_name=file_name, full_chunk_length=60*60, ...
    USV_chunk_length=60*60);

