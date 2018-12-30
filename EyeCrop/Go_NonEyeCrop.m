clear all;
close all;
clc;

RstImg_folder_Tr = 'Images_Training';
RstImg_folder_Val = 'Images_Validation';

imgin_ftype = 'bmp';
imgout_ftype = 'png';

NonEyeImg_folder_Tr = 'NonEyePatchTr';
NonEyeImg_folder_Val = 'NonEyePatchVal';

fid_out_Tr = fopen('Eye_Coord_Tr.txt','r');
fid_out_Val = fopen('Eye_Coord_Val.txt','r');

for i = 1 : 1400,
    cur_string = fgetl(fid_out_Tr);
    blank_pos = 1;
    for j=1:length(cur_string),
        if cur_string(j) == ' ',
            blank_pos = j;
            break;
        end
    end
    cur_idx = cur_string(1:blank_pos-1);
    coord_vec = str2num(cur_string(blank_pos+1:end));
    eye_idx = coord_vec(1);
    eye_name = sprintf('%s_f%d', cur_idx, eye_idx);
    Img_Size = coord_vec(2:3);
    Eye_Coord_orig = coord_vec(4:7);
    Eye_Coord_diff = coord_vec(4:5) - coord_vec(6:7);
    Distance = norm(coord_vec(4:5) - coord_vec(6:7));
    
    flag = 0;
    Center_Right = zeros(1,2);
    Center_Left = zeros(1,2);
    while flag == 0
        Center_Right = [ round(coord_vec(2)*rand), round(coord_vec(3)*rand/2) ];
        if ((Center_Right(1)-8)>=1) && ((Center_Right(1)+9)<=coord_vec(2)) && ((Center_Right(2)-8)>=1)
            Center_Left = Center_Right + Eye_Coord_diff;
            Error1 = norm(Center_Right - coord_vec(4:5));
            Error2 = norm(Center_Left - coord_vec(6:7));
            Normalized_Error = max( Error1, Error2 ) / Distance;
            if (Normalized_Error > 0.5) && ((Center_Left(1)-8)>=1) && ((Center_Left(1)+9)<=coord_vec(2)) && ((Center_Left(2)+9)<=coord_vec(3))
                flag = 1 ;
            end
        end
    end
    
    img_file = sprintf('%s/%s_reye.%s', RstImg_folder_Tr, eye_name, imgin_ftype);
    img = imread(img_file, imgin_ftype);
    
    %image out
    imgr_temp = img(Center_Right(1)-8:Center_Right(1)+9, Center_Right(2)-8:Center_Right(2)+9);
    reye_file = sprintf('%s/%s_noneyer.%s', NonEyeImg_folder_Tr, eye_name, imgout_ftype);
    imwrite(imgr_temp, reye_file, imgout_ftype);
    imgl_temp = img(Center_Left(1)-8:Center_Left(1)+9, Center_Left(2)-8:Center_Left(2)+9);
    leye_file = sprintf('%s/%s_noneyel.%s', NonEyeImg_folder_Tr, eye_name, imgout_ftype);
    imwrite(imgl_temp, leye_file, imgout_ftype);
end

for i = 1 : 700,
    cur_string = fgetl(fid_out_Val);
    blank_pos = 1;
    for j=1:length(cur_string),
        if cur_string(j) == ' ',
            blank_pos = j;
            break;
        end
    end
    cur_idx = cur_string(1:blank_pos-1);
    coord_vec = str2num(cur_string(blank_pos+1:end));
    eye_idx = coord_vec(1);
    eye_name = sprintf('%s_f%d', cur_idx, eye_idx);
    Img_Size = coord_vec(2:3);
    Eye_Coord_orig = coord_vec(4:7);
    Eye_Coord_diff = coord_vec(4:5) - coord_vec(6:7);
    Distance = norm(coord_vec(4:5) - coord_vec(6:7));
    
    flag = 0;
    Center_Right = zeros(1,2);
    Center_Left = zeros(1,2);
    while flag == 0
        Center_Right = [ round(coord_vec(2)*rand), round(coord_vec(3)*rand/2) ];
        if ((Center_Right(1)-8)>=1) && ((Center_Right(1)+9)<=coord_vec(2)) && ((Center_Right(2)-8)>=1)
            Center_Left = Center_Right + Eye_Coord_diff;
            Error1 = norm(Center_Right - coord_vec(4:5));
            Error2 = norm(Center_Left - coord_vec(6:7));
            Normalized_Error = max( Error1, Error2 ) / Distance;
            if (Normalized_Error > 0.5) && ((Center_Left(1)-8)>=1) && ((Center_Left(1)+9)<=coord_vec(2)) && ((Center_Left(2)+9)<=coord_vec(3))
                flag = 1 ;
            end
        end
    end
    
    img_file = sprintf('%s/%s_reye.%s', RstImg_folder_Val, eye_name, imgin_ftype);
    img = imread(img_file, imgin_ftype);
    
    %image out
    imgr_temp = img(Center_Right(1)-8:Center_Right(1)+9, Center_Right(2)-8:Center_Right(2)+9);
    reye_file = sprintf('%s/%s_noneyer.%s', NonEyeImg_folder_Val, eye_name, imgout_ftype);
    imwrite(imgr_temp, reye_file, imgout_ftype);
    imgl_temp = img(Center_Left(1)-8:Center_Left(1)+9, Center_Left(2)-8:Center_Left(2)+9);
    leye_file = sprintf('%s/%s_noneyel.%s', NonEyeImg_folder_Val, eye_name, imgout_ftype);
    imwrite(imgl_temp, leye_file, imgout_ftype);
end

fclose(fid_out_Tr);
fclose(fid_out_Val);