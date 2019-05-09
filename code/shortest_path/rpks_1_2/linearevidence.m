function [ lambda, ev ] = linearevidence( s, gamma, d, card, costMP, costKMP, boundaries )
%EVIDENCE Summary of this function goes here
%   Detailed explanation goes here

NC = length(card);
lambda = s*gamma;

%regularizer hessian matrix
hReg = toeplitz([1 -0.5 zeros(1,NC-2)]);

%full hessian matrix around MP solution
hMP = diag(card) + s * toeplitz([1 -0.5 zeros(1,NC-2)]);

ev = - d*0.5*log(det(hMP)) - gamma*costMP + gamma*costKMP + 0.5*d*NC*log(lambda) - 0.125 * lambda * trace(boundaries' * pinv(hReg) * boundaries) + 0.25 * lambda * trace(boundaries'*boundaries);  
end

