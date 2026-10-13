function [calls_t, audio, fs] = load_call_snippets(folder)
    arguments
        folder string = pwd() % Path to folder containing detection files
    end

    calls = load_calls(folder);
    audio = cell(height(calls),1);
    current_file = "";
    for i = 1:height(calls)   
        if current_file ~= calls.file(i)
            current_file = calls.file(i);
            [current_audio, fs] = audioread(calls.file(i), 'native');
        end
        start = calls.Box(i,1);
        stop = sum(calls.Box(i,[1,3]));
        audio{i} = current_audio(round(start*fs) : round(stop*fs));
    end
    %save call table with call identifying information 
    calls.usv_duration = calls.Box(:,3);
    calls_t = calls(:, {'Box', 'file', 'usv_duration'});
end