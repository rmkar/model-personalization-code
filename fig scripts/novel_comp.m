X = categorical({'IU-1','IU-2'});
Y = [68 67 80; 48 53 80 ];

rms = [0.13, 0.21; 12.8, 3.6 ; 0.14, 0.17];
b = bar(X,Y);

xtips1 = b(1).XEndPoints;
ytips1 = b(1).YEndPoints;
labels1 = [string(rms(1,:)) + ' m/s'];
text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom','FontSize',12)

xtips2 = b(2).XEndPoints;
ytips2 = b(2).YEndPoints;
labels2 = [string(rms(2,:)) + ' m/s'];
text(xtips2,ytips2,labels2,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom','FontSize',12)

xtips3 = b(3).XEndPoints;
ytips3 = b(3).YEndPoints;
labels3 = [string(rms(3,:)) + ' m/s'];
text(xtips3,ytips3,labels3,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom','FontSize',12)

legend('Untransformed Base Data','Transformed Base Data','Base and Novel Data','Location','Southeast','FontSize',12)
xlabel('Subject','FontSize',12)
ylabel('Percentage of Success','FontSize',12)

%928,561,570,305