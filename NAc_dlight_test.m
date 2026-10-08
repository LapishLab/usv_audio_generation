root = "/datastar/davidSwygart/USV_playback/2CAP_audio/";
low = root + "low";
high = root + "high";
background = root + "background/20241011";
gen_audio_folder = "/datastar/annaRemes/NAc_dlight/playback_audio/";
file_name = "happy_NAc_dlight_test";




gen_audio_from_detections(high, background, audio_file_save = gen_audio_folder, ...
    make_plots=true, decreasing_shape=false,audio_file_name='random.wav')
