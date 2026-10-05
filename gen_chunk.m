function [chosen_usv, fs] = gen_chunk(usv, background, opts)
arguments
    usv  % USV table (audio, detection file, audioinfo ,call number, duration) 
    background % background table (audio, detection file, audioinfo, call number, duration) 
    opts.audio_duration double = 22; % Duration of audio in seconds
    opts.target_usv_proportion double = 0.8; % Proportion of full audio that should be USVs
    opts.rate_power_scaling double = 0.4; % Power scaling applied to linear increase gaps between USVs
    opts.rand_scale double = 0.6; % How much random scaling to apply to gaps between USVs
    opts.make_plots logical = false; % Should I make rate plots?
end
fs = audioinfo(usv.audio_file(1)).SampleRate;

%% Choose enough random USVs to reach our target duration
target_usv_dur = opts.audio_duration * opts.target_usv_proportion;

n_repeats = ceil(target_usv_dur / sum(usv.duration)); % How many time will we need to repeat the same calls to achieve this duration
usv_inds = cell(n_repeats,1);
for i=1:n_repeats
    usv_inds{i} = randperm(height(usv))';
end
usv_inds = cat(1, usv_inds{:}); %Unpack the cell array into a list
cumulative_duration = cumsum(usv.duration(usv_inds)); % Calculate the cumulative duration using all of these USVs
last_needed = find(cumulative_duration > target_usv_dur, 1); % Find the cuttoff point where we have enough USVs to hit the target
usv_inds = usv_inds(1:last_needed); %Restrict to those USVs needed to reach the target duration
chosen_usv = usv(usv_inds,:); %Repack into a table of chosen USVs

%% Generate a random background audio of the required duration
background_duration = opts.audio_duration - sum(chosen_usv.duration);
n_repeats = ceil(background_duration/sum(background.duration));

rand_back = cell(n_repeats,1);
for i=1:n_repeats
    rand_inds = randperm(height(background));
    rand_back{i} = cat(1, background.audio{rand_inds}); % Concatonate these random background chunks
end
rand_back = cat(1, rand_back{:}); % unpack and concatate all the repeats
rand_back = rand_back(1:ceil(background_duration*fs)); % restrict the full background to the required duration

%% Cut up the background audio with 1 piece for each USV
% TODO: This is completely random cutting. We might want to allow for
% linear (more even) or bursty (less even) cutting.
cut_inds = randperm(length(rand_back), height(chosen_usv)-1);
cut_inds = [0, cut_inds, height(rand_back)]; % add the first and last indices as cut inds
cut_inds = sort(cut_inds);

for i=1:length(cut_inds)-1
    chosen_usv.background_audio{i} = rand_back(cut_inds(i)+1:cut_inds(i+1));
end

% if  opts.make_plots %% TODO: Fix completely broken plotting
%     %% Plotting USV ON proportion and rate
%     len_On = cellfun(@length, full_usv);
%     len_Off = cellfun(@length, full_back);
%     len_both = len_On + len_Off;
% 
%     prop_on = len_On ./ len_both;
%     t = cumsum(len_both)/fs;
%     t = [0, t(1:end-1)];
% 
%     % proportion of time ON
%     figure(1); clf; hold on;
%     scatter(t,prop_on,'.', DisplayName="USV+noise audio segment");
%     xlabel('Time (s)')
%     ylabel({'Proportion of audio segment duration', 'containing an active USV emission'})
% 
%     bins = 0:5:max(t)+5; %rebin at 1s
%     g = discretize(t, bins);
%     avg_prop = accumarray(g', prop_on', [], @mean, 0);
%     avg_t = bins(1:length(avg_prop));
%     plot(avg_t,avg_prop,DisplayName="Average (5s)", LineWidth=2)
%     legend()
% 
%     % USV rate
%     figure(2); clf; hold on;
%     scatter(t(2:end),1./diff(t'),'.', DisplayName="Instantaneous rate per USV");
%     xlabel('Time (s)')
%     ylabel('USV rate (Hz)')
% 
%     window = 5;
%     step = .1;
%     avg_t = 0:step:max(t);
%     y = zeros(size(avg_t));
%     for i=1:length(avg_t)
%         y(i) = sum(t>avg_t(i) & t<(avg_t(i)+window))/window;
%     end
%     y = movmean(y,window/step);
%     x=avg_t;
% 
%     plot(x,y,DisplayName="Average rate (5s)",LineWidth=2)
%     legend()
%     % yscale('log')
%     yscale('linear')
%     ylim([0 ,max(y)*1.2])
% end

end
