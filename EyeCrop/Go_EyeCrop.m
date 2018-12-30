clear all;
close all;
clc;

RstImg_folder_Tr = 'Images_Training';
RstImg_folder_Val = 'Images_Validation';

imgin_ftype = 'bmp';
imgout_ftype = 'png';

NonEyeImg_folder_Tr = 'EyePatchTr';
NonEyeImg_folder_Val = 'EyePatchVal';

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
    Distance = norm(coord_vec(4:5) - coord_vec(6:7));
    lengh = round(Distance * 0.5);
    
    img_file = sprintf('%s/%s_reye.%s', RstImg_folder_Tr, eye_name, imgin_ftype);
    img = imread(img_file, imgin_ftype);
    
    %image out
    imgr_temp = img(coord_vec(4)-lengh:coord_vec(4)+lengh, coord_vec(5)-lengh:coord_vec(5)+lengh);
    imgr_temp = imresize(imgr_temp,[18 18]);
    reye_file = sprintf('%s/%s_eyer.%s', NonEyeImg_folder_Tr, eye_name, imgout_ftype);
    imwrite(imgr_temp, reye_file, imgout_ftype);
    imgl_temp = img(coord_vec(6)-lengh:coord_vec(6)+lengh, coord_vec(7)-lengh:coord_vec(7)+lengh);
    imgl_temp = imresize(imgl_temp,[18 18]);
    leye_file = sprintf('%s/%s_eyel.%s', NonEyeImg_folder_Tr, eye_name, imgout_ftype);
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
    Distance = norm(coord_vec(4:5) - coord_vec(6:7));
    lengh = round(Distance * 0.6);
    
    img_file = sprintf('%s/%s_reye.%s', RstImg_folder_Val, eye_name, imgin_ftype);
    img = imread(img_file, imgin_ftype);
    
    %image out
    imgr_temp = img(coord_vec(4)-lengh:coord_vec(4)+lengh, coord_vec(5)-lengh:coord_vec(5)+lengh);
    imgr_temp = imresize(imgr_temp,[18 18]);
    reye_file = sprintf('%s/%s_eyer.%s', NonEyeImg_folder_Val, eye_name, imgout_ftype);
    imwrite(imgr_temp, reye_file, imgout_ftype);
    imgl_temp = img(coord_vec(6)-lengh:coord_vec(6)+lengh, coord_vec(7)-lengh:coord_vec(7)+lengh);
    imgl_temp = imresize(imgl_temp,[18 18]);
    leye_file = sprintf('%s/%s_eyel.%s', NonEyeImg_folder_Val, eye_name, imgout_ftype);
    imwrite(imgl_temp, leye_file, imgout_ftype);
end

fclose(fid_out_Tr);
fclose(fid_out_Val);