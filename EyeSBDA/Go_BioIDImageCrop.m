clear all;
close all;
clc;

RstImg_folder = 'TestImages2';
imgout_ftype = 'bmp';

fid_out = fopen('Total_Eye_Coord2.dat','w');

folder = 'BioID_V1.2';
imgin_ftype = 'pgm';

ImgFiles = dir([folder '\*.pgm']);
nFiles = size(ImgFiles,1);

test = load('BioIDList.txt');

for i = 1 : nFiles
    FileName = ImgFiles(i,1).name(1:end-4);
    flag = 0 ;
    for j = 1 : 320
        if str2num(FileName(end-3:end)) == test(j)
            flag = 1;
        end
    end
    
    if flag == 0
        fid = fopen([ folder '\' FileName '.eye' ],'r');
        cur_string = fgetl(fid);
        cur_string = fgetl(fid);
        coord_vec = str2num(cur_string);
        leye_orig = fliplr(coord_vec(1:2));
        reye_orig = fliplr(coord_vec(3:4));
        distance = round(norm(leye_orig' - reye_orig'));
        
        img_file = sprintf('%s/%s.%s', folder, FileName, imgin_ftype);
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
        
        reye_Y = round((reye_orig(1) - Left_Top(1) + 1)*ratio);
        reye_X = round((reye_orig(2) - Left_Top(2) + 1)*ratio);
        leye_Y = round((leye_orig(1) - Left_Top(1) + 1)*ratio);
        leye_X = round((Mid_X - (leye_orig(2) - Left_Top(2) - Mid_X + 1))*ratio);
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
        %     img_temp(reye_Y-1:reye_Y+1,reye_X-1:reye_X+1)=255;
        reye_file = sprintf('%s/%s_reye.%s', RstImg_folder, FileName, imgout_ftype);
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
        %     img_temp(leye_Y-1:leye_Y+1,leye_X-1:leye_X+1)=255;
        leye_file = sprintf('%s/%s_leye.%s', RstImg_folder, FileName, imgout_ftype);
        imwrite(uint8(img_temp), leye_file, imgout_ftype);
        fclose(fid);
    end
end

fclose(fid_out);