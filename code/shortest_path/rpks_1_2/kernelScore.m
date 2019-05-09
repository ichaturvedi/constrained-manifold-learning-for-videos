function [ score ] = kernelScore( KX, medoids_id)
%LINEARSCORE Summary of this function goes here
%   Detailed explanation goes here
    N = size(KX,1);
    NC = length(medoids_id);
    
    KXW = KX(:,medoids_id);
    KW = KXW(medoids_id,:);

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
    [d2_point,~] = min(repmat(diag(KX),1,NC)+repmat(diag(KW)',N,1)-2*KXW,[],2);
    
    score = sum(d2_line(mask))+sum(d2_point(~mask));
end

