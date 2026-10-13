function [background_audio, required_dur] = load_required_background(background_folder, call_times, usv_durations)
    %% Determine how much background we need
    block_duration = diff(call_times);
    block_duration = block_duration(:); %ensure rows
    block_duration = [block_duration; block_duration(end)]; % We don't really need to add background after the last call, but we will just for symmetry. 
    required_dur = block_duration(:) - usv_durations(:);

    if any(required_dur < 0)
        error("You requested too high of a rate")
    end

    %% Fill in the required background for each block
    [back_t, background, fs] = load_call_snippets(background_folder);
    n_back = height(back_t);
    total_back_dur = sum(back_t.usv_duration);

    background_audio = cell(numel(call_times), 1);

    for i=1:numel(call_times)
        n_repeats = ceil(required_dur(i) / total_back_dur);
        idx = cell(n_repeats);
        for r=1:n_repeats
          idx{r} = randperm(n_back);
        end
        idx = cat(2, idx{:}); % unpack
        
        total_dur = cumsum(back_t.usv_duration(idx));
        last_detection = find(total_dur>required_dur(i), 1);
        idx = idx(1:last_detection);

        back_selection = background(idx); % index audio into cell array
        back_selection = cat(1, back_selection{:}); % unpack audio
        last = round(required_dur(i)*fs);
        background_audio{i} = back_selection(1:last); % limit to required duration
    end
end