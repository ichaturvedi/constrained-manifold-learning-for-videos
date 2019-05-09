function [ medoids_id, labels, global_cost] = rpks( k_mtx, init_medoids_id, s)
%RPKS Regularized Path in Kernel Space
%   [ medoids_id, labels, global_cost] = RPKS( k_mtx, init_medoids_id, s)
%
%   Finds a path connecting init_medoids_id(1) to init_medoids_id(NC)
%   optimizing a regularized k-means cost function with an EM-like
%   procedure in kernel space.
%   
%   The initial and final medoids are kept fixed, thus optimizing the cost
%   on the remaining NC-2 medoids.
%
%   INPUT:
%
%   k_mtx: kernel matrix. (NxN)
%
%   init_medoids_id: initial set of medoids indices ordered according to
%   the topology. (1xNC)
%
%   s: regularization parameter.
%
%   OUTPUT:
%
%   medoids_id: final set of medoids indices. (1xNC)
%
%   labels: final set of labels. (1xN, values [1,NC])
%
%   global_cost: value of the cost function at each iteration. 

    N = length(k_mtx);
    NC = length(init_medoids_id);
    
    %initialize labels
    k_dst_mtx = utility_k_dstMtx(k_mtx);
    [~,labels]=min(k_dst_mtx(:,init_medoids_id),[],2);

    %separate movable medoids from boundaries
    boundaries_id = init_medoids_id([1,NC]);
    medoids_id = init_medoids_id(2:NC-1);
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
        while(i<NC+1)
            if(sum(labels==i)>0)
                card(i)=sum(labels==i);
                i = i+1;
            else
                warning('RPKS: warning, empty cluster removed.');
                labels(labels>i)=labels(labels>i)-1;
                NC = NC-1;
            end
        end
        
        %set up the hessian matrix and compute the pseudo-inverse 
        A = zeros(1,NC);
        if(NC>1)
            A(1:2)=[1 -0.5*s];
            A = toeplitz(A);
        end
        for i=1:NC
            A(i,i) = s+card(i);
        end
        inv_A = pinv(A);
        
        %compute kernel summations
        g=zeros(NC);
        mixed=zeros(NC,1);
        
        for i=1:NC
            for j=1:NC
                g(i,j)=sum(sum(k_mtx(labels==i,labels==j)));
                if i==1 || i==NC
                    l=floor(i/NC)+1;
                    g(i,j) = g(i,j) + 0.5*s*sum(k_mtx(boundaries_id(l),labels==j));    
                end
                if j==1 || j==NC
                     l=floor(j/NC)+1;
                     g(i,j) = g(i,j) + 0.5*s*sum(k_mtx(boundaries_id(l),labels==i));
                end
                if (i==1 || i==NC) && (j==1 || j==NC)
                    l=floor(i/NC)+1;
                    m=floor(j/NC)+1;
                    g(i,j) = g(i,j) + 0.25*s^2*k_mtx(boundaries_id(l),boundaries_id(m));
                end
            end
        end

        for j=1:NC
            for l=1:NC
                for m=1:NC
                    mixed(j) = mixed(j) + inv_A(j,l) * inv_A(j,m) * g(l,m);
                end
            end
        end
        
        %compute regularization cost
        cost_reg=0;
        for j=1:NC-1
            cost_reg = cost_reg + mixed(j) + mixed(j+1);
            for l=1:NC
                for m=1:NC
                    cost_reg = cost_reg - 2 * inv_A(j,l) * inv_A(j+1,m) * g(l,m);
                end
            end
        end

        cost_reg = cost_reg + k_mtx(boundaries_id(1),boundaries_id(1)) + mixed(1);
        cost_reg = cost_reg + mixed(NC) + k_mtx(boundaries_id(2),boundaries_id(2));
        for l=1:NC
            if l==1 || l==NC
                m=floor(l/NC)+1;
                cost_reg = cost_reg - inv_A(1,l) * s*k_mtx(boundaries_id(1),boundaries_id(m));  
                cost_reg = cost_reg - inv_A(NC,l) * s*k_mtx(boundaries_id(2),boundaries_id(m));    
            end
            cost_reg = cost_reg - 2 * inv_A(1,l) * sum(k_mtx(boundaries_id(1),labels==l));
            cost_reg = cost_reg - 2 * inv_A(NC,l) * sum(k_mtx(boundaries_id(2),labels==l));
        end
        cost_reg = cost_reg*0.25*s;
        
        %update labels
        f=zeros(NC,1);
        medoids_id=zeros(NC,1);
        medoids_dst=zeros(NC,1);
        cost = 0;
        for i=1:N
            for j=1:NC
                f(j) = sum(k_mtx(i,labels==j));
                if(j==1 || j==NC)
                    l=floor(j/NC)+1;
                    f(j) = f(j) + 0.5*s*k_mtx(i,boundaries_id(l));
                end
            end
            f=-2*inv_A*f;
            
            [dst,labels_new(i)] = min([k_dst_mtx(i,boundaries_id(1)); (repmat(k_mtx(i,i),NC,1)+f+mixed); k_dst_mtx(i,boundaries_id(2))]);
            labels_new(i) = labels_new(i)-1;
            if(labels_new(i)>0 && labels_new(i) <NC+1 && (medoids_id(labels_new(i))==0 || dst<medoids_dst(labels_new(i))))
                medoids_id(labels_new(i)) = i;
                medoids_dst(labels_new(i)) = dst;
            end
            
            cost = cost + dst;
        end
        global_cost(iteration) = cost_reg + 0.5*cost;
        converged = ~sum(labels_new~=labels);
        medoids_id = medoids_id(medoids_id>0);
        labels=labels_new;
    end
    
    medoids_id=[boundaries_id(1); medoids_id; boundaries_id(2)];
    labels = labels+1;
end

