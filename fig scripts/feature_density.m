% dataFolder = {'./Datasets/NAB2 Adap/','./Datasets/NAB3 Adap'};
addpath('../')

novelData = {'../Datasets/NAB2 Adap/'};
n_trials = [1 2 4 5]; % [1 3] for NAB3, [3,4] for NAB2 but [1 4] works better

feature_names = {'Step Length','Leg Angle theta','RMS Swing Current - Hip','RMS Swing Current - Knee (A)','tTD','Swing Angle - Hip (rad)','Swing Angle Knee','Swing Angular Vel Hip','Swing Angular Vel - Knee (rad/s)','Stance Angle Hip','Stance Angle Knee','Stance Angular Vel - Hip (rad/s)','Stance Angular Vel Knee','TAng','TAng Vel','TRoll','TRoll Vel'};

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
end
%%

feat = [4 6 9];
% feat = 1:17;
t = tiledlayout(2,2);


for ct = 1:length(feat)
m = bootstrp(1000,@mean,novel_feat(:,feat(ct)));
[f,x] = ksdensity(m);
% [f,x] = ksdensity(novel_feat(:,feat(ct)));
nexttile
plot(x,f,'LineWidth',2)
xlabel(feature_names{feat(ct)},'FontSize',13)
end

m = bootstrp(1000,@mean,novel_vk);
[f,x] = ksdensity(m);
% [f,x] = ksdensity(novel_vk);
nexttile
plot(x,f,'LineWidth',2)
xlabel('Gait Velocity (m/s)','FontSize',13)

ylabel(t,'Probability Density','FontSize',13)
title(t,'Estimated Probability Density of Gait Feature Distribution Means','fontweight','bold')