function [res,WinInfo] = cropping_resize_noR(data, left_eye, right_eye, crop_size, out_file)


%macros
scale_factor = 2.25;
flag_success = 1;
flag_failure = 0;
%N_Shift = 10;
N_Shift = 0;
%rand_sign = sign(2*rand(1,1) - 1);  %Caution that rand_sign can be zero.
%Noise_Level = 4*rand_sign;
Max_GrayVal = 255;
%Edge_Threshold = 0.02;
%Edge_Threshold = [0.025, 0.05];
%mask_size = 9;
%half_mask = (mask_size-1)/2;
%Threshold = 7;

%read input file
[N_Height, N_Width, N_Color] = size(data);    %N_Height = 768, N_Width = 512, N_Color = 3

%RGB to Gray scale
%gray_data = rgb2gray(data);
gray_data = data;


% %Rotation
% tan_theta = (left_eye(1,2)-right_eye(1,2))/(left_eye(1,1)-right_eye(1,1));
% theta = (180/pi)*atan(tan_theta);
% %rot_data = imrotate(gray_data, theta, 'nearest');
% rot_data = imrotate(gray_data, theta, 'bilinear');
% 
% [rot_height, rot_width] = size(rot_data);
% 
% %fname = sprintf('%s_rot.bmp', out_file);
% %imwrite(rot_data, fname, 'bmp');
% 
% %Crop the image
% if theta > 0,
%    theta_radian = atan(tan_theta);
%    left_eye_new(1,1) = round((left_eye(1,1)+left_eye(1,2)*tan(theta_radian))*cos(theta_radian));
%    left_eye_new(1,2) = round((N_Width-left_eye(1,1))*sin(theta_radian) + (left_eye(1,2)*cos(theta_radian)));
%    right_eye_new(1,1) = round((right_eye(1,1)+right_eye(1,2)*tan(theta_radian))*cos(theta_radian));
%    right_eye_new(1,2) = round((N_Width-right_eye(1,1))*sin(theta_radian) + (right_eye(1,2)*cos(theta_radian)));
% else,
%    theta_radian = -atan(tan_theta);
%    left_eye_new(1,1) = round(N_Height*sin(theta_radian) + (left_eye(1,1)-left_eye(1,2)*tan(theta_radian))*cos(theta_radian));
%    left_eye_new(1,2) = round(left_eye(1,1)*sin(theta_radian) + left_eye(1,2)*cos(theta_radian));
%    right_eye_new(1,1) = round(N_Height*sin(theta_radian) + (right_eye(1,1)-right_eye(1,2)*tan(theta_radian))*cos(theta_radian));
%    right_eye_new(1,2) = round(right_eye(1,1)*sin(theta_radian) + right_eye(1,2)*cos(theta_radian));
% end    

left_eye_new = left_eye;
right_eye_new = right_eye;

center_eye_x = (left_eye_new(1,1) + right_eye_new(1,1)) / 2;
center_eye_y = (left_eye_new(1,2) + right_eye_new(1,2)) / 2;

rect_width = sqrt((left_eye_new(1,1)-right_eye_new(1,1))^2 + (left_eye_new(1,2)-right_eye_new(1,2))^2);
%rect_height = (12/10)*rect_width;
rect_height = rect_width;
size_x = round(scale_factor*rect_width);
size_y = round(scale_factor*rect_height);

start_x = round(center_eye_x - (size_x/2));
%start_y = round(center_eye_y - (size_y/2));
start_y = round(center_eye_y - (0.3*size_y));
end_x = start_x + size_x - 1;
end_y = start_y + size_y - 1;

if start_x-1 >= 1 & start_y-1 >=1 & end_x+1 <= N_Width & end_y+1 <= N_Height
% if (start_x < 1+N_Shift) | (start_y < 1+N_Shift) | (end_x > rot_width-N_Shift) | (end_y > rot_height-N_Shift),
%    if (start_x < 1+N_Shift),
%       disp_out = sprintf('start_x = %d', start_x);
%       display(disp_out);
%    elseif (start_y < 1+N_Shift),
%       disp_out = sprintf('start_y = %d', start_y);
%       display(disp_out);
%    elseif (end_x > rot_width-N_Shift),
%       disp_out = sprintf('end_x = %d', end_x);
%       display(disp_out);
%    elseif (end_y > rot_height-N_Shift),
%       disp_out = sprintf('end_y = %d', end_y);
%       display(disp_out);
%    end
%    res = flag_failure;
%    return;
% end

rot_data = gray_data;
%crop_data(:,:,1) = rot_data((start_y):(end_y), (start_x):(end_x));     %Reference image
%crop_data(:,:,2) = rot_data((start_y-N_Shift):(end_y-N_Shift), (start_x):(end_x)) - 1*Noise_Level;
%crop_data(:,:,3) = rot_data((start_y):(end_y), (start_x-N_Shift):(end_x-N_Shift)) - 2*Noise_Level;
%crop_data(:,:,4) = rot_data((start_y+N_Shift):(end_y+N_Shift), (start_x):(end_x)) + 1*Noise_Level;
%crop_data(:,:,5) = rot_data((start_y):(end_y), (start_x+N_Shift):(end_x+N_Shift)) + 2*Noise_Level;

IndexPatch = 0;
for i=-1:1:1
    for j=-1:1:1
        IndexPatch = IndexPatch + 1;
        crop_data(:,:,IndexPatch) = rot_data((start_y+i):(end_y+i), (start_x+j):(end_x+j));     %Reference image
    end
end
%crop_data(:,:,1) = rot_data((start_y):(end_y), (start_x):(end_x));     %Reference image
%crop_data(:,:,2) = rot_data((start_y):(end_y), (start_x-N_Shift):(end_x-N_Shift));
%crop_data(:,:,3) = rot_data((start_y):(end_y), (start_x+N_Shift):(end_x+N_Shift));

%crop_data(:,:,2) = uint8(double(rot_data((start_y):(end_y), (start_x-N_Shift):(end_x-N_Shift))) - 1*Noise_Level);
%crop_data(:,:,3) = uint8(double(rot_data((start_y):(end_y), (start_x+N_Shift):(end_x+N_Shift))) + 1*Noise_Level);

%Resize the image
[size_y, size_x, N_TotImage] = size(crop_data);    %N_TotImage = 3

for i=1:N_TotImage,
   crop_data_resized(:,:,i) = imresize(crop_data(:,:,i), crop_size, 'bilinear');
   %resized_data_equalized(:,:,i) = histo_equalize(crop_data_resized(:,:,i), Max_GrayVal);    %Histogram Equalization
end

[size_y, size_x, N_TotImage] = size(crop_data_resized);    %size_y = 120, size_x = 100, N_TotImage = 3
% [size_y, size_x, N_TotImage] = size(resized_data_equalized);    %size_y = 120, size_x = 100, N_TotImage = 3

for k=1:N_TotImage,
%   fname = sprintf('%s_crop_%d.bmp', out_file, k);
%   imwrite(crop_data(:,:,k), fname, 'bmp');
%   fname = sprintf('%s_resized_%d.bmp', out_file, k);
%   imwrite(crop_data_resized(:,:,k), fname, 'bmp');
   

   fname = sprintf('%s_%dx%d_%d.bmp', out_file, size_x, size_y, k);
   imwrite(crop_data_resized(:,:,k), fname, 'bmp');
   
   
%    imwrite(resized_data_equalized(:,:,k), fname, 'bmp');
end

    res = flag_success;
    WinInfo = [ start_x start_y end_x end_y ];
else
    res = flag_failure;
    WinInfo = [ 0 0 0 0 ];
end 

% res = flag_success;
%size_downy = size_y/2;
%size_downx = size_x/2;
%for i=1:size_downy,
%   for j=1:size_downx,
%      down_data(i,j) = uint8(round((double(crop_data_resized(2*i-1,2*j-1)) + double(crop_data_resized(2*i-1,2*j)) + double(crop_data_resized(2*i,2*j-1)) + double(crop_data_resized(2*i,2*j))) / 4));
%   end
%end

%make out_file
%fname = sprintf('%s_%dx%d.tif', out_file, size_downx, size_downy);
%imwrite(down_data, fname, 'tiff');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Histogram Equalization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [data_out] = histo_equalize(data_in, Max_GrayVal);

[N_Row, N_Col] = size(data_in);  %data_in : uint8
N_TotPix = N_Row*N_Col;

histo_vec = zeros(1,Max_GrayVal+1);    %Max_GrayVal+1 = 256
for i=1:N_Row,
   for j=1:N_Col,
      histo_vec(double(data_in(i,j))+1) = histo_vec(double(data_in(i,j))+1) + 1;
   end
end

mid_sum = 0;
for i=1:(Max_GrayVal+1),
   prob(i) = histo_vec(i)/N_TotPix;
   mid_sum = mid_sum + prob(i);
   histo_vec_cumulated(i) = mid_sum;
end

for i=1:N_Row,
   for j=1:N_Col,
      data_out(i,j) = uint8(round(histo_vec_cumulated(double(data_in(i,j))+1) * Max_GrayVal));
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Edge discrimination
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [edge_flag] = decide_edge(edge_data, Threshold);

[Mask_Row, Mask_Col] = size(edge_data);

N_One = 0;
for i=1:Mask_Row,
   for j=1:Mask_Col,
      if edge_data(i,j) == 1,
         N_One = N_One + 1;
      end
   end
end

if N_One > Threshold,
   edge_flag = 1;
else,
   edge_flag = 0;
end
