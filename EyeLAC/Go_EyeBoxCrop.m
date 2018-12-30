clear all;
close all;
clc;

RstImg_folder_Tr = 'EyePatchTr';
RstImg_folder_Val = 'EyePatchVal';
imgout_ftype = 'png';
imgin_ftype = 'bmp';
fid_Tr = fopen('Tr_Eye_Coord.dat','r');
fid_Val = fopen('Val_Eye_Coord.dat','r');

folder = 'Images-Training';
Img = dir([folder '\*.bmp']);
nNeg = size(Img,1);

for i = 1 : nNeg
    cur_string = fgetl(fid_Tr);
    coord_vec = str2num(cur_string);
    face_name = Img(i,1).name(1:end-4);
    eye_orig = coord_vec(1:2);
    
    distance = coord_vec(3);
    WinSize = round(distance/2);
    
    %image read
    img_file = sprintf('%s/%s.%s', folder, face_name, imgin_ftype);
    img = imread(img_file, imgin_ftype);
    [img_nrow, img_ncol, n_channel] = size(img);
    if n_channel == 1,
        img_gray = double(img);
    elseif n_channel == 3,
        img_gray = double(rgb2gray(img));
    end
    
    if eye_orig(1) - WinSize <= 1
        WinSize = eye_orig(1) - 2;
    end
    if eye_orig(2) - WinSize <= 1
        WinSize = eye_orig(2) - 2;
    end
    if eye_orig(1) + WinSize >= img_nrow - 1
        WinSize = img_nrow - eye_orig(1) - 2;
    end
    if eye_orig(2) + WinSize >= img_ncol - 1
        WinSize = img_ncol - eye_orig(2) - 2;
    end
    
    %image out
    num = 1;
    for j = -1 : 1
        for k = -1 : 1
            img_temp = img_gray(eye_orig(1)-WinSize+j : eye_orig(1)+WinSize+j , eye_orig(2)-WinSize+k : eye_orig(2)+WinSize+k);
            img_temp = imresize(img_temp,[18 18]);
            eye_file = sprintf('%s/%s_%d.%s', RstImg_folder_Tr, face_name, num, imgout_ftype);
            imwrite(uint8(img_temp), eye_file, imgout_ftype);
            num = num + 1;
        end
    end
end

folder = 'Images-Validation';
Img = dir([folder '\*.bmp']);
nNeg = size(Img,1);

for i = 1 : nNeg
    cur_string = fgetl(fid_Val);
    coord_vec = str2num(cur_string);
    face_name = Img(i,1).name(1:end-4);
    eye_orig = coord_vec(1:2);
    
    distance = coord_vec(3);
    WinSize = round(0.9*distance/2);
    
    %image read
    img_file = sprintf('%s/%s.%s', folder, face_name, imgin_ftype);
    img = imread(img_file, imgin_ftype);
    [img_nrow, img_ncol, n_channel] = size(img);
    if n_channel == 1,
        img_gray = double(img);
    elseif n_channel == 3,
        img_gray = double(rgb2gray(img));
    end
    
    if eye_orig(1) - WinSize <= 1
        WinSize = eye_orig(1) - 2;
    end
    if eye_orig(2) - WinSize <= 1
        WinSize = eye_orig(2) - 2;
    end
    if eye_orig(1) + WinSize >= img_nrow -1
        WinSize = img_nrow - eye_orig(1) - 2;
    end
    if eye_orig(2) + WinSize >= img_ncol -1
        WinSize = img_ncol - eye_orig(2) - 2;
    end
    
    %image out
    num = 1;
    for j = -1 : 1
        for k = -1 : 1
            img_temp = img_gray(eye_orig(1)-WinSize+j : eye_orig(1)+WinSize+j , eye_orig(2)-WinSize+k : eye_orig(2)+WinSize+k);
            img_temp = imresize(img_temp,[18 18]);
            eye_file = sprintf('%s/%s_%d.%s', RstImg_folder_Val, face_name, num, imgout_ftype);
            imwrite(uint8(img_temp), eye_file, imgout_ftype);
            num = num + 1;
        end
    end
end

fclose(fid_Tr);
fclose(fid_Val);