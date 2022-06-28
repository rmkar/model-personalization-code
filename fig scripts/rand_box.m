load('randomized_ps.mat')

% NAB2 Walker and Crutches trained on walker base

subjects = [repmat(['Walker','  '],size(ps_walker,1),1);repmat('Crutches',size(ps_crutches,1),1)];

h = boxplot([ps_walker;ps_crutches]*100,subjects);
set(h,{'linew'},{1.5})
hold on
plot(1,88,'g*','MarkerSize',10,'LineWidth',3)
plot(2,77,'g*','MarkerSize',10,'LineWidth',3)
hold off

xlabel('Ambulatory Device for IU-1','FontSize',12)
ylabel('Percentage of Success','FontSize',12)
% legend({'Estimation accuracy with novel data' + newline + 'chosen using KL divergence'})