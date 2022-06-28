% NAB2_data = [91 84 77 86;
%             74 83 80 81;
%             69 84 73 76;
%             68 52 66 77];
        
NAB2_data = [74 83 80;
            69 84 73;
            68 52 66];
        
% NAB3_data = [80 81 86 90;
%              62 76 75 81;
%              63 88 78 92;
%              48 81 75 81];
         
NAB3_data = [62 76 75;
             63 88 78;
             48 81 75];

figure(1)
h1 = heatmap([0 1 2],[2 1 0],NAB2_data);
% title('Estimator accuracy for novel data combinations for NAB2')
xlabel('Number of SD sets')
ylabel('Number of SU sets')

figure(2)
h2 = heatmap([0 1 2],[ 2 1 0],NAB3_data);
title('Estimator accuracy for novel data combinations for NAB3')
xlabel('Number of SD sets')
ylabel('Number of SU sets')