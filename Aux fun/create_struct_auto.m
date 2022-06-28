function userStruct = create_struct_auto(dataFolder, novelData, n_trials, filename)
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


model_mean = mean([full_set vk_next])';
model_cov = cov([full_set vk_next]);

ss_model_mean = mean([ss_features ss_vk ss_vk_next])';
ss_model_cov = cov([ss_features ss_vk ss_vk_next]);

selected = 1:18;

userStruct.selected_feat = selected;
userStruct.model_mean = model_mean;
userStruct.model_cov = model_cov;
userStruct.estimate_vel =  @estimate_vel;
userStruct.ss_threshold = std(ss_vk);

save(filename,'userStruct');

function [y,P] = estimate_vel(y_in, model_mean,model_cov,selected)

y = model_mean(19,1) + model_cov(19,selected)/model_cov(selected,selected)*(y_in(selected,1)-model_mean(selected,1));
P = model_cov(19,19) - model_cov(19,selected)/model_cov(selected,selected)*model_cov(selected,19);

end

end