close all

subs = 1:3;

% Both
per_succ_b = [77.5 84.6 83.7]';
rmse_b = [0.12,0.12,0.11];

CI_b = [63 88;
    71 93;
    70 93];

% Adap
per_succ_a = [61.5 77.5 75]';
rmse_a = [0.25 0.14 0.14];

CI_a = [48 74;
    63 88;
    61 85];

% Free
per_succ_f = [54.2 63 67]';
rmse_f = [0.22 0.16 0.13];

CI_f = [38 78;
    46 79;
    50 80];

f1 = genPlot(subs, CI_b, rmse_b, per_succ_b);
f1.CurrentAxes.Title.String = 'Estimator Performance with base data from Free and Adap trials';

f2 = genPlot(subs, CI_a, rmse_a, per_succ_a);
f2.CurrentAxes.Title.String = 'Estimator Performance with base data from Adap trials';

f3 = genPlot(subs, CI_f, rmse_f, per_succ_f);
f3.CurrentAxes.Title.String = 'Estimator Performance with base data from Free trials';


function fig = genPlot(subs, CI, rmse, per_succ)
fig = figure()
y = [CI(:,1) ; flip(CI(:,2))];
x = [subs flip(subs)];

yyaxis left
p1 = plot(subs, per_succ,'-*','LineWidth',2);
ylabel('Percentage Success','Fontsize',13)
hold on
h = fill(x,y,'b','facealpha',0.1,'EdgeColor','none');
hold off
a = get(gca,'YTickLabel');
set(gca,'YTickLabel',a,'fontsize',12)

yyaxis right
p2 = plot(subs, rmse,'--s','LineWidth',2);
a = get(gca,'YTickLabel');
set(gca,'YTickLabel',a,'fontsize',12)
ylabel('RMS Velocity Estimation Error (m/s)','Fontsize',13)
xlabel('Number of Subjects','Fontsize',13)
legend(h,'95% Confidence Interval')
ylim(gca, ylim(gca) + [-1,1]*range(ylim(gca)).* 0.05)
set(gca, 'XTick', 1:4)
end