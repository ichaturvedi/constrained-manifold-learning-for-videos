clc;
clear all;
close all;

rng(17);

%INPUT: X, boundaries_id, NC, s
load('2D_constellation.mat');
NC=15;
s =[ 10000 1000 500 400 300 200 100 90 80 70 60 50 40 35 30 20 10 9 8 7 6 5 ];
boundaries_id = utility_mousePick(X,2);

%run the algorithm
[ X, X_garbage, solutions, evidence, kseg_score ] = annealing_rpls( X, boundaries_id, NC, s );

%find best solution according to evidence maximization
[~,s_maxev_id]=max(evidence);

%find best solution according to k-segment score minimization
s_maxcv_id=1;
while ((kseg_score(s_maxcv_id) > kseg_score(s_maxcv_id+1)) && s_maxcv_id<length(s)-1)
    s_maxcv_id=s_maxcv_id+1;
end

%visualize results
figure('Position',[0 0 1280 720],'Color','w');

subplot(2,1,1);
title(['NC = ' num2str(NC)]);
set(gca,'xlim',[min(s) max(s)]);
set(gca,'xscale','log');
hold on;
yyaxis('left');
set(gca,'ycolor','r');
plot(s,evidence,'r-');
y=ylim;
plot([s(s_maxev_id) s(s_maxev_id)],y,'r-.','linewidth',1);

yyaxis('right');
set(gca,'ycolor','g');
plot(s,kseg_score,'g-');
y=ylim;
plot([s(s_maxcv_id) s(s_maxcv_id)],y,'g-.','linewidth',1);
hl=legend('evidence','s_{ev}','k-segments score','s_{ks}');
hl.Position=[0,0.85,0.1,0.1];

subplot(2,1,2);
title(['\color{red} s_{ev}=' num2str(s(s_maxev_id)) '  \color{green}s_{ks}' num2str(s(s_maxcv_id))]);
hold on;
    
scatter(X(:,1),X(:,2),'MarkerFaceColor','b','MarkerFaceAlpha',.1,'MarkerEdgeColor','none');
scatter(X_garbage(:,1),X_garbage(:,2),'MarkerFaceColor','c','MarkerFaceAlpha',.1,'MarkerEdgeColor','none');
plot(squeeze(solutions(s_maxev_id,:,1)),squeeze(solutions(s_maxev_id,:,2)),'r-x','LineWidth',1.5);
plot(squeeze(solutions(s_maxcv_id,:,1)),squeeze(solutions(s_maxcv_id,:,2)),'g-x','LineWidth',1.5);
   
axis equal;
hl=legend('data','filtered out','ev sol','ks sol');
hl.Position=[0,0.35,0.1,0.1];