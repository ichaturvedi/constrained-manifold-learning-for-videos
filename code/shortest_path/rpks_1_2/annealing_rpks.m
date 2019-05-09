
function [ mask, solutions_medoid, solutions_NC, evidence, kseg_score ] = annealing_rpks( k_mtx, boundaries_id, NC, s ) 
    %RPKS Regularized Path in Kernel Space
    %   [ mask, solutions_medoid, solutions_NC, evidence, kseg_score ] = annealing_rpks( k_mtx, boundaries_id, NC, s )
    %
    %   Finds a set of paths connecting boundaries_id(1) to boundaries_id(2)
    %   optimizing a regularized k-means cost function with an EM-like
    %   procedure.
    %   
    %   The initial and final centroids are kept fixed, thus optimizing the cost
    %   on the remaining NC-2 centroids.
    %
    %   INPUT:
    %
    %   k_mtx: Kernel matrix representing the dataset. (NxN)
    %
    %   boundaries_id: id of the initial and final medoid (1x2)
    %
    %   s: values for the regularization parameter. (1xM) In an annealing-like fashion the
    %   algorithm will start from s(1) and will iterate to s(M) and each iteration
    %   use the result coming from the previous one as initialization.
    %
    %   OUTPUT:
    %
    %   mask: filter mask. (1 x N) (the algorithm prefilter the dataset euristically
    %   to focus on the manifold connecting the first and the last medoids).
    %
    %   solutions_medoid: set of paths. (M x NC ) Each path is represented by an ordered
    %   array of medoid indices.
    %
    %   solutions_NC: array containg the actual number of clusters for each
    %   path. (1 x M) In kernel space some clusters might become empty
    %   during the iterations of the algorithms therefore they have to be
    %   removed.
    %   
    %   evidence: evidence curve useful in MS phase. (1xM)
    %
    %   kseg_score: k-segment score useful in MS phase. (1xM) 

    %filter dataset according to boundaries
    [mask,init_path] = rpks_filter(k_mtx, boundaries_id,200, 5);
    boundaries_id = utility_maskIdxConversion(mask, boundaries_id);
    init_path = utility_maskIdxConversion(mask, init_path);
    
    %compute kernel and distance matrices
    k_mtx = k_mtx(mask,:);
    k_mtx = k_mtx(:,mask);
    dst_mtx = utility_k_dstMtx(k_mtx);
    N=size(k_mtx,1);

    %prepare arrys for solutions
    evidence = zeros(1,length(s));
    kseg_score = zeros(1,length(s));
    solutions_medoid = zeros(length(s),NC);
    solutions_NC = zeros(length(s));
    %run standard k-means (needed for the evidence evaluation)
    for i=1:10
        init_medoids_id = rpksInitMedoids('kpp',k_mtx,boundaries_id,NC);
        [~,~,cost]=rpks(k_mtx, init_medoids_id, 0);
        if(i==1 || cost(end)<costKMP)
            costKMP = cost(length(cost));
        end
    end
    
    %run the regularized path in linear space algorithm
    init_medoids_id = rpksInitMedoids('kpp',k_mtx,boundaries_id,NC);
    init_medoids_id = rpksInitPath('projection',k_mtx,init_medoids_id);
    
    for i=1:length(s)
        %run the algorithm and save the centroids
        [medoids_id,labels,cost]=rpks(k_mtx, init_medoids_id, s(i));
        init_medoids_id = medoids_id;
        
        solutions_NC(i) = length(medoids_id);
        solutions_medoid(i,1:solutions_NC(i)) = medoids_id;

        %compute the evidence for a given s and various gamma
        gamma = 2/mean(mean(dst_mtx));
        costMP = cost(end);
        card=zeros(NC-2,1);
        for m=2:NC-1
            card(m-1) = sum(labels==m);
        end
        [~,ev] = kernelevidence(s(i), gamma, k_mtx, card, costMP, costKMP, boundaries_id);
        evidence(i) = ev;

        %compute k-segments score for a given s
        kseg_score(i) = kernelScore(k_mtx,medoids_id);
    end
end

