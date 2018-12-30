clear all;
close all;
clc;

RstImg_folder = 'TestImages';
imgout_ftype = 'bmp';

fid = fopen('Final_DB_eye_coord_ground_truth.txt','r');
fid_out = fopen('Total_Eye_Coord.dat','w');

folder = 'Final_DB';
imgin_ftype = 'bmp';

for i = 1 : 2330
    cur_string = fgetl(fid);
    blank_pos = 1;
    for j=1:length(cur_string),
        if cur_string(j) == ' ',
            blank_pos = j;
            break;
        end
    end
    face_name = cur_string(1:blank_pos-5);
    coord_vec = str2num(cur_string(blank_pos+1:end));
    leye_orig = fliplr(coord_vec(3:4));
    reye_orig = fliplr(coord_vec(1:2));
    distance = round(norm(leye_orig' - reye_orig'));
    
    img_file = sprintf('%s/%s.%s', folder, face_name, imgin_ftype);
    img = imread(img_file, imgin_ftype);
    [img_nrow, img_ncol, n_channel] = size(img);
    if n_channel == 1,
        img_gray = double(img);
    elseif n_channel == 3,
        img_gray = double(rgb2gray(img));
    end
    
    Left_Top = [round((reye_orig(1)+leye_orig(1))/2 - 0.3*2.25*distance) , round((reye_orig(2)+leye_orig(2))/2 - 0.5*2.25*distance)];
    if Left_Top(1) <= 0
        Left_Top(1) = 1;
    elseif Left_Top(2) <= 0
        Left_Top(2) = 1;
    end
    Right_Bottom = [round(Left_Top(1) + 2.25*distance) , round(Left_Top(2) + 2.25*distance)];
    if Right_Bottom(1) >= img_nrow
        Right_Bottom(1) = img_nrow;
    elseif Right_Bottom(2) >= img_ncol
        Right_Bottom(2) = img_ncol;
    end
    height = Right_Bottom(1) - Left_Top(1) ;
    width = Right_Bottom(2) - Left_Top(2);
    Mid_X = round(width/2) ;
    ratio = 84 / 2.25 / distance;
    
    reye_Y = round((reye_orig(1) - Left_Top(1) + 1)*ratio)-1;
    reye_X = round((reye_orig(2) - Left_Top(2) + 1)*ratio)+1;
    leye_Y = round((leye_orig(1) - Left_Top(1) + 1)*ratio)-1;
    leye_X = round((Mid_X - (leye_orig(2) - Left_Top(2) - Mid_X + 1))*ratio)+1;
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
    if reye_X + WinSize > Mid_X*ratio
        WinSize = round(Mid_X*ratio - reye_X - 1);
    end
    if leye_X - WinSize <= 0
        WinSize = leye_X - 1;
    end
    if leye_X + WinSize > Mid_X*ratio
        WinSize = round(Mid_X*ratio - leye_X - 1);
    end
    
    fprintf(fid_out,'%d %d %f \n', leye_Y, leye_X, distance );
    fprintf(fid_out,'%d %d %f \n', reye_Y, reye_X, distance );
    
    %image out
    img_temp = img_gray(Left_Top(1):Left_Top(1)+round(height*2/3), Left_Top(2):Left_Top(2)+Mid_X-1);
    img_temp = imresize(img_temp,[54 42]);
%     for j = reye_Y - WinSize : reye_Y + WinSize
%         img_temp(j,reye_X - WinSize) = 255;
%         img_temp(j,reye_X + WinSize) = 255;
%     end
%     for j = reye_X - WinSize : reye_X + WinSize
%         img_temp(reye_Y - WinSize,j) = 255;
%         img_temp(reye_Y + WinSize,j) = 255;
%     end
    reye_file = sprintf('%s/%s_reye.%s', RstImg_folder, face_name, imgout_ftype);
    imwrite(uint8(img_temp), reye_file, imgout_ftype);
    
    img_temp = img_gray(Left_Top(1):Left_Top(1)+round(height*2/3), Left_Top(2)+Mid_X:Right_Bottom(2));
    img_temp = imresize(img_temp,[54 42]);
    img_temp = fliplr(img_temp);
%     for j = leye_Y - WinSize : leye_Y + WinSize
%         img_temp(j,leye_X - WinSize) = 255;
%         img_temp(j,leye_X + WinSize) = 255;
%     end
%     for j = leye_X - WinSize : leye_X + WinSize
%         img_temp(leye_Y - WinSize,j) = 255;
%         img_temp(leye_Y + WinSize,j) = 255;
%     end
    leye_file = sprintf('%s/%s_leye.%s', RstImg_folder, face_name, imgout_ftype);
    imwrite(uint8(img_temp), leye_file, imgout_ftype);
end
% end

fclose(fid);
fclose(fid_out);