function [ centroids, labels, global_cost] = rpls( x, init_centroids, s)
%RPLS Regularized Path in Linear Space
%   [ medoids_id, labels, global_cost] = RPKS( x, init_medoids_id, s)
%
%   Finds a path connecting init_centroids(1) to init_centroids(NC)
%   optimizing a regularized k-means cost function with an EM-like
%   procedure.
%   
%   The initial and final centroids are kept fixed, thus optimizing the cost
%   on the remaining NC-2 centroids.
%
%   INPUT:
%
%   x: dataset. (NxD)
%
%   init_centroids: initial set of centroids ordered according to the 
%   topology. (NCxD)
%
%   s: regularization parameter.
%
%   OUTPUT:
%
%   centroids: final set of centroids. (NCxD)
%
%   labels: final set of labels. (1xN, values [1,NC])
%
%   global_cost: value of the cost function at each iteration. 

    N = size(x,1);
    D = size(x,2);
    NC = size(init_centroids,1);
    
    %initialize labels
    dst_mtx = utility_dstMtx(x,init_centroids);
    [~,labels]=min(dst_mtx,[],2);

    %separate movable centroids from boundaries
    boundaries = init_centroids([1,NC],:);
    boundaries = [boundaries(1,:); zeros(NC-4,D); boundaries(2,:)];
    centroids = init_centroids;
    NC = NC-2;
    labels = labels-1;
    
    %iterate the algorithm
    iteration=0;
    converged=0;
    labels_new=labels;
    while(~converged)
        iteration = iteration+1;
        disp(['iteration:' num2str(iteration)]);
        card = [];
        
        %remove empty clusters
        i=1;
        while(i<NC+3)
%             if(sum(labels==i-1)>0)
                card(i)=sum(labels==i-1);
                i = i+1;
%             else
%                 warning('RPKS: warning, empty cluster removed.');
%                 labels(labels>i)=labels(labels>i)-1;
%                 NC = NC-1;
%             end
        end
        
        C=zeros(NC,D);
        for i=1:NC
            C(i,:) = sum(x(labels==i,:),1);
        end
        
        E=zeros(D);
        for i=1:D
            E(i,i) = sum(x(:,i)'*x(:,i));
        end
        
        CB = zeros(NC,D);
        CB(1,:) = sum(x(labels==0,:),1);
        CB(NC,:) = sum(x(labels==NC+1,:),1);
        
        AD = diag(card(2:NC+1));
        AW = toeplitz([1 -0.5 zeros(1,NC-2)]);
        AB = diag([card(1), zeros(1,NC-2), card(NC+2)]);
        
        centroids = centroids(2:NC+1,:);
        cost = trace(0.5 * centroids' * AD * centroids - C'*centroids + 0.5*E + 0.5*boundaries'*AB*boundaries - boundaries'*CB);
        costReg = trace(0.5 * s * centroids' * AW * centroids - (0.5*s*boundaries)'*centroids + 0.25*s*boundaries'*boundaries);
        global_cost(iteration) = cost + costReg;
        
        centroids = [boundaries(1,:); pinv(AD+s*AW) * (C+0.5*s*boundaries); boundaries(NC,:)];
        
        dst_mtx = utility_dstMtx(x,centroids);
        [~,labels_new]=min(dst_mtx,[],2);
        labels_new = labels_new-1;
        
        converged = ~sum(labels_new~=labels);
        labels=labels_new;
    end
    labels = labels+1;
end