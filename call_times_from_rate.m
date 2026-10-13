function call_times = call_times_from_rate(rate, sr)
    rate_time = linspace(0, numel(rate)/sr, numel(rate));
    cum_num_usv = cumsum(rate * 1/sr);

    plot(cum_num_usv, rate_time)
    ylabel('Time (s)')
    xlabel('Cumulative call number')

    n_calls = round(cum_num_usv(end));
    call_times = interp1(cum_num_usv,rate_time, 1:n_calls, 'nearest', 'extrap');
    call_times = call_times(:); % ensure row vector
    call_times = [0 ; call_times]; % Call at t==0 starts the rate calculation
end