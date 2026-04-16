function plot_spectrum_data(y, Fs)
    window = round(Fs * 0.0032);% Deepsqueak default = .0032 s
    nfft = round(Fs * 0.0032);% Deepsqueak default = .0032 s
    % spectrogram(y,window,[],[], Fs, "yaxis")
    [~,F,T,P] = spectrogram(y,window,[],nfft, Fs); % defaults to 50% overlap with []

    P = sqrt(P); % plot amplitude
    % P = 10*log10(P+eps); %convert to decibel: Add eps to avoid log(0)
  
    imagesc(T, F/1000, P); 
    axis xy;
    ylabel('Frequency (kHz)');
    xlabel('Time (s)');
    c = colorbar;
    c.Label.String = 'Amplitude';

    colormap("inferno")

    % setting color limits
    avg = mean(P,2);
    dev = std(P,[],2);
    low = min(avg)/2;
    shift_high = avg+(3*dev);
    high = max(shift_high(F>4e4));

    clim([low,high])
end