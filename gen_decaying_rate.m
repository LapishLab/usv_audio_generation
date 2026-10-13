function [rate, sr] = gen_decaying_rate(opts)
arguments
        opts.audio_duration double = 35*60; % Duration of audio in seconds
        opts.baseline_rate double = 5; % Initial rate in Hz
        opts.time_constant double = 10*60; % Time constant of decay in seconds
        opts.decay_time_flipped logical = false; % Should the decay be flipped in time
        opts.rand_scale double = .1; % How much random scaling
        opts.sampling_rate = 1e3; % Sampling rate in Hz (higher equals smoother transitions, but more computation)
end
    sr = opts.sampling_rate;
    t_ms = 0:1:opts.audio_duration*sr;
    if opts.time_constant == 0
        decay_rate_ms = 0;
    else
        decay_rate_ms = -1/opts.time_constant/sr;
    end

    rate = opts.baseline_rate * exp(t_ms * decay_rate_ms);
    if opts.decay_time_flipped 
        rate = fliplr(rate);
    end
    
    % Apply reproducible multiplicative random variation to the rate.
    rng(0);
    mult = 1000;
    range = [1-opts.rand_scale, 1+opts.rand_scale] * mult;
    rand_scale = randi(range, [numel(t_ms), 1]) / mult;

    rate = rate(:) .* rand_scale(:);
end
