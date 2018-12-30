clear all;
close all;
clc;

RstImg_folder_Pos = 'EyePatches';
RstImg_folder_Neg = 'NonEyePatches';
imgout_ftype = 'bmp';
imgin_ftype = 'bmp';
fid = fopen('EyeGroundTruth.txt','r');
cur_string = fgetl(fid);

folder = 'TrainingImages';
Img = dir([folder '\*.bmp']);
nImg = size(Img,1);

for i = 1 : nImg
    cur_string = fgetl(fid);
    coord_vec = str2num(cur_string);
    reye = coord_vec(1:2);
    leye = coord_vec(3:4);
    WinSize = 18;
    
    %image read
    img_file = Img(i).name;
    img = imread([folder '\' img_file], imgin_ftype);
    [img_nrow, img_ncol, n_channel] = size(img);
    if n_channel == 1,
        img_gray = double(img);
    elseif n_channel == 3,
        img_gray = double(rgb2gray(img));
    end
    
    if reye(1) - WinSize <= 1
        WinSize = reye(1) - 2;
    end
    if reye(2) - WinSize <= 1
        WinSize = reye(2) - 2;
    end
    if reye(1) + WinSize >= img_nrow - 1
        WinSize = img_nrow - reye(1) - 2;
    end
    if reye(2) + WinSize >= img_ncol - 1
        WinSize = img_ncol - reye(2) - 2;
    end
    if leye(1) - WinSize <= 1
        WinSize = leye(1) - 2;
    end
    if leye(2) - WinSize <= 1
        WinSize = leye(2) - 2;
    end
    if leye(1) + WinSize >= img_nrow - 1
        WinSize = img_nrow - leye(1) - 2;
    end
    if leye(2) + WinSize >= img_ncol - 1
        WinSize = img_ncol - leye(2) - 2;
    end
    
    %image out
    img_temp = img_gray(reye(1)-WinSize : reye(1)+WinSize , reye(2)-WinSize : reye(2)+WinSize);
    img_temp = imresize(img_temp,[18 18]);
    eye_file = sprintf('%s/%s_reye.%s', RstImg_folder_Pos, img_file(1:end-4), imgout_ftype);
    imwrite(uint8(img_temp), eye_file, imgout_ftype);
    
    img_temp = img_gray(leye(1)-WinSize : leye(1)+WinSize , leye(2)-WinSize : leye(2)+WinSize);
    img_temp = imresize(img_temp,[18 18]);
    eye_file = sprintf('%s/%s_leye.%s', RstImg_folder_Pos, img_file(1:end-4), imgout_ftype);
    imwrite(uint8(img_temp), eye_file, imgout_ftype);
end
fclose(fid);