function [output, fs] = load_random_usv(USV_folder, n_calls)
    [usv_t, usv, fs] = load_call_snippets(USV_folder);
    num_loaded =  length(usv);

    %% Choose random USVs (choose without replacement until we run out then start over)
    n_repeats = ceil(n_calls / num_loaded);
    usv_idx  = cell(n_repeats, 1);
    for i=1:n_repeats
        usv_idx{i} = randperm(num_loaded);
    end
    usv_idx = cat(2, usv_idx{:}); % Unpack
    usv_idx = usv_idx(1:n_calls); % limit to number of calls 
    usv_idx = usv_idx(:); % ensure row vector

    %% Put chosen USVs in a table
    output = usv_t(usv_idx, :); % metadata
    output.usv_audio = usv(usv_idx); % actual audio
end