function [N_class,class_label,N_class_sample]=class_information(class)

N_data = length(class);
N_class = 1;
class_label = class(1);
for i=2:N_data
    flag = 0;
    for j=1:length(class_label)
        if class(i) == class_label(j)
            flag = 1;
        end
    end
    if flag == 0
        N_class = N_class + 1;
        class_label = [class_label class(i)];
    end
end
class_label = sort(class_label)';

N_class_sample = zeros(N_class,1);
for i=1:N_data
    temp = class(i);
    index = 1;
    flag = 0;
    while flag == 0
        if class_label(index) == temp
            flag = 1;
        else
            index = index + 1;
        end
    end
    N_class_sample(index) = N_class_sample(index) + 1;
end
        
    
    
