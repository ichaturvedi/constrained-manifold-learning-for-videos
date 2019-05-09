function [ dst_mtx ] = utility_k_dstMtx( k_mtx )
    N = size(k_mtx,1);
    
    dst_mtx = repmat(diag(k_mtx),1,N);
    dst_mtx = dst_mtx + repmat(diag(k_mtx)',N,1);
    dst_mtx = dst_mtx - 2*k_mtx;
end