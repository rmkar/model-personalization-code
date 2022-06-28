% dataFolder = {'./Datasets/NAB2 Adap/','./Datasets/NAB3 Adap'};
% dataFolder = {
%     './Datasets/AB1 Adap Crutches/',
%     './Datasets/AB2 Adap Crutches/',
%     './Datasets/AB2 Free Crutches/',
%     './Datasets/AB1 Free Crutches/',
%     './Datasets/AB3 Adap Crutches/',
%     './Datasets/AB3 Free Crutches/'
%     };

% dataFolder = {
%     './Datasets/AB1 Adap/',
%     './Datasets/AB2 Adap/',
%     './Datasets/AB2 Free/',
%     './Datasets/AB1 Free/',
%     './Datasets/AB3 Adap/',
%     './Datasets/AB3 Free/'
%     };

dataFolder = {
    './Datasets/AB1 Adap Crutches/',
    './Datasets/AB2 Adap Crutches/',
    './Datasets/AB2 Free Crutches/',
    './Datasets/AB1 Free Crutches/',
    './Datasets/AB3 Adap Crutches/',
    './Datasets/AB3 Free Crutches/',
    './Datasets/AB1 Adap/',
    './Datasets/AB2 Adap/',
    './Datasets/AB2 Free/',
    './Datasets/AB1 Free/',
    './Datasets/AB3 Adap/',
    './Datasets/AB3 Free/'
    };

novelData = {'./Datasets/NAB3 Adap Crutches/'};
n_trials = [1 2 3]; % [1 5] for NAB3, [3,4] for NAB2 but [1 4] works better

% novelData = {};

novel_feat = [];
novel_vk = [];
novel_vk_next = [];

ss_novel_feat  = [];
ss_novel_vk_next = [];
ss_novel_vk = [];

if ~isempty(n_trials)
    
    if ~isempty(novelData)
        for novel = 1:length(novelData)
            [novel_feat_u,novel_vk_next_u,novel_vk_u] = extract_training_data_novel(novelData{novel},n_trials);
            [novel_ss_features_u,novel_ss_vk_next_u,novel_ss_vk_u] = extract_training_data_ss_novel(novelData{novel},n_trials);
            
            novel_feat = [novel_feat;novel_feat_u];
            novel_vk_next = [novel_vk_next;novel_vk_next_u];
            novel_vk = [novel_vk;novel_vk_u];
            
            ss_novel_feat  = [ss_novel_feat;novel_ss_features_u];
            ss_novel_vk_next = [ss_novel_vk_next;novel_ss_vk_next_u];
            ss_novel_vk = [ss_novel_vk;novel_ss_vk_u];
        end
    end
    
    shift_dist = @(base,novel) (base - mean(base)).*std(novel)./std(base) + mean(novel);
    % shift_dist = @(base,novel) (base - mean(base))/sqrt_mat(cov(base))*sqrt_mat(cov(novel))+mean(novel);
    
    % shift_dist = @(base,novel)
    
    features = [];
    vk_next = [];
    vk = [];
    
    ss_features = [];
    ss_vk_next = [];
    ss_vk = [];
    
    scaled_base_feat = [];
    scaled_vk = [];
    scaled_vk_n = [];
    
    for user = 1:length(dataFolder)
        [features_u,vk_next_u,vk_u] = extract_training_data(dataFolder{user});
        [ss_features_u,ss_vk_next_u,ss_vk_u] = extract_training_data_ss(dataFolder{user});
        
        features = [features;features_u];
        vk_next = [vk_next;vk_next_u];
        vk = [vk;vk_u];
        
        ss_features = [ss_features;ss_features_u];
        ss_vk_next = [ss_vk_next;ss_vk_next_u];
        ss_vk = [ss_vk;ss_vk_u];
        
        %     scaled_base_feat = [scaled_base_feat; shift_dist(features_u,novel_feat)];
        %     scaled_vk = [scaled_vk; shift_dist(vk_u,novel_vk)];
        %     scaled_vk_n = [scaled_vk_n; shift_dist(vk_next_u,novel_vk_next)];
    end
    
    base_feat = features;
    base_vk = vk;
    base_vk_next = vk_next;
    
    scaled_base_feat = shift_dist(base_feat,novel_feat);
    scaled_vk = shift_dist(vk,novel_vk);
    scaled_vk_n = shift_dist(vk_next,novel_vk_next);
    
    ss_scaled_base_feat = shift_dist(ss_features,ss_novel_feat);
    ss_scaled_vk = shift_dist(ss_vk,ss_novel_vk);
    ss_scaled_vk_n = shift_dist(ss_vk_next,ss_novel_vk_next);
    
    % scaled_base_feat = shift_dist(base_feat-mean(ss_features),novel_feat-mean(ss_novel_feat));
    % scaled_vk = shift_dist(vk-mean(ss_vk),novel_vk-mean(ss_novel_vk));
    % scaled_vk_n = shift_dist(vk_next - mean(ss_vk_next),novel_vk_next - mean(ss_novel_vk_next));
    
    features = [scaled_base_feat;novel_feat];
    vk_next = [scaled_vk_n;novel_vk_next];
    vk = [scaled_vk; novel_vk];
    
    ss_features = [ss_scaled_base_feat;ss_novel_feat];
    ss_vk_next = [ss_scaled_vk_n;ss_novel_vk_next];
    ss_vk = [ss_scaled_vk; ss_novel_vk];
    
%     features = [scaled_base_feat];
%     vk_next = [scaled_vk_n];
%     vk = [scaled_vk];
% 
%     ss_features = [ss_scaled_base_feat];
%     ss_vk_next = [ss_scaled_vk_n];
%     ss_vk = [ss_scaled_vk];
   
%     features = [novel_feat];
%     vk_next = [novel_vk_next];
%     vk = [novel_vk];
%     
%     ss_features = [ss_novel_feat];
%     ss_vk_next = [ss_novel_vk_next];
%     ss_vk = [ss_novel_vk];
    
else
    
    features = [];
    vk_next = [];
    vk = [];
    
    ss_features = [];
    ss_vk_next = [];
    ss_vk = [];
    
    for user = 1:length(dataFolder)
        [features_u,vk_next_u,vk_u] = extract_training_data(dataFolder{user});
        [ss_features_u,ss_vk_next_u,ss_vk_u] = extract_training_data_ss(dataFolder{user});
        
        features = [features;features_u];
        vk_next = [vk_next;vk_next_u];
        vk = [vk;vk_u];
        
        ss_features = [ss_features;ss_features_u];
        ss_vk_next = [ss_vk_next;ss_vk_next_u];
        ss_vk = [ss_vk;ss_vk_u];
        
        %     scaled_base_feat = [scaled_base_feat; shift_dist(features_u,novel_feat)];
        %     scaled_vk = [scaled_vk; shift_dist(vk_u,novel_vk)];
        %     scaled_vk_n = [scaled_vk_n; shift_dist(vk_next_u,novel_vk_next)];
    end
end

full_set = [features vk];

feature_names = {'Step Length','Leg Angle theta','RMS Swing Curr Hip','RMS Swing Curr Knee','tTD','Swing Angle Hip','Swing Angle Knee','Swing Angular Vel Hip','Swing Angular Vel Knee','Stance Angle Hip','Stance Angle Knee','Stance Angular Vel Hip','Stance Angular Vel Knee','TAng','TAng Vel','TRoll','TRoll Vel'};

model_data = [full_set vk_next];

model_mean = mean(model_data)';
model_cov = cov(model_data);

ss_model_mean = mean([ss_features ss_vk ss_vk_next])';
ss_model_cov = cov([ss_features ss_vk ss_vk_next]);

vk_reg = model_mean(19,1) + model_cov(19,1:18)/model_cov(1:18,1:18)*(full_set'-model_mean(1:18,1));

[Rsquared,rmse] = goodness(vk_next,vk_reg')
selected = 1:18;


% %% Reduce features
%
% novel_diff = mean([scaled_base_feat scaled_vk]) - mean([novel_feat novel_vk]);
%
% [sorted_diff,mean_idx] = sort(abs(novel_diff)./abs(mean([novel_feat novel_vk])));
% % selected  = sort(mean_idx(sorted_diff<0.5));
% feat_list = [1:size(full_set,2)];
% selected = feat_list(novel_diff < 0.5*std([novel_feat novel_vk]));
%
% vk_reg_red = model_mean(19,1) + model_cov(19,selected)/model_cov(selected,selected)*(full_set(:,selected)'-model_mean(selected,1));
%
%
% Rsquared_min = goodness(vk_next,vk_reg_red');


%% Aux fun

function [Rsquared,rmse] = goodness(measured, estimated)

rmse = rms(measured-estimated);

TSS = sum((measured-mean(estimated)).^2);
RSS = sum((measured-estimated).^2);
Rsquared = 1 - RSS/TSS;

end


function out = sqrt_mat(A)

[V, D] = eig(A);
D(D<1e-8) = 0;
out = V*D.^(0.5)/V;

end