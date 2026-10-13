
function [audio, fs, output] = gen_audio_from_detections(USV_folder, background_folder, rate, opts)
    arguments
        USV_folder {mustBeTextScalar} % Path to folder containing detection files for USVs of interest
        background_folder {mustBeTextScalar} % Path to folder containing detection files for background audio (to fill in gaps)
        rate
        opts.rate_sr = 1e3
    end

    %% Create a table with 1 row per USV. This will have all the data to make the final audio plus metadata about the USV
    output = table();

    %% Calculate call times
    output.call_times = call_times_from_rate(rate, opts.rate_sr);

    %% Load USVs
    [usvs, fs]= load_random_usv(USV_folder, height(output));
    longest_usv = max(usvs.usv_duration);
    if max(rate) > 1/longest_usv
        error("requested too high of a rate. Limit to below %d Hz based on the maxiumum usv duration of %d s", 1/longest_usv, longest_usv)
    end
    output = cat(2, output, usvs); % Add these usvs and metadata to the table

    %% Load background (I'm not tracking the metadata for the background)
    [output.background, output.background_duration] = load_required_background(background_folder, output.call_times, output.usv_duration);

    %% Remove the audio from the output table and concatonate into a giant vector
    audio = output{:, ["usv_audio", "background"]};
    audio = reshape(audio', [],1); % Reshape so it goes [usv1, background1, usv2, background2 ....]
    audio = cat(1, audio{:}); % unpack cell array into vector
    output = removevars(output, ["usv_audio", "background"]);
end