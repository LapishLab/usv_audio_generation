function calls = load_call_snippets(folder)
    arguments
        folder string = pwd() % Path to folder containing detection files
    end
    
    calls = load_calls(folder);
    current_file = "";
    for i = 1:height(calls)
        if current_file ~= calls.audio_file(i)
            current_file = calls.audio_file(i);
            [current_audio, fs] = audioread(calls.audio_file(i));
        end
        start = calls.Box(i,1);
        stop = sum(calls.Box(i,[1,3]));
        calls.audio{i} = current_audio(round(start*fs) : round(stop*fs));
        calls.duration(i) = numel(calls.audio{i}) / fs;
    end
end



