clc;
clear all;
close all;

%parameters
rng(17);

%INPUT: k_mtx, boundaries_id, NC, s
% load('2D_constellation.mat');

X = zeros(10000,320*180*3);

fileList = getAllFiles('../Drive/');
id = [1:10000];
id2 = [1:10000];

parfor i=1:10000%length(fileList)    
    i  
    if i == 1
        ind = 1;
    elseif i == 2
        ind = 5000;
    else
       ind = randi(length(fileList));
    end
    
    id2(i) = ind;
    img = im2double(imread(fileList{ind}));
    %img = imresize(img,[64 64]);
    %img = rgb2gray(img);
    
    img = img(:)';
    X(i,:) = img;   
   
end

%X = X(:,1:2);

startin = 1;
endin = 2;

Xold = X;

k_mtx = X*X';

NC=5;
s =[ 1000 500 400 300 200 100 90 80 70 60 50 40 35 30 20 10 9 8 7 6 5 ];

%boundaries_id = utility_mousePick(X,2);

boundaries_id = [startin endin];
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
plot(squeeze(X(solutions_medoid(s_maxev_id,1:solutions_NC(s_maxev_id)),1)),squeeze(X(solutions_medoid(s_maxev_id,1:solutions_NC(s_maxev_id)),2)),'r-x','LineWidth',1.5);
plot(squeeze(X(solutions_medoid(s_maxcv_id,1:solutions_NC(s_maxcv_id)),1)),squeeze(X(solutions_medoid(s_maxcv_id,1:solutions_NC(s_maxcv_id)),2)),'g-x','LineWidth',1.5);
   
axis equal;
hl=legend('data','filtered out','ev sol','ks sol');
hl.Position=[0,0.35,0.1,0.1];

laste = NC;
for i=1:NC
   if solutions_medoid(size(evidence,2),i)==0
      laste = i-1;
      break;
   end
end

imgs = solutions_medoid(size(evidence,2),1:laste);

for i=1:laste
    idimg = id(imgs(i));
    name = fileList{id2(idimg)};
    [filepath,name2,ext] = fileparts(name);
    newStr = strrep(filepath,'..\Drive\','a');
    newStr2 = strrep(newStr,'\','a');
    filename = sprintf('output/%d_%s_%d.jpg',startin,newStr2,i);
    copyfile(name,filename)  % here you save the figure
end


