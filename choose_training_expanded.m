addpath('Aux fun');

% dataFolder = {
%     './Datasets/AB1 Adap Crutches/',
%     './Datasets/AB2 Adap Crutches/',
%     './Datasets/AB2 Free Crutches/',
%     './Datasets/AB1 Free Crutches/',
%     './Datasets/AB3 Adap Crutches/',
%     './Datasets/AB3 Free Crutches/'
%     };
% 
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

novelData = {'./Datasets/NAB3 Adap/'};

feat_select = 0;

filePattern = fullfile(novelData{1}, '*.mat');
files_full = dir(filePattern);

trial_idx = 1:length(files_full)/2;
max_set = [2 3];
trial_combs = gen_trial_array(trial_idx,max_set);

index_mat = @(mat,x,y) mat(x,y);

% wsd = zeros(18,1);
% dkl = zeros(18,1);
% KL_mat = zeros(18,size(trial_combs,1));
% KL_mat_w = zeros(18,size(trial_combs,1));
% corr_mat = zeros(18,size(trial_combs,1));

weight = @(x) abs(x);

% normalize = @(x)(x-min(x))/(max(x)-min(x));

for comb = 1:size(trial_combs,1)
    n_trials = trial_combs{comb};
    [feat_set, gait_vel, ss_full_set, ss_vk_next] = process_transform(dataFolder,novelData,n_trials);
    
    if feat_select == 1
        n_feat = size(feat_set,2);
        MI_ind = zeros(n_feat,1);
        
        for ct = 1:n_feat
            MI_ind(ct) = findMI(diff(gait_vel),diff(feat_set(:,ct)));
        end
        
        %     parfor k = 1:18
        %         wsd(k,1) = ws_distance(feat_set(:,k),gait_vel);
        %         dkl(k,1) = KL(gait_vel,feat_set(:,k));
        %         MI(k,1) = findMI(gait_vel,feat_set(:,k));
        %         corr_coeff(k,1) = (index_mat(corrcoef(feat_set(:,k),gait_vel),1,2));
        %     end
        
        [selected_mrmr,score] = mrmr(diff(feat_set),18,MI_ind);
        
        for ct = 1:n_feat
            sub_select = selected_mrmr(1:ct);
            MI_mrmr(ct) = findMI(diff(gait_vel),diff(feat_set(:,sub_select)));
        end
       
        inc = diff(MI_mrmr/MI_mrmr(end)*100);
        feat_idx = find(inc>1)+1;
        
        selected = sort(selected_mrmr([1 feat_idx]));
        feat_set_red = feat_set(:,selected);
        pair_select{comb} = selected;
        MI_full(comb,1) = findMI(diff(gait_vel),diff(feat_set_red));
    else
        MI_full(comb,1) = findMI(diff(gait_vel),diff(feat_set));
    end
end

%%

[max_mif,mif_idx] = max(MI_full);

trial_data_mif = trial_combs{mif_idx}

if exist('pair_select','var') 
selected =  pair_select{mif_idx}
end
%%

%%
function MI = findMI(gait_vel,feat)
test = [gait_vel feat];

vel_loc = 1;
feat_loc = 2:size(test,2);
n_zeros = zeros(1,length(feat_loc));

p.mean = mean(test)';
p.cov = cov(test);

q.mean = mean(test)';
% q.cov = diag(diag(cov(test)));

feat_cov = cov(test);
feat_cov(vel_loc,feat_loc) = n_zeros;
feat_cov(feat_loc,vel_loc) = n_zeros';
q.cov = feat_cov;

MI = KL(p,q);
end

function normalized = normalize(x)
normalized = zeros(size(x));

for ct = 1:size(zeros,2)
    normalized(:,ct) = (x(:,ct)-min(x(:,ct)))/(max(x(:,ct))-min(x(:,ct)));
end
end

function [selected,score] = mrmr(featMat,K,vMI)
n_feat = size(featMat,2);

not_selected = [1:n_feat];

if nargin < 4
    selected = [];
else
    not_selected(intersect(not_selected,selected)) = [];
    K = K - length(selected);
end


fMI = ones(n_feat)*1e-5;

score = zeros(K,1);
for ct = 1:K
    
    if length(selected) >= 1
        last_selected = selected(end);
        mi_vec = miVec(featMat,not_selected,last_selected);
        fMI(not_selected,last_selected) = mi_vec;
        score_mi = vMI(not_selected,1)./mean(fMI(not_selected,selected),2);
        [score(ct,1),select_idx] = max(score_mi);
        selected = [selected not_selected(select_idx)];
        not_selected(select_idx) = [];
    else
        [score(ct,1),select_idx] = max(vMI);
        selected = select_idx;
        not_selected(not_selected == select_idx) = [];
    end
    
end


end


function mi = miVec(feat,not_selected,last_selected)
mi = zeros(length(not_selected),1);
for k = 1:length(not_selected)
    idx = not_selected(k);
    feat_mi = findMI(feat(:,idx),feat(:,last_selected));
    mi(k,1) = feat_mi;
    
end
mi(mi < 1e-4) = 1e-5;
end

