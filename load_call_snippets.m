function audio = load_call_snippets(folder)
    arguments
        folder string = pwd() % Path to folder containing detection files
    end
    
    calls = load_calls(folder);
    audio = cell(height(calls),1);
    current_file = "";
    for i = 1:height(calls)
        if current_file ~= calls.file(i)
            current_file = calls.file(i);
            [current_audio, fs] = audioread(calls.file(i));
        end
        start = calls.Box(i,1);
        stop = sum(calls.Box(i,[1,3]));
        audio{i} = current_audio(round(start*fs) : round(stop*fs));
    end
end



