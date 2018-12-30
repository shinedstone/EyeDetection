function [W,Eigvalues,FlagRank] = LDA(train_data,train_class,R_flag)

[N_train,N_att] = size(train_data);
[N_class,class_label,N_class_sample]=class_information(train_class);
[sorted_train,class_index] = class_separation(train_data,train_class,class_label,N_class);
% N_train=data 갯수, N_att=data 차원
% N_class=class 갯수, class_label=class 이름, N_class_sample=class당 date 갯수
% sorted_train=sorted data, class_index=각 class의 시작과 끝 숫자
Sw_temp = zeros(N_att,N_att);
mean_matrix = zeros(N_class,N_att);
for i=1:N_class
    start = class_index(i,1);
    last = class_index(i,2);
    sum = zeros(1,N_att);
    for j=start:last
        sum = sum + sorted_train(j,:);
    end
    mean_matrix(i,:) = sum / (last-start+1);
    
    temp = zeros(N_att,N_att);
    for j=1:N_class_sample(i)
        mat = sorted_train(start+j-1,:) - mean_matrix(i,:);
        temp = temp + mat' * mat;
    end
    Sw_temp = Sw_temp + temp;
end
Sw = Sw_temp / N_train;

RankSw = rank(Sw);
[N_row,N_col] = size(Sw);
display(['The rank of Sw (' num2str(N_row) 'x' num2str(N_col) ') = ' num2str(rank(Sw)) ]);
if (R_flag == 1) 
    alpha = 0.01;
    Sw = Sw + alpha * eye(N_att);
end

sum = zeros(1,N_att);
for i=1:N_train
    sum = sum + train_data(i,:);
end
mean_total = sum / N_train;
    
Sb = zeros(N_att,N_att);
for i=1:N_class
    mat = mean_matrix(i,:) - mean_total;
    Sb = Sb + N_class_sample(i) * mat' * mat;
end
Sb = Sb / N_train;
display(['The rank of Sb = ' num2str(rank(Sb)) ]);
RankSb = rank(Sb);

if RankSb ~= (N_class-1) || RankSw ~= N_att
    FlagRank = 0;
    W = [];
    Eigvalues = [];
else    
    [vectors,values] = diagonal(Sw);
    for i=1:N_att
        vectors(:,i) = vectors(:,i) / sqrt(values(i));
    end
    w1 = vectors;
    
    Sb_temp = w1' * Sb * w1;
    
    [vectors,values] = diagonal(Sb_temp);
    w2 = vectors(:,1:RankSb);
    W = w1 * w2;
    Eigvalues = values(1:RankSb);
    FlagRank = 1;
end

