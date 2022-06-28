 close all
% clc
% clear
trial = 'all';

addpath('./estimator_fun/')

% load('struct_NAB3_adap_novel.mat'); trialfun = @(msfile,tdfile,feature_num) fun_BKF(msfile,tdfile,userStruct);
% load('struct_NAB2_adap_pca.mat'); trialfun = @(msfile,tdfile,feature_num) fun_BKF_pca(msfile,tdfile,userStruct);
load('struct_NAB3_adap_cond.mat'); trialfun = @(msfile,tdfile,feature_num) fun_BKF_cond(msfile,tdfile,userStruct);
trialDataFolder = './Datasets/NAB3 Adap Crutches'; 

n_feat = length(userStruct.selected_feat);

filePattern = fullfile(trialDataFolder, '*.mat');
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

data = [];
trial_data = {};

for k = 1:N
    
    baseFilename_MS = files_ms(k).name;
    fullFilename_MS = fullfile(files_ms(k).folder,baseFilename_MS);
    
    baseFilename_TD = files_td(k).name;
    fullFilename_TD = fullfile(files_td(k).folder,baseFilename_TD);
    
    data_ms = load(fullFilename_MS);
    data_td = load(fullFilename_TD);
    
    [Xs,Xs_TD] = trialfun(data_ms, data_td);
    
    intent_signal = diff(Xs_TD(:,7));
    measured_diff = diff(data_ms.measMat(1:size(Xs,1),4));
    est_diff = Xs_TD(:,7) - Xs(1:end-1,4);
    
    data_trial = [intent_signal measured_diff(2:end) est_diff(2:end)];
%     
%     if exist(agfile) == 2
%         load(agfile);
%         data = [data;data_trial];
%     else
%         data = data_trial;
%     end
    
    trial_data{k,1} = baseFilename_MS(end-8:end-4);
    trial_data{k,2} = data_trial;
    
    data = [data;data_trial];
end
dataStruct.data = data;
dataStruct.trial_data = trial_data;



%% Confidence Interval

ci_aggregation = {};
feature_names = {'Step Length','Leg Angle theta','RMS Swing Curr Hip','RMS Swing Curr Knee','tTD','Swing Angle Hip','Swing Angle Knee','Swing Angular Vel Hip','Swing Angular Vel Knee','Stance Angle Hip','Stance Angle Knee','Stance Angular Vel Hip','Stance Angular Vel Knee','TAng','TAng Vel','TRoll','TRoll Vel'};

if isfield(userStruct,'ss_threshold')
    [error, ps, CI, su_tf, sd_tf] = confidence_int(dataStruct,trial,userStruct.ss_threshold);
else
    [error, ps, CI, su_tf, sd_tf] = confidence_int(dataStruct,trial);
end

ci_aggregation{1} = error;
ci_aggregation{2} = ps ;
ci_aggregation{3} = CI';
ci_aggregation{4} = trial;
ci_aggregation{5} = su_tf;
ci_aggregation{6} = sd_tf;
ci_aggregation{7} = [su_tf(1)+sd_tf(1) sum([su_tf;sd_tf],'all')];

trial_ag = cell2table(ci_aggregation,'VariableNames',{'RMS_error','Probability_of_success','Confidence_Intervals','Trial','SU_T_F','SD_T_F','Successful Steps'})


function [error, ps, CI, su_tf, sd_tf] = confidence_int(dataStruct,trial,ss_threshold)

% if strcmp(trial,'all')
%     data = dataStruct.data;
% else
%     trial_data = dataStruct.trial_data;
%     trial_no = contains(dataStruct.trial_data(:,1),trial);
%     data = dataStruct.trial_data{trial_no,2};
% end

if nargin < 3
    ss_threshold = 0;
end

switch trial
    case 'all'
        data = dataStruct.data;
        
    case 'SD'
        trial_nos = find(contains(dataStruct.trial_data(:,1),'SD'));
        data = [];
        for k = 1:length(trial_nos)
            data = [data;dataStruct.trial_data{trial_nos(k),2}];
        end
    
    case 'SU'
        trial_nos = find(contains(dataStruct.trial_data(:,1),'SU'));
        data = [];
        for k = 1:length(trial_nos)
            data = [data;dataStruct.trial_data{trial_nos(k),2}];
        end
    
    otherwise
        trial_no = contains(dataStruct.trial_data(:,1),trial);
        data = dataStruct.trial_data{trial_no,2};
end

intent_signal = data(:,1);
measured_diff = data(:,2);
est_diff = data(:,3);

step_idx = find(abs(est_diff)>ss_threshold);

trials = sign(intent_signal(step_idx)).*sign(measured_diff(step_idx));
error = rms(intent_signal(step_idx) - measured_diff(step_idx));

n = length(intent_signal(step_idx));
ns = nnz(trials(trials>0));

fp_su = nnz(intent_signal(step_idx) > 0 & measured_diff(step_idx) < 0);
fp_sd = nnz(intent_signal(step_idx) < 0 & measured_diff(step_idx) > 0);

tp_su = nnz(intent_signal(step_idx) > 0 & measured_diff(step_idx) > 0);
tp_sd = nnz(intent_signal(step_idx) < 0 & measured_diff(step_idx) < 0);

su_tf = [tp_su fp_su];
sd_tf = [tp_sd fp_sd];
%%

a = ns + 1/2;
b = n - ns + 1/2;

alpha = 0.05; % for 95% confidence interval

ps = ns/n;
CI = icdf('Beta',[alpha/2;1-alpha/2],a,b);


end