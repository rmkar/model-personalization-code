load('comData.mat')

comZc = movmean(comZ_c(1224:1973),50)/1000;
comZw = movmean(comZ_w(1769:2410),50)/1000;

comYc = movmean(comY_c(1224:1973),50)/1000;
comYw = movmean(comY_w(1769:2410),50)/1000;

tc = (0:1/500:(length(comZc)-1)/500);
tw = (0:1/500:(length(comZw)-1)/500);

subplot(211)
plot(tc,comZc,'Linewidth',2)
hold on
plot(tw,comZw,'Linewidth',2)
hold off
ylabel('CoM vertical excursion (m)')
legend('Crutches','Walker','Location','Southoutside','Orientation','Horizontal')

subplot(212)
plot(tc,comYc,'Linewidth',2)
hold on
plot(tw,comYw,'Linewidth',2)
hold off
ylabel('CoM lateral excursion (m)')
xlabel('Time (s)')