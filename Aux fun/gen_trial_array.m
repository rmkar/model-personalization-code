function trial_array = gen_trial_array(trial_idx,choices)

trial_array = {};

for ct = 1:length(choices)
    combs = nchoosek(trial_idx,choices(ct));
    tmp = {};
    for comb = 1:size(combs,1)
        tmp{comb,1} = combs(comb,:);
    end
    trial_array = [trial_array;tmp];
end

end