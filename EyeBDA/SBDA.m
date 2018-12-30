function [W, w_2,mean_positive, position, D_BDA] = SBDA(positive,negative,alpha)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Biased Discriminant Analysis
% if BDA_flag = 1 ; normal BDA
% if BDA_flag = 2 ; projection to range and null space of Sw
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[N_positive,N_f]=size(positive);
[N_negative,N_f]=size(negative);

%% With-in Covariance Matrix, Sw
mean_positive = mean(positive);
Sw_temp = zeros(N_f,N_f);
for i=1:N_positive
    positive_temp(i,:) = positive(i,:) - mean_positive;
    Sw_temp = Sw_temp + positive_temp(i,:)' * positive_temp(i,:);
end
Sw = Sw_temp / N_positive;
Sw = Sw + 0.01*eye(N_f);
%Sw = Sw_temp;
%Sw_r = trace(Sw)*eye(N_f)/N_f;
%mu = 0.1;
%Sw = Sw*(1-mu) + Sw_r*mu;
%Sw = positive_temp' * positive_temp;
%Sw = Sw_temp / N_positive;
%Sw = Sw_temp;

%% Whitening (Sphering) Sw
[V_sorted,D_sorted]=diagonal(Sw);
m = rank(Sw);

D_invroot = zeros(m,m);
for i=1:m
    D_invroot(i,i) = sqrt(1/D_sorted(i));
end
    
w_1 = V_sorted(:,1:m) * D_invroot; % inclusion of range (sphering)
w_1 = [w_1, V_sorted(:,m+1:N_f)]; % inclusion of null space
%w_1 = V_sorted(:,m+1:N_f);
    
Sw_1 = w_1' * Sw * w_1;

%% Projection of negative to w_1
negative = negative - ones(N_negative,1)*mean_positive;
negative = negative * w_1; % now negative = N_negative * m

%alpha = 10;
beta = 0;

for i=1:N_negative
    distance(i) = 0;
    for j=1:N_f
        distance(i) = distance(i) + negative(i,j)^2;
    end
    distance(i) = sqrt(distance(i));
%     if distance(i) > alpha
%         negative(i,:) = (alpha / distance(i)) * negative(i,:);
%     end
end

%% Between Covariance Matrix, Sb
Sb_temp = zeros(N_f,N_f);
position = [];
for i=1:N_negative
    if distance(i) > alpha
        position = [ position ; i ];
        temp = (alpha / distance(i)) * negative(i,:);
        Sb_temp = Sb_temp + temp' * temp;
    else
        if distance(i) < beta
            temp = 10*(beta / distance(i)) * negative(i,:);
            Sb_temp = Sb_temp - temp' * temp;
        else
            Sb_temp = Sb_temp + negative(i,:)' * negative(i,:);
        end
    end
end    

Sb = Sb_temp / N_negative;

[Q_BDA,D_BDA]=diagonal(Sb);
%[Q_BDA,D_BDA]=diagonal(Sb);
%display(D_BDA);
w_2 = Q_BDA;    

W = w_1*w_2;

