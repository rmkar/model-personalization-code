function [features, vk_next,vk] = extract_training_data_novel(dataFolder,n_trials)

% if nargin < 2
%     n_trials = [1 1];
% end
% 
% sd_trials = 1:n_trials(1);
% su_trials = [1:n_trials(2)] + 3;

if nargin < 2
    n_trials = [1 4];
end

filePattern = fullfile(dataFolder, '*.mat');
files_full = dir(filePattern);
ct_d = 1;
ct_t = 1;
deleto = [];
tdfile = [];

for k = 1:length(files_full)
    idx1 = strfind(files_full(k).name,'TD');
    idx2 = strfind(files_full(k).name,'NC');
    if ~isempty(idx2)
        deleto(ct_d) = k;
        ct_d = ct_d+1;
    elseif ~isempty(idx1)
        tdfile(ct_t) = k;
        ct_t = ct_t + 1;
    end
end

files_ms = files_full(setdiff(1:end,[deleto tdfile]));
files_td = files_full(tdfile);

N = length(files_ms);

vk = [];
vk_next = [];

features = [];
for k = n_trials
    
    baseFilename = files_ms(k).name;
    fullFilename = fullfile(files_ms(k).folder,baseFilename);
    load(fullFilename);
    
    idx_n = commandStep;
    idx = commandStep-1;
    idx_s = commandStep; %+1;
    n_steps = min(4,length(measMat) - idx_s);
    
    v = measMat(1:end-1,4);
    vk = [vk;v(idx:idx+n_steps-1);];
    vk_next = [vk_next;v(idx_n:idx_n+n_steps-1)];
    
    baseFilename = files_td(k).name;
    fullFilename = fullfile(files_td(k).folder,baseFilename);
    load(fullFilename);
    
%     measMat_TD = [measMat_TD(2:end,:);measMat_TD(1,:)];
    
    features = [features;measMat_TD(idx_s:idx_s+n_steps-1,:)];
    
end
features(:,2) = [];

end