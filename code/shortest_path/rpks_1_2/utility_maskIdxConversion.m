function [ new_idx ] = utility_maskIdxConversion( mask, idx )
%UTILITY_MASKIDXCONVERSION Summary of this function goes here
%   Detailed explanation goes here
    new_idx = zeros(size(idx));
    for i=1:length(idx)
        new_idx(i) = sum(mask(1:idx(i)));
    end
end

