ground_truth = [0.91, 0.67, 0.89, 0.75, 0.74, 0.79, 0.93, 0.83];

% Diff
ss = [37, 20, 13, 3, 14, 13, 24, 29];
ts = [46, 32, 17, 4, 25, 29, 30, 36];

% % Min
% ss = [35, 12, 10, 4, 16, 5, 19, 5];
% ts = [43, 26, 13, 8, 25, 7, 22, 6];

p_val = zeros(length(ts),3);

for trial = 1:length(ts)
    ps = ss(trial)/ts(trial);
    p_val(trial,1) = ps - ground_truth(trial);
    
    if ps >= ground_truth(trial)
        p_val(trial,2) = 1-binocdf(ss(trial),ts(trial), ground_truth(trial));
        p_val(trial,3) = 1;
    else
        p_val(trial,2) = binocdf(ss(trial),ts(trial), ground_truth(trial));
    end
    
end

p_val

find(p_val(:,2)<0.05)