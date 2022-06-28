function MI = findMI(gait_vel,feat)
test = [gait_vel feat];

d1 = size(gait_vel,2);

vel_loc = 1:d1;
feat_loc = d1+1:size(test,2);
n_zeros = zeros(d1,length(feat_loc));

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