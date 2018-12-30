clear all;
close all;
clc;

RstImg_folder_Tr = 'Images-Training';
RstImg_folder_Val = 'Images-Validation';
imgout_ftype = 'bmp';

fid = fopen('Total_gtruth.txt','r');
fid_out_Tr = fopen('Tr_Eye_Coord.dat','w');
fid_out_Val = fopen('Val_Eye_Coord.dat','w');

for k = 1 : 3
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
        cur_idx = cur_string(1:blank_pos-1);
        coord_vec = str2num(cur_string(blank_pos+1:end));
        face_idx = coord_vec(1);
        face_name = sprintf('%s_f%d', cur_idx, face_idx);
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
        Mid_X = round(width/2) ;
        ratio = 84 / 2.25 / distance;
        
        reye_Y = round((reye_orig(1) - Left_Top(1) + 1)*ratio)-1;
        reye_X = round((reye_orig(2) - Left_Top(2) + 1)*ratio)+1;
        leye_Y = round((leye_orig(1) - Left_Top(1) + 1)*ratio)-1;
        leye_X = round((Mid_X - (leye_orig(2) - Left_Top(2) - Mid_X + 1))*ratio)+1;
        distance = distance * ratio;
        
        if rem(i,3) ~= 0
            fprintf(fid_out_Tr,'%d %d %f \n', leye_Y, leye_X, distance );
            fprintf(fid_out_Tr,'%d %d %f \n', reye_Y, reye_X, distance );
            
            img_file = sprintf('%s/%s.%s', folder, cur_idx, imgin_ftype);
            img = imread(img_file, imgin_ftype);
            [img_nrow, img_ncol, n_channel] = size(img);
            if n_channel == 1,
                img_gray = double(img);
            elseif n_channel == 3,
                img_gray = double(rgb2gray(img));
            end
            
            %image out
            img_temp = img_gray(Left_Top(1):Left_Top(1)+round(height*2/3), Left_Top(2):Left_Top(2)+Mid_X-1);
            img_temp = imresize(img_temp,[54 42]);
            reye_file = sprintf('%s/%s_reye.%s', RstImg_folder_Tr, face_name, imgout_ftype);
            imwrite(uint8(img_temp), reye_file, imgout_ftype);
            
            img_temp = img_gray(Left_Top(1):Left_Top(1)+round(height*2/3), Left_Top(2)+Mid_X:Right_Bottom(2));
            img_temp = imresize(img_temp,[54 42]);
            img_temp = fliplr(img_temp);
            leye_file = sprintf('%s/%s_leye.%s', RstImg_folder_Tr, face_name, imgout_ftype);
            imwrite(uint8(img_temp), leye_file, imgout_ftype);
        else
            fprintf(fid_out_Val,'%d %d %f\n', leye_Y, leye_X, distance );
            fprintf(fid_out_Val,'%d %d %f\n', reye_Y, reye_X, distance );
            
            img_file = sprintf('%s/%s.%s', folder, cur_idx, imgin_ftype);
            img = imread(img_file, imgin_ftype);
            [img_nrow, img_ncol, n_channel] = size(img);
            if n_channel == 1,
                img_gray = double(img);
            elseif n_channel == 3,
                img_gray = double(rgb2gray(img));
            end
            
            %image out
            img_temp = img_gray(Left_Top(1):Left_Top(1)+round(height*2/3), Left_Top(2):Left_Top(2)+Mid_X);
            img_temp = imresize(img_temp,[54 42]);
            reye_file = sprintf('%s/%s_reye.%s', RstImg_folder_Val, face_name, imgout_ftype);
            imwrite(uint8(img_temp), reye_file, imgout_ftype);
            
            img_temp = img_gray(Left_Top(1):Left_Top(1)+round(height*2/3), Left_Top(2)+Mid_X+1:Right_Bottom(2));
            img_temp = imresize(img_temp,[54 42]);
            img_temp = fliplr(img_temp);
            leye_file = sprintf('%s/%s_leye.%s', RstImg_folder_Val, face_name, imgout_ftype);
            imwrite(uint8(img_temp), leye_file, imgout_ftype);
        end
    end
end       

fclose(fid);
fclose(fid_out_Tr);
fclose(fid_out_Val);