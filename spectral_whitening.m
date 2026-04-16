function audio_out = spectral_whitening(audioIn, fs, window)
% Flatten audio spectrum using whitening filter
n = length(audioIn);
X = fft(audioIn);

power = abs(X).^2 / n;
winSize = window / (fs/n);
env = smoothdata(power, 'gaussian', winSize);
filt = 1 ./ (sqrt(env) + eps);% create filter

%manual filter editing
% filt = filt/ max(filt);
% f = fs/n*fftshift(-n/2:n/2-1);
% filt(abs(f)>35e3) = 1;
% filt = filt+.1;

Y = X .* filt; % Apply filter in frequency domain

% plot original power, smoothed env, and filter
% figure(1);clf;
% subplot(2,1,1); hold on; yscale('log');
% plot_power(power, fs/1000)
% plot_power(env, fs/1000)
% % plot_power(filt, fs/1000)
% subplot(2,1,2); hold on; yscale('log');
% plot_power(abs(Y).^2/n, fs/1000)

% Inverse FFT to get whitened audio
audio_out = real(ifft(Y));

% audio_out = audio_out / max(abs(audio_out)); %Normalize output
end

function plot_power(p, fs)
decimation = 10;
n = length(p);

y = p(1:decimation:n/2);

% y = y/sum(y); %normalize
max_f = fs/2;
f = linspace(0, max_f, length(y));
plot(f, y)
end