set(0,'DefaultFigureVisible','on')
clc;
clear all;
close all;
result = zeros(1,1);

for ind = 1:2

%parameters
rng(17);

%INPUT: k_mtx, boundaries_id, NC, s
X=load('lstdb/trainxf');
Xy = load('lstdb/trainyf');

Xold = X;
id = [1:size(X)];

% 
% for ran1=1:100
%            sampleid = randsample(1:size(X1,1),1);
%            sample = X1(sampleid,:);
%            if ran1 == 1
%                X = sample;
%            else
%                X = [X;sample];
%            end
% end


% for ran1=1:100
%            sampleid = randsample(1:size(X2,1),1);
%            sample = X2(sampleid,:);
%            X = [X;sample];
% end


k_mtx = X*X';
NC=15;
s =[ 1000 500 400 300 200 100 90 80 70 60 50 40 35 30 20 10 9 8 7 6 5 ];
%boundaries_id = utility_mousePick(X,2); 
start_id = randsample(rng,size(X,1),1); 
end_id = randsample(rng,size(X,1),1);

%end_id = randsample(1001:size(X,1),1);
boundaries_id = [start_id end_id];

%run the algorithm
[ mask, solutions_medoid, solutions_NC, evidence, kseg_score ] = annealing_rpks( k_mtx, boundaries_id, NC, s ); 
X_garbage = X(~mask,:);
X = X(mask,:);
id = id(mask);

%find best solution according to evidence maximization
[~,s_maxev_id]=max(evidence);

%find best solution according to k-segment score minimization
s_maxcv_id=1;
while (((kseg_score(s_maxcv_id) > kseg_score(s_maxcv_id+1)) || s_maxcv_id==1) && s_maxcv_id<length(s)-1)
    s_maxcv_id=s_maxcv_id+1;
end

x1=squeeze(Xold(id(solutions_medoid(s_maxev_id,1:solutions_NC(s_maxev_id))),1));
y1=squeeze(Xold(id(solutions_medoid(s_maxev_id,1:solutions_NC(s_maxev_id))),1));
       
A = [x1 y1];
sumd = 0;
for i=1:size(A,1)-1
     r1 = A(i:i+1,:);
     d = pdist(r1,'euclidean');
     sumd = sumd + d;
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
    
scatter(X(1,:),X(2,:),'MarkerFaceColor','b','MarkerFaceAlpha',.1,'MarkerEdgeColor','none');
scatter(X_garbage(:,1),X_garbage(:,2),'MarkerFaceColor','c','MarkerFaceAlpha',.1,'MarkerEdgeColor','none');
plot(squeeze(X(solutions_medoid(s_maxev_id,1:solutions_NC(s_maxev_id)),1)),squeeze(X(solutions_medoid(s_maxev_id,1:solutions_NC(s_maxev_id)),2)),'r-x','LineWidth',1.5);
plot(squeeze(X(solutions_medoid(s_maxcv_id,1:solutions_NC(s_maxcv_id)),1)),squeeze(X(solutions_medoid(s_maxcv_id,1:solutions_NC(s_maxcv_id)),2)),'g-x','LineWidth',1.5);

axis equal;
hl=legend('data','filtered out','ev sol','ks sol');
hl.Position=[0,0.35,0.1,0.1];

for i=1:15
   if solutions_medoid(size(evidence,2),i)==0
      laste = i-1;
      break;
   end
end

imgs = X(solutions_medoid(size(evidence,2),1:laste),:);

for i=1:laste
    figure
    visualize(reshape(imgs(i,:),164,219))
end
close all
result(ind)=sumd;

end