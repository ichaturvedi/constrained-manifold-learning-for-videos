function [ medoids_id ] = rpks_kpp( dst, NC, pre_medoids_id )
%RPKS_KPP Summary of this function goes here
%   Detailed explanation goes here

N = length(dst);
medoids_id=pre_medoids_id;

for i=1:NC-length(pre_medoids_id)
    available_id = 1:N;
    available_id(medoids_id) = [];
    
    [medoids_dst,~] = min(dst(:,medoids_id),[],2);
    
    accepted=0;
    while(~accepted)
        medoids_id(i+2) = available_id(randi(length(available_id)));
        if(rand(1)<medoids_dst(medoids_id(i+2))/sum(medoids_dst))
            accepted=1;
        end
    end
end
end

