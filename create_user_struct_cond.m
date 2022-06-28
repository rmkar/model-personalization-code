clear 
filename = 'struct_NAB3_adap_cond';

conditional_models

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


