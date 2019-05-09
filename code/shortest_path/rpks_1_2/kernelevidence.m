function [ lambda, ev ] = evidence( s, gamma, K, card, costMP, costKMP, boundaries_id )
%EVIDENCE Summary of this function goes here
%   Detailed explanation goes here

N = length(K);
NC = length(card);
lambda = s*gamma;

alpha_b = zeros(N,2);
alpha_b(boundaries_id(1),1) = 1;
alpha_b(boundaries_id(2),2) = 1;

%full hessian matrix around MP solution
hMP = diag(card) + s * toeplitz([1 -0.5 zeros(1,NC-2)]);

%linear term
c=zeros(NC);
for i=1:NC
    for j=i:NC
        i_=i-1;
        j_=j-1;
        c(i,j) = 1/(1-0.5*i_/(i_+1)-0.5*(NC-1-i_)/(NC-i_)) * (NC-j_)/(NC-i_);
    end
end
lin_term = c(1,1) * alpha_b(:,1)' * K * alpha_b(:,1);
lin_term = lin_term + c(1,NC) * alpha_b(:,1)' * K * alpha_b(:,2);
lin_term = lin_term + c(1,NC) * alpha_b(:,2)' * K * alpha_b(:,1);
lin_term = lin_term + c(NC,NC) * alpha_b(:,2)' * K * alpha_b(:,2);

%constant term
cns_term = alpha_b(:,1)' * K * alpha_b(:,1) + alpha_b(:,2)' * K * alpha_b(:,2);

%estimate dimensionality
e = eig(K);
e = sort(e,1,'descend');
pv=zeros(N,1);
for i=1:length(e)
    pv(i)=sum(e(1:i));
end
pv=pv/sum(e);
d = find(pv>0.99,1);

ev = - d*0.5*log(det(hMP)) - gamma*costMP + gamma*costKMP + 0.5*d*NC*log(lambda) - 0.125 * lambda * lin_term + 0.25 * lambda * cns_term;  
end

