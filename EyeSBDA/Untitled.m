clear all;
close all;
clc;

RstImg_folder = 'TrainingImages';
imgout_ftype = 'bmp';

fid = fopen('Total_gtruth.txt','r');
fid_out = fopen('EyeGroundTruth.txt','w');
fprintf(fid_out,'FileName        reye_Y reye_X leye_Y leye_X \n');

for k = 1 : 2
    if k == 1
        data_string = 'cmu';
        start_idx = 1;
        end_idx = 680;
        folder = 'Images[original]';
        imgin_ftype = 'ppm';
    elseif k == 2
        data_string = 'bioid';
        start_idx = 1;
        end_idx = 320;
        folder = 'BioID_V1.2';
        imgin_ftype = 'pgm';
    elseif k == 3
        data_string = 'csl';
        start_idx = 1;
        end_idx = 1100;
        folder = 'face_test';
        imgin_ftype = 'jpg';
    end
    
    for i = start_idx : end_idx,
        cur_string = fgetl(fid);
        blank_pos = 1;
        for j=1:length(cur_string),
            if cur_string(j) == ' ',
                blank_pos = j;
                break;
            end
        end
        face_name = cur_string(1:blank_pos-1);
        coord_vec = str2num(cur_string(blank_pos+1:end));
        leye_orig = coord_vec(8:9);
        reye_orig = coord_vec(10:11);
        distance = norm(leye_orig' - reye_orig');
        
        Left_Top = [round((leye_orig(1)+reye_orig(1))/2-2.25*distance/3) round((leye_orig(2)+reye_orig(2))/2-2.25*distance*0.5)];
        if Left_Top(1) <= 0
            Left_Top(1) = 1;
        elseif Left_Top(2) <= 0
            Left_Top(2) = 1;
        end
        Right_Bottom = [round((leye_orig(1)+reye_orig(1))/2+2.25*distance*2/3) round((leye_orig(2)+reye_orig(2))/2+2.25*distance*0.5)];
        if Right_Bottom(1) >= coord_vec(2)
            Right_Bottom(1) = coord_vec(2);
        elseif Right_Bottom(2) >= coord_vec(3)
            Right_Bottom(2) = coord_vec(3);
        end
        height = Right_Bottom(1) - Left_Top(1);
        width = Right_Bottom(2) - Left_Top(2);
        ratio = 84 / 2.25 / distance;
        
        reye_Y = round((reye_orig(1) - Left_Top(1) + 1)*ratio);
        reye_X = round((reye_orig(2) - Left_Top(2) + 1)*ratio);
        leye_Y = round((leye_orig(1) - Left_Top(1) + 1)*ratio);
        leye_X = round((leye_orig(2) - Left_Top(2) + 1)*ratio);
        distance = distance * ratio;
        
        WinSize = round(distance/2);
        
        if reye_Y - WinSize <= 0
            WinSize = reye_Y - 1;
        end
        if reye_Y + WinSize > height*ratio
            WinSize = round(height*ratio - reye_Y - 1);
        end
        if leye_Y - WinSize <= 0
            WinSize = leye_Y - 1;
        end
        if leye_Y + WinSize > height*ratio
            WinSize = round(height*ratio - leye_Y - 1);
        end
        if reye_X - WinSize <= 0
            WinSize = reye_X - 1;
        end
        if leye_X + WinSize > width*ratio
            WinSize = round(Mid_X*ratio - leye_X - 1);
        end
        fprintf(fid_out,'%s.bmp   %d   %d   %d   %d \n', face_name, reye_Y, reye_X, leye_Y, leye_X);
        
        img_file = sprintf('%s/%s.%s', folder, face_name, imgin_ftype);
        img = imread(img_file, imgin_ftype);
        [img_nrow, img_ncol, n_channel] = size(img);
        if n_channel == 1,
            img_gray = double(img);
        elseif n_channel == 3,
            img_gray = double(rgb2gray(img));
        end
        
        %image out
        img_temp = img_gray(Left_Top(1):Right_Bottom(1),Left_Top(2):Right_Bottom(2));
        img_temp = imresize(img_temp,[84 84]);
%         for j = reye_Y - WinSize : reye_Y + WinSize
%             img_temp(j,reye_X - WinSize) = 255;
%             img_temp(j,reye_X + WinSize) = 255;
%         end
%         for j = reye_X - WinSize : reye_X + WinSize
%             img_temp(reye_Y - WinSize,j) = 255;
%             img_temp(reye_Y + WinSize,j) = 255;
%         end
%         img_temp(reye_Y-1:reye_Y+1,reye_X-1:reye_X+1)=255;
%         for j = leye_Y - WinSize : leye_Y + WinSize
%             img_temp(j,leye_X - WinSize) = 255;
%             img_temp(j,leye_X + WinSize) = 255;
%         end
%         for j = leye_X - WinSize : leye_X + WinSize
%             img_temp(leye_Y - WinSize,j) = 255;
%             img_temp(leye_Y + WinSize,j) = 255;
%         end
%         img_temp(leye_Y-1:leye_Y+1,leye_X-1:leye_X+1)=255;
        reye_file = sprintf('%s/%s.%s', RstImg_folder, face_name, imgout_ftype);
        imwrite(uint8(img_temp), reye_file, imgout_ftype);
    end
end

fclose(fid);
fclose(fid_out);