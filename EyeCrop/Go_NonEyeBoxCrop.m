clear all;
close all;
clc;

imgout_ftype = 'png';
fid = fopen('Total_gtruth.txt','r');
Tr_num = 0;
Val_num = 0;
RstImg_folder_Tr = 'NonEyePatchTr';
RstImg_folder_Val = 'NonEyePatchVal';
fid_Tr_Error = fopen('TrNonEyePatchError.dat','w');
fid_Val_Error = fopen('ValNonEyePatchError.dat','w');
Fid_Tr = fopen('TrainingNonEyeSamples.dat','w');
Fid_Val = fopen('ValidationNonEyeSamples.dat','w');

for l = 1 : 3
    if l == 1
        data_string = 'cmu';
        start_idx = 1;
        end_idx = 680;
        folder = 'Images[original]';
        imgin_ftype = 'ppm';
    elseif l == 2
        data_string = 'bioid';
        start_idx = 1;
        end_idx = 320;
        folder = 'BioID_V1.2';
        imgin_ftype = 'pgm';
    elseif l == 3
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
            if cur_string(j) == ' ';
                blank_pos = j;
                break;
            end
        end
        cur_idx = cur_string(1:blank_pos-1);
        coord_vec = str2num(cur_string(blank_pos+1:end));
        face_idx = coord_vec(1);
        face_name = sprintf('%s_f%d', cur_idx, face_idx);
        lbox_orig = coord_vec(4:5);
        if lbox_orig(1) <= 0
            lbox_orig(1) = 1;
        elseif lbox_orig(2) <= 0
            lbox_orig(2) = 1;
        end
        rbox_orig = coord_vec(6:7);
        if rbox_orig(1) > coord_vec(2)
            rbox_orig(1) = coord_vec(2);
        elseif rbox_orig(2) > coord_vec(3)
            rbox_orig(2) = coord_vec(3);
        end
        height = rbox_orig(1) - lbox_orig(1);
        width = rbox_orig(2) - lbox_orig(2);
        limit = min(height, width)/2;
        mid = round(width/2);
        leye_orig = coord_vec(8:9);
        reye_orig = coord_vec(10:11);
        
        distance = norm(leye_orig' - reye_orig');
        WinSize = 9;
        
        %image read
        img_file = sprintf('%s/%s.%s', folder, cur_idx, imgin_ftype);
        img = imread(img_file, imgin_ftype);
        [img_nrow, img_ncol, n_channel] = size(img);
        if n_channel == 1,
            img_gray = double(img);
        elseif n_channel == 3,
            img_gray = double(rgb2gray(img));
        end
        
        WinSize_Temp = 2*WinSize;
        count = 0;
        while WinSize_Temp + 1 < limit
            WinSize_Temp = round( WinSize_Temp / 0.8 );
            count = count + 1;
        end
        
        %image out
        num = 0;
        for m = 1 : count
            while num < ( 9 / count * m )
                j = round( ( height - 2*WinSize ) * rand );
                k = round( ( width - 2*WinSize ) * rand );
                Center_Y = lbox_orig(1) + WinSize + j;
                Center_X = lbox_orig(2) + WinSize + k;
                rerror = sqrt(( Center_Y - reye_orig(1) )^2 + ( Center_X - reye_orig(2) )^2)/distance;
                lerror = sqrt(( Center_Y - leye_orig(1) )^2 + ( Center_X - leye_orig(2) )^2)/distance;
                if ( rerror >= 0.3 ) || ( lerror >= 0.3 )
                    if rerror <= lerror
                        if ( Center_Y-WinSize > lbox_orig(1) ) && ( Center_Y+WinSize <= rbox_orig(1) ) && ( Center_X-WinSize > lbox_orig(2) ) && ( Center_X-WinSize <= rbox_orig(2) )
                            img_temp = img_gray(Center_Y-WinSize:Center_Y+WinSize, Center_X-WinSize:Center_X+WinSize);
                            img_temp = imresize(img_temp,[18 18]);
                            num = num + 1;
                            if rem(num,3) ~= 1
                                Tr_num = Tr_num + 1;
                                eye_file = sprintf('%s/%s_%d.%s',RstImg_folder_Tr, face_name, Tr_num, imgout_ftype);
                                imwrite(uint8(img_temp), eye_file,imgout_ftype);
                                ImgPatchNorm = ImageNormalization(double(img_temp));
                                ImgPatchNorm = IntgImg(double(ImgPatchNorm),1);
                                ImgVec = reshape(ImgPatchNorm',[1,18*18]);
                                for n=1:18*18
                                    fprintf(Fid_Tr,'%f ',ImgVec(n));
                                end
                                fprintf(Fid_Tr,'%d\n',0);
                                fprintf(fid_Tr_Error,'%d\n',round(100*rerror));
                                if flag == 2
                                    fprintf(Fid_Est_Tr,'%d\n',1);
                                end
                            else
                                Val_num = Val_num + 1;
                                eye_file = sprintf('%s/%s_%d.%s',RstImg_folder_Val, face_name, Val_num, imgout_ftype);
                                imwrite(uint8(img_temp), eye_file,imgout_ftype);
                                ImgPatchNorm = ImageNormalization(double(img_temp));
                                ImgPatchNorm = IntgImg(double(ImgPatchNorm),1);
                                ImgVec = reshape(ImgPatchNorm',[1,18*18]);
                                for n=1:18*18
                                    fprintf(Fid_Val,'%f ',ImgVec(n));
                                end
                                fprintf(Fid_Val,'%d\n',0);
                                fprintf(fid_Val_Error,'%d\n',round(100*rerror));
                                if flag == 2
                                    fprintf(Fid_Est_Val,'%d\n',1);
                                end
                            end
                        end
                    elseif rerror > lerror
                        if ( Center_Y-WinSize > lbox_orig(1) ) && ( Center_Y+WinSize <= rbox_orig(1) ) && ( Center_X-WinSize > lbox_orig(2) ) && ( Center_X-WinSize <= rbox_orig(2) )
                            img_temp = img_gray(Center_Y-WinSize:Center_Y+WinSize, Center_X-WinSize:Center_X+WinSize);
                            img_temp = fliplr(img_temp);
                            img_temp = imresize(img_temp,[18 18]);
                            num = num + 1;
                            if rem(num,3) ~= 1
                                Tr_num = Tr_num + 1;
                                eye_file = sprintf('%s/%s_%d.%s',RstImg_folder_Tr, face_name, Tr_num, imgout_ftype);
                                imwrite(uint8(img_temp), eye_file,imgout_ftype);
                                ImgPatchNorm = ImageNormalization(double(img_temp));
                                ImgPatchNorm = IntgImg(double(ImgPatchNorm),1);
                                ImgVec = reshape(ImgPatchNorm',[1,18*18]);
                                for n=1:18*18
                                    fprintf(Fid_Tr,'%f ',ImgVec(n));
                                end
                                fprintf(Fid_Tr,'%d\n',0);
                                fprintf(fid_Tr_Error,'%d\n',round(100*lerror));
                            else
                                Val_num = Val_num + 1;
                                eye_file = sprintf('%s/%s_%d.%s',RstImg_folder_Val, face_name, Val_num, imgout_ftype);
                                imwrite(uint8(img_temp), eye_file,imgout_ftype);
                                ImgPatchNorm = ImageNormalization(double(img_temp));
                                ImgPatchNorm = IntgImg(double(ImgPatchNorm),1);
                                ImgVec = reshape(ImgPatchNorm',[1,18*18]);
                                for n=1:18*18
                                    fprintf(Fid_Val,'%f ',ImgVec(n));
                                end
                                fprintf(Fid_Val,'%d\n',0);
                                fprintf(fid_Val_Error,'%d\n',round(100*lerror));
                            end
                        end
                    end
                end
            end
            WinSize = round( WinSize / 0.8 );
        end
    end
end

fclose(fid);
fclose(fid_Tr_Error);
fclose(fid_Val_Error);
fclose(Fid_Tr);
fclose(Fid_Val);