function [ ordered_medoids_id ] = rpksInitPath( init_type, k_mtx, medoids_id )
%RPKSINITPATH 
%   [ ordered_medoids_id ] = RPKSINITPATH( init_type, k_mtx, medoids_id )
%
%   Reorders the set of medoids indices according to a given path finding
%   algorithm.  
%
%   INPUT:
%
%   init_type:
%       'greedy': stupid and greedy shortest-path algorithm starting from
%       medoids_id(1) and ending in medoids_id(NC).
%
%   k_mtx: kernel matrix. (NxN)
%
%   medoids_id: set of medoids indices to be reordered. (1xNC)
%
%   OUTPUT:
%
%   ordered_medoids_id: set of reordered medoids indices. (1xNC)

    NC=length(medoids_id);

    perm=1:NC;
    switch(init_type)
        case 'projection'
            n = k_mtx(medoids_id(1),medoids_id(1))+k_mtx(medoids_id(NC),medoids_id(NC))-2*k_mtx(medoids_id(1),medoids_id(NC));
            p = -k_mtx(medoids_id(2:NC-1),medoids_id(1)) + k_mtx(medoids_id(2:NC-1),medoids_id(NC));
            [~,perm]=sort(p);
            perm = [1;perm+1;NC];
        otherwise
            error('RPKSINITPATH: unknown path initialization type.');
    end
    ordered_medoids_id = medoids_id(perm);
end

