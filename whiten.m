function [audio_out,fs] = whiten(f, new_folder, filter)

audiofile = load(f).audiodata.Filename;
[audio_signal, fs] = audioread(audiofile);
%% take fft of whole audio
X = fftshift(fft(audio_signal)); % fftshift so that 0 frequency in middle

%% upsample filter to match fft and apply
big_filter = resample(filter,length(X),length(filter)); 
Y = X .* big_filter; % Apply filter in frequency domain

%% invert filtered fft back to time domain and normalize
audio_out = real(ifft(fftshift(Y)));

%% normalize 
% audio_out = zscore(audio_out) / 50; % normalize
audio_out =audio_out / 50;

clf; histogram(audio_out); yscale('log')
audio_out(abs(audio_out)>1) = 1;
%%
% d = load(f);
% 
% start_ind = round(d.Calls.Box(:,1)*fs);
% stop_ind = start_ind + round(d.Calls.Box(:,3)*fs);
% 
% all_ind = cell(size(start_ind));
% for i=1:height(start_ind)
%     all_ind{i} = start_ind(i):stop_ind(i);
% end
% all_ind = cat(2,all_ind{:});
% 
% % box_original = audio_signal(all_ind);
% box_filtered = audio_out(all_ind);
% rms(box_filtered)
%%

[~,fname,~] = fileparts(audiofile);
save_name = fullfile(new_folder,fname+".wav");
audiowrite(save_name, audio_out, fs);
end