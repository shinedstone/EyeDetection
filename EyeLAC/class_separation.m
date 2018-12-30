function [sorted_data,class_index] = class_separation(data,class,class_label,N_class)

[N_data,N_f]=size(data);
for i=1:N_class
    eval(['class' num2str(class_label(i)) ' = zeros(1,N_f);']);
end
for i=1:N_data
    eval(['class' num2str(class(i)) ' = [ class' num2str(class(i)) ' ; data(i,:) ];' ]);
end
for i=1:N_class
    eval(['class' num2str(class_label(i)) ' = class' num2str(class_label(i)) '(2:end,:);']);
end

%sorted_data = zeros(1,N_f);
sorted_data = [];
for i=1:N_class
    eval(['sorted_data = [ sorted_data ; class' num2str(class_label(i)) ' ];']);
end
%sorted_data = sorted_data(2:end,:);

class_index = zeros(N_class,2);
start = 1;
for i=1:N_class
    eval(['[N_sam,N_f] = size(class' num2str(class_label(i)) ');']);
    last = start + N_sam - 1;
    class_index(i,1) = start;
    class_index(i,2) = last;
    start = last + 1;
end