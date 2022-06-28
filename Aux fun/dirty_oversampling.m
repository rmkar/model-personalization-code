function [new_set,new_vel] = dirty_oversampling(feat_set,gait_vel,N)

% feat_set contains gait features and N is the number of desired
% synthetic measurement instances
[n,m] = size(feat_set);

new_set = zeros(N,m);
new_vel = zeros(N,1);
for iter = 1:5
for k = 1:N
    meas = randi(n,[2,1]);
    new_set_tmp(k,:) = (feat_set(meas(1),:) + feat_set(meas(2),:))/2;
    new_vel_tmp(k,:) = (gait_vel(meas(1),:) + gait_vel(meas(2),:))/2;
end

new_set = new_set + new_set_tmp;
new_vel = new_vel + new_vel_tmp;
end


new_set = [feat_set;new_set/5];
new_vel = [gait_vel;new_vel/5];

end