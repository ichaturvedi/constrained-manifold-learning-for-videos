function [ medoids_id ] = rpksInitMedoids( init_type, k_mtx, boundaries_id, NC )
%RPKSINITMEDOIDS 
%   [ medoids_id ] = RPKSINITMEDOIDS( init_type, k_mtx, boundaries_id, NC )
%
%   Picks NC-2 medoids from the dataset with a given algorithm. It returns 
%   a vector of NC medoids indices adding the initial and final 
%   medoids contained in boundaries_id.
%
%   INPUT:
%
%   init_type:
%       'random': pick NC-2 random medoids;
%       'kpp': pick NC-2 medoids according to kernel k-means++ algorithm.
%
%   k_mtx: kernel matrix. (NxN)
%
%   boundaries_id: initial and final medoids indices. (1x2, values in
%   [1,N])
%
%   NC: number of medoids including the initial and final one. (values > 2) 
%
%   OUTPUT:
%
%   medoids_id: set of medoids indices. (1xNC)

    N=length(k_mtx);
    switch(init_type)
        case 'random'
            available_id = 1:N;
            available_id(boundaries_id) = [];
            
            medoids_id=available_id(randperm(N-2));
        	medoids_id=medoids_id(1:NC-2);
            
            medoids_id = [boundaries_id(1), medoids_id, boundaries_id(2)];
        case 'kpp'
            k_dst_mtx = utility_k_dstMtx(k_mtx); 
            medoids_id=boundaries_id;
            for i=1:NC-2
                accepted=0;
                available_id = 1:N;
                available_id(medoids_id) = [];
                [medoids_dst,~] = min(k_dst_mtx(:,medoids_id),[],2);
                cnt = 0;
                while(~accepted && cnt<50)
                    cnt = cnt + 1;
                    medoids_id(i+2) = available_id(randi(length(available_id)));
                    if(rand(1)<medoids_dst(medoids_id(i+2))/sum(medoids_dst))
                        accepted=1;
                    end
                end
            end
            tmp = medoids_id(NC);
            medoids_id(NC) = medoids_id(2);
            medoids_id(2) = tmp;
        otherwise
            error('RPKSINITMEDOIDS: unknown medoids initialization type.');
    end
end