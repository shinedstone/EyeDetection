function results = Gaussian_window(vector,K,h)
%
% Gaussian Window Function
% PDF estimation¿¡ »ç¿ë
% 
% vector : a row vector
% K : covariance matrix
% h : a window width parameter

[N_f,N_f]=size(K);
results = 1/( (2*pi)^(N_f/2) * h^N_f * sqrt(det(K)) ) * exp( -1*vector*inv(K)*vector' / (2*h^2) );
