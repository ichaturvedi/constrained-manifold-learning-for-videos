function [ score ] = linearScore( X, centroids)
%LINEARSCORE Summary of this function goes here
%   Detailed explanation goes here
    N = size(X,1);
    NC = size(centroids,1);
    
    KX = X*X';
    KW = centroids*centroids';
    KXW = X*centroids';

    %line-point distance
    a2 = repmat(diag(KX),1,NC-1) + repmat(diag(KW(1:NC-1,1:NC-1))',N,1) - 2*KXW(:,1:NC-1);
    b2 = diag(KW(1:NC-1,1:NC-1))' + diag(KW(2:NC,2:NC))' - 2 * diag(KW,1)';
    ab = KXW(:,2:NC) - KXW(:,1:NC-1) + repmat(diag(KW(1:NC-1,1:NC-1))',N,1) - repmat(diag(KW,1)',N,1);
    
    %projection mask
    p = ab >= 0 & ab <= repmat(b2,N,1);
    mask = max(p,[],2);
    p = double(p);
    p(p==0) = Inf;
    
    d2 = abs(a2 - ab.*ab ./ repmat(b2,N,1));
    [d2_line,~] = min(d2.*p,[],2);
    [d2_point,~] = min(utility_dstMtx(X,centroids),[],2);
    
    score = sum(d2_line(mask))+sum(d2_point(~mask));
end