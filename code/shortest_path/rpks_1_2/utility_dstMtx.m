function [ dst_mtx ] = utility_dstMtx( X, Y )
    N = size(X,1);
    M = size(Y,1);
    
    dst_mtx =  repmat(diag(X*X'),1,M);
    dst_mtx = dst_mtx + repmat(diag(Y*Y')',N,1);
    dst_mtx = dst_mtx - 2*X*Y';
end