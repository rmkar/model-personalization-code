function F = fscore(feat,y)
n_feat = size(feat,2);
F = zeros(n_feat,1);

for ct = 1:n_feat
    X = feat(:,ct);
    n = length(X);
    corr_mat = corrcoef(X,y);
    dof = n-2;
    corr_coef_sq = corr_mat(1,2)^2;
    
    F(ct,1) = corr_coef_sq / (1 - corr_coef_sq) * dof;
end
% F = F./fcdf(F,1,dof); % Divide by p-value of the score for refinement
end