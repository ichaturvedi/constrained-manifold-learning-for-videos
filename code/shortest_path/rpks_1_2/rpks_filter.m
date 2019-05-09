function [ filter, path ] = rpks_filter( K, boundaries_id, NC, knn)
%RPKS_FILTER Summary of this function goes here
%   Detailed explanation goes here

%parameters
PENALTY = 10^3;
THRESHOLD = 0.1;

%pick NC medoids with k-means++ 
dst = utility_k_dstMtx(K);
medoids_id = rpks_kpp(dst, NC, boundaries_id);
tmp=medoids_id(2);
medoids_id(2)=medoids_id(NC);
medoids_id(NC)=tmp;

%medoids dst matrix to find shortest path
medoids_dst = dst(medoids_id, :);
medoids_dst = medoids_dst(:,medoids_id);

%sort dst matrix to find nearest-neighbour indices
[medoids_dst_srt, medoids_idx_knn] = sort(medoids_dst,2);

%build a penalized k-nearest-neighbour dst matrix
medoids_dst_penalized = medoids_dst*PENALTY;
medoids_lin_idx_knn = repmat((1:NC)',1,knn)+(medoids_idx_knn(:,1:knn)-1)*NC;
medoids_dst_penalized(medoids_lin_idx_knn) = medoids_dst(medoids_lin_idx_knn);
medoids_lin_idx_knn = repmat((0:NC-1)'*NC,1,knn)+(medoids_idx_knn(:,1:knn));
medoids_dst_penalized(medoids_lin_idx_knn) = medoids_dst(medoids_lin_idx_knn);

%avoid short circuit on boundary conditions
medoids_dst_penalized(1,NC)=0;
medoids_dst_penalized(NC,1)=0;

%find shortest path on the penalized k-nearest-neighbour dst matrix
medoids_id_path=shortestpath(graph(sqrt(medoids_dst_penalized)),1,NC);

NC_set=[];
for i=medoids_id_path
    knn_filter = find(medoids_dst_srt(i,:)>THRESHOLD*mean(mean(medoids_dst)),1);
    NC_set=[NC_set medoids_idx_knn(i,~ismember(medoids_idx_knn(i,1:knn_filter),medoids_id_path))];
end
NC_set = unique(NC_set);

medoids_mask = ~ismember(1:NC,NC_set);
new_medoids_id_path = utility_maskIdxConversion(medoids_mask,medoids_id_path);
medoids_id(NC_set)=[];

[~,labels]=min(dst(:,medoids_id),[],2);
filter = ismember(labels,new_medoids_id_path);
path = medoids_id(new_medoids_id_path);

end

