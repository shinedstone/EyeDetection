function [Vectors,Values] = diagonal(M);
%% Matrix M is n by n square matrix
[n,n]=size(M);
m = rank(M);

[V,D]=eig(M);

for i=1:n
    d_1D(i) = D(i,i);
end

[Values_sorted,index]=sort(d_1D);

for i=1:n
    Vectors(:,i) = V(:,index(n-i+1));
    Values(i) = d_1D(index(n-i+1));
end