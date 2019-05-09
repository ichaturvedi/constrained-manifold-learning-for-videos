function [ X, X_garbage, solutions, evidence, kseg_score ] = annealing_rpls( X, boundaries_id, NC, s ) 
%RPLS Regularized Path in Linear Space
%   [ X, X_garbage, solutions, evidence, kseg_score ] = annealing_rpls( X, boundaries_id, NC, s )
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
%   X: dataset. (NxD)
%
%   boundaries_id: id of the initial and final medoid (1x2)
%
%   s: values for the regularization parameter. (1xM) In an annealing-like fashion the
%   algorithm will start from s(1) and will iterate to s(M) and each iteration
%   use the result coming from the previous one as initialization.
%
%   OUTPUT:
%
%   X: filtered dataset (the algorithm prefilter the dataset euristically
%   to focus on the manifold connecting the first and the last medoids).
%
%   X_garbage: held out portion of the dataset.
%
%   solutions: set of paths. (M x NC x D) Each path is represented by an ordered
%   array of centroids.
%
%   evidence: evidence curve useful in MS phase. (1xM)
%
%   kseg_score: k-segment score useful in MS phase. (1xM) 

    %filter dataset according to boundaries
    k_mtx = X*X';
    [mask,init_path] = rpks_filter(k_mtx, boundaries_id,200, 5);
    boundaries_id = utility_maskIdxConversion(mask, boundaries_id);
    init_path = utility_maskIdxConversion(mask, init_path);
    X_garbage = X(~mask,:);
    X = X(mask,:);

    N=size(X,1);
    D=size(X,2);
    
    %compute kernel and distance matrices
    k_mtx = X*X';
    dst_mtx = utility_k_dstMtx(k_mtx);
    
    %prepare arrys for solutions
    evidence = zeros(1,length(s));
    kseg_score = zeros(1,length(s));
    solutions = zeros(length(s),NC,D);

    %run standard k-means (needed for the evidence evaluation)
    for i=1:10
        init_medoids_id = rpksInitMedoids('kpp',k_mtx,boundaries_id,NC);
        init_centroids = X(init_medoids_id,:);
        [~,~,cost]=rpls(X, init_centroids, 0);
        if(i==1 || cost(end)<costKMP)
            costKMP = cost(length(cost));
        end
    end

    %run the regularized path in linear space algorithm
    init_medoids_id = rpksInitMedoids('kpp',k_mtx,boundaries_id,NC);
    init_medoids_id = rpksInitPath('projection',k_mtx,init_medoids_id);
    init_centroids = X(init_medoids_id,:);
    for i=1:length(s)
        %run the algorithm and save the centroids
        [centroids,labels,cost]=rpls(X, init_centroids, s(i));
        init_centroids = centroids;
        solutions(i,:,:) = centroids;

        %compute the evidence for a given s and various gamma
        gamma = 2/mean(mean(dst_mtx));
        costMP = cost(end);
        boundaries = init_centroids([1,NC],:);
        boundaries = [boundaries(1,:); zeros(NC-4,D); boundaries(2,:)];
        card=zeros(NC-2,1);
        for m=2:NC-1
            card(m-1) = sum(labels==m);
        end
        [~,ev] = linearevidence(s(i), gamma, D, card, costMP, costKMP, boundaries);
        evidence(i) = ev;

        %compute k-segments score for a given s
        kseg_score(i) = linearScore(X,centroids);
    end
end

