% clear all;
% close all;
% clc;
% 
% RstImg_folder_Eye = 'Eye1';
% RstImg_folder_Tr = 'EyePatchTr1';
% RstImg_folder_Val = 'EyePatchVal1';
% imgout_ftype = 'png';
% 
% fid = fopen('Total_gtruth.txt','r');
% num = 1;
% for l = 1 : 3
%     if l == 1
%         data_string = 'cmu';
%         start_idx = 1;
%         end_idx = 680;
%         folder = 'Images[original]';
%         imgin_ftype = 'ppm';
%     elseif l == 2
%         data_string = 'bioid';
%         start_idx = 1;
%         end_idx = 320;
%         folder = 'BioID_V1.2';
%         imgin_ftype = 'pgm';
%     elseif l == 3
%         data_string = 'csl';
%         start_idx = 1;
%         end_idx = 1100;
%         folder = 'face_test';
%         imgin_ftype = 'jpg';
%     end
%     
%     for i = start_idx : end_idx,
%         cur_string = fgetl(fid);
%         blank_pos = 1;
%         for j=1:length(cur_string),
%             if cur_string(j) == ' ',
%                 blank_pos = j;
%                 break;
%             end
%         end
%         cur_idx = cur_string(1:blank_pos-1);
%         coord_vec = str2num(cur_string(blank_pos+1:end));
%         face_idx = coord_vec(1);
%         face_name = sprintf('%s_f%d', cur_idx, face_idx);
%         lbox_orig = coord_vec(4:5);
%         if lbox_orig(1) <= 0
%             lbox_orig(1) = 1;
%         elseif lbox_orig(2) <= 0
%             lbox_orig(2) = 1;
%         end
%         rbox_orig = coord_vec(6:7);
%         height = rbox_orig(1) - lbox_orig(1);
%         width = rbox_orig(2) - lbox_orig(2);
%         mid = round(width/2);
%         leye_orig = coord_vec(8:9);
%         reye_orig = coord_vec(10:11);
%         
%         distance = norm(leye_orig' - reye_orig');
%         ratio = 0.9;
%         WinSize = round((distance * ratio)/2);
%         
%         if reye_orig(1) - WinSize <= 0
%             WinSize = reye_orig(1)-2;
%         elseif leye_orig(1) - WinSize <= 0
%             WinSize = leye_orig(1)-2;
%         elseif reye_orig(2) - WinSize <= 0
%             WinSize = reye_orig(2)-2;
%         end
%         
%         %image read
%         img_file = sprintf('%s/%s.%s', folder, cur_idx, imgin_ftype);
%         img = imread(img_file, imgin_ftype);
%         [img_nrow, img_ncol, n_channel] = size(img);
%         if n_channel == 1,
%             img_gray = double(img);
%         elseif n_channel == 3,
%             img_gray = double(rgb2gray(img));
%         end
%         
%         %image out
%         
%         for j = -1 : 1
%             for k = -1 : 1
%                 img_temp = img_gray(reye_orig(1)-WinSize+j : reye_orig(1)+WinSize+j , reye_orig(2)-WinSize+k : reye_orig(2)+WinSize+k);
%                 img_temp = imresize(img_temp,[18 18]);
%                 reye_file = sprintf('%s/%s_reye_%d.%s', RstImg_folder_Eye, face_name, num, imgout_ftype);
%                 imwrite(uint8(img_temp), reye_file, imgout_ftype);
%                 img_temp = img_gray(leye_orig(1)-WinSize+j : leye_orig(1)+WinSize+j , leye_orig(2)-WinSize+k : leye_orig(2)+WinSize+k);
%                 img_temp = fliplr(img_temp);
%                 img_temp = imresize(img_temp,[18 18]);
%                 leye_file = sprintf('%s/%s_leye_%d.%s', RstImg_folder_Eye, face_name, num, imgout_ftype);
%                 imwrite(uint8(img_temp), leye_file, imgout_ftype);
%                 num = num + 1;
%             end
%         end
%     end
% end
% 
% fclose(fid);
% 
% EyePatches = dir([RstImg_folder_Eye '\*.png']);
% nEyes = size(EyePatches,1);
% mid = round( nEyes*2/3 );
% Order = randperm(nEyes);
% for i=1:mid
%     index = Order(i);
%     FileName = EyePatches(index,1).name;
%     Patch = imread([RstImg_folder_Eye '\' FileName],'png');
%     imwrite(Patch,[RstImg_folder_Tr '\' FileName],'png');
% end
for i=mid+1:nEyes
    index = Order(i);
    FileName = EyePatches(index,1).name;
    Patch = imread([RstImg_folder_Eye '\' FileName],'png');
    imwrite(Patch,[RstImg_folder_Val '\' FileName],'png');
end