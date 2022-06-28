clear
close all
addpath('Aux fun');

% dataFolder = {
%     './Datasets/AB1 Adap Crutches/',
%     './Datasets/AB2 Adap Crutches/',
%     './Datasets/AB2 Free Crutches/',
%     './Datasets/AB1 Free Crutches/',
%     './Datasets/AB3 Adap Crutches/',
%     './Datasets/AB3 Free Crutches/'
%     };

dataFolder = {
    './Datasets/AB1 Adap/',
    './Datasets/AB2 Adap/',
    './Datasets/AB2 Free/',
    './Datasets/AB1 Free/',
    './Datasets/AB3 Adap/',
    './Datasets/AB3 Free/'
    };

novelData = {'./Datasets/NAB2 Adap/'};

n_trials = [3 5 6];

[feat_set, gait_vel, ss_full_set, ss_vk_next] = process_transform(dataFolder,novelData,n_trials);
model_data = [feat_set, gait_vel];

n_feat = size(feat_set,2);

MI_ind = zeros(n_feat,1);

for ct = 1:n_feat
    MI_ind(ct) = findMI(diff(gait_vel),diff(feat_set(:,ct)));    
end

MI_full = findMI(diff(gait_vel),diff(feat_set))

[MI_sorted,sort_idx] = sort(MI_ind,'descend');

sort_idx = sort_idx';

MI_red = zeros(1,n_feat);

for ct = 1:n_feat
    selected = sort(sort_idx(1:ct));
    MI_red(ct) = findMI(diff(gait_vel),diff(feat_set(:,selected)));
end


[selected_mrmr,score] = mrmr(diff(feat_set),18,MI_ind);

for ct = 1:n_feat
    selected = sort(selected_mrmr(1:ct));
    MI_mrmr(ct) = findMI(diff(gait_vel),diff(feat_set(:,selected)));
end

inc_mrmr = diff(MI_mrmr/MI_mrmr(end)*100);
inc_naive = diff(MI_red/MI_red(end)*100);


[N,edges] = histcounts(inc_mrmr);
feat_threshold = edges(2);
feat_idx = find(inc_mrmr>=feat_threshold)+1;
idx_mrmr = [1 feat_idx];
selected = (selected_mrmr([1 feat_idx]))

[N,edges] = histcounts(inc_naive);
feat_threshold = edges(2);
feat_idx = find(inc_naive>=feat_threshold)+1;
idx_naive = [1 feat_idx];
selected_naive = (sort_idx([1 feat_idx]))

%%
% yyaxis left
% plot(MI_red,'-*')
% hold on
% plot(MI_mrmr,'-s')
% hold off
% legend('Naive sort','MRMR')

% yyaxis right
MI_naive = MI_red/MI_red(end)*100;
MI_smart = MI_mrmr/MI_mrmr(end)*100;

plot(MI_naive,'-*','LineWidth',2)
hold on
plot(MI_smart,'-s','LineWidth',2)
plot(idx_naive,MI_naive(idx_naive),'ro','Markersize',10,'Linewidth',2)
plot(idx_mrmr,MI_smart(idx_mrmr),'ko','Markersize',10,'Linewidth',2)
hold off
legend('Naive sort','MRMR')
xlabel('Number of Features')
ylabel('Mutual Information (Percentage of Max)')

figure()
plot(inc_naive)
hold on
plot(inc_mrmr)
hold off
legend('Naive sort','MRMR')


%%

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
