clear all;
close all;
clc;

ExperimentsIndex = '01';
NodeIndex = '01';
Threshold = 3;

PathFolder = ['Experiments' ExperimentsIndex '\Cascade-BDA\Node' NodeIndex '\Training\ResultsOfScanningBDA'];
PathImg = 'TestImages';
PathTrueResults = ['Experiments' ExperimentsIndex '\Cascade-BDA\Node' NodeIndex '\Training\DetectionResults'];
PathFalseResults = ['Experiments' ExperimentsIndex '\Cascade-BDA\Node' NodeIndex '\Training\DetectionResults\FalseResults'];
Fid_Coord = fopen('Total_Eye_Coord.dat','r');

% PathFolder = ['Experiments' ExperimentsIndex '\Cascade-BDA\Node' NodeIndex '\Training\ResultsOfScanningBDA'];
% PathImg = 'TestImages2';
% PathTrueResults = ['Experiments' ExperimentsIndex '\Cascade-BDA\Node' NodeIndex '\Training\DetectionResults'];
% PathFalseResults = ['Experiments' ExperimentsIndex '\Cascade-BDA\Node' NodeIndex '\Training\DetectionResults\FalseResults'];
% Fid_Coord = fopen('Total_Eye_Coord2.dat','r');

% PathFolder = ['Experiments' ExperimentsIndex '\Cascade-BDA\Node' NodeIndex '\Training\ResultsOfScanningBDA'];
% PathImg = 'TestImages3';
% PathTrueResults = ['Experiments' ExperimentsIndex '\Cascade-BDA\Node' NodeIndex '\Training\DetectionResults'];
% PathFalseResults = ['Experiments' ExperimentsIndex '\Cascade-BDA\Node' NodeIndex '\Training\DetectionResults\FalseResults'];
% Fid_Coord = fopen('Total_Eye_Coord3.dat','r');

ImgFiles = dir([PathImg '\*.bmp']);
RemainImgFiles = dir([PathRemainingImg '\*.bmp']);
nFiles = size(ImgFiles,1)/2;

nTrue = 0;
nFalse = 0;

Result = zeros(26,1);

for k=1:nFiles
    %Left Image
    FileName = ImgFiles(2*k-1,1).name;
    
    ImgMat = imread([PathImg '\' FileName],'bmp');
    ImgMatOutLeft1 = ImgMat;
    ImgMatOutLeft2 = ImgMat;
    [Height,Width] = size(ImgMat);
    
    ImgPatches = load([PathFolder '\LAC_RemainingPatches_' NodeIndex '_' FileName '.dat']);
    nPatches = size(ImgPatches,1);
    
    cur_string = fgetl(Fid_Coord);
    coord_vec = str2num(cur_string);
    EyeY_Orig = coord_vec(1);
    EyeX_Orig = coord_vec(2);
    Distance = coord_vec(3);
    
    if nPatches >= 1
        ImgPatchesReal = zeros(nPatches,7);
        for i=1:nPatches
            WinX = ImgPatches(i,1);
            WinY = ImgPatches(i,2);
            RatioX = Width/WinX;
            RatioY = Height/WinY;
            
            ImgPatchesReal(i,1) = round((ImgPatches(i,3)+ImgPatches(i,5))/2*RatioX);
            ImgPatchesReal(i,2) = round((ImgPatches(i,4)+ImgPatches(i,6))/2*RatioY);
            ImgPatchesReal(i,3) = ImgPatches(i,8);
            ImgPatchesReal(i,4) = round(ImgPatches(i,3)*RatioX);
            ImgPatchesReal(i,5) = round(ImgPatches(i,4)*RatioY);
            ImgPatchesReal(i,6) = round(ImgPatches(i,5)*RatioX);
            ImgPatchesReal(i,7) = round(ImgPatches(i,6)*RatioY);
%             for j=ImgPatchesReal(i,4):ImgPatchesReal(i,6)
%                 ImgMatOutLeft1(ImgPatchesReal(i,5),j) = 255;
%                 ImgMatOutLeft1(ImgPatchesReal(i,7),j) = 255;
%             end
%             for j=ImgPatchesReal(i,5):ImgPatchesReal(i,7)
%                 ImgMatOutLeft1(j,ImgPatchesReal(i,4)) = 255;
%                 ImgMatOutLeft1(j,ImgPatchesReal(i,6)) = 255;
%             end
            ImgMatOutLeft1(ImgPatchesReal(i,2),ImgPatchesReal(i,1)) = 255;
        end
        
        ClusterIndex = zeros(nPatches,1);
        ClusterNum = 0;
        ClusterFlag = 0;
        while ClusterFlag == 0
            ClusterNum = ClusterNum + 1;
            RefFlag = 0;
            idx = 0;
            while RefFlag == 0 && idx < nPatches
                idx = idx + 1;
                if ClusterIndex(idx) == 0
                    RefFlag = 1;
                end
            end
            RefPoint = ImgPatchesReal(idx,1:2);
            ClusterIndex(idx) = ClusterNum;
            
            ClusterIndex = NeighborhoodCheck(RefPoint,ImgPatchesReal(:,1:2),ClusterIndex,Threshold,ClusterNum);
            
            [nCluster,ClusterLabels,nPatchPerCluster] = class_information(ClusterIndex);
            if ClusterLabels(1) ~= 0
                ClusterFlag = 1;
            end
        end
        
        for i = 1 : nCluster
            if max(nPatchPerCluster) == nPatchPerCluster(i)
                nMaxCluster = i;
            end
        end
        
        FaceLocations = zeros(1,2);
        count = 0;
        for j=1:nPatches
            if ClusterIndex(j)==ClusterLabels(nMaxCluster)
                FaceLocations(1,1) = FaceLocations(1,1) + ImgPatchesReal(j,3)*ImgPatchesReal(j,1);
                FaceLocations(1,2) = FaceLocations(1,2) + ImgPatchesReal(j,3)*ImgPatchesReal(j,2);
                count = count + ImgPatchesReal(j,3);
%                 for i=ImgPatchesReal(j,4):ImgPatchesReal(j,6)
%                     ImgMatOutLeft2(ImgPatchesReal(j,5),i) = 255;
%                     ImgMatOutLeft2(ImgPatchesReal(j,7),i) = 255;
%                 end
%                 for i=ImgPatchesReal(j,5):ImgPatchesReal(j,7)
%                     ImgMatOutLeft2(i,ImgPatchesReal(j,4)) = 255;
%                     ImgMatOutLeft2(i,ImgPatchesReal(j,6)) = 255;
%                 end
%                 ImgMatOutLeft2(ImgPatchesReal(j,2),ImgPatchesReal(j,1)) = 255;
            end
        end
        FaceLocations(1,:) = round(FaceLocations(1,:)/count);
        EyeY = FaceLocations(2);
        EyeX = FaceLocations(1);
        for i = -1 : 1
            for j = -1 : 1
                ImgMatOutLeft2(EyeY+i,EyeX+j) = 255;
            end
        end
        ErrorLeft = norm([(EyeY-EyeY_Orig) (EyeX-EyeX_Orig)])/Distance;
    else
        ErrorLeft = 1;
    end
    ImgMatOutLeft1 = fliplr(ImgMatOutLeft1);
    ImgMatOutLeft2 = fliplr(ImgMatOutLeft2);
    
    %Right Image
    FileName = ImgFiles(2*k,1).name;
    
    ImgMat = imread([PathImg '\' FileName],'bmp');
    ImgMatOutRight1 = ImgMat;
    ImgMatOutRight2 = ImgMat;
    [Height,Width] = size(ImgMat);
    
    ImgPatches = load([PathFolder '\LAC_RemainingPatches_' NodeIndex '_' FileName '.dat']);
    nPatches = size(ImgPatches,1);
    
    cur_string = fgetl(Fid_Coord);
    coord_vec = str2num(cur_string);
    EyeY_Orig = coord_vec(1);
    EyeX_Orig = coord_vec(2);
    Distance = coord_vec(3);
    
    if nPatches >= 1
        ImgPatchesReal = zeros(nPatches,7);
        for i=1:nPatches
            WinX = ImgPatches(i,1);
            WinY = ImgPatches(i,2);
            RatioX = Width/WinX;
            RatioY = Height/WinY;
            
            ImgPatchesReal(i,1) = round((ImgPatches(i,3)+ImgPatches(i,5))/2*RatioX);
            ImgPatchesReal(i,2) = round((ImgPatches(i,4)+ImgPatches(i,6))/2*RatioY);
            ImgPatchesReal(i,3) = ImgPatches(i,8);
            ImgPatchesReal(i,4) = round(ImgPatches(i,3)*RatioX);
            ImgPatchesReal(i,5) = round(ImgPatches(i,4)*RatioY);
            ImgPatchesReal(i,6) = round(ImgPatches(i,5)*RatioX);
            ImgPatchesReal(i,7) = round(ImgPatches(i,6)*RatioY);
%             for j=ImgPatchesReal(i,4):ImgPatchesReal(i,6)
%                 ImgMatOutRight1(ImgPatchesReal(i,5),j) = 255;
%                 ImgMatOutRight1(ImgPatchesReal(i,7),j) = 255;
%             end
%             for j=ImgPatchesReal(i,5):ImgPatchesReal(i,7)
%                 ImgMatOutRight1(j,ImgPatchesReal(i,4)) = 255;
%                 ImgMatOutRight1(j,ImgPatchesReal(i,6)) = 255;
%             end
            ImgMatOutRight1(ImgPatchesReal(i,2),ImgPatchesReal(i,1)) = 255;
        end
        
        ClusterIndex = zeros(nPatches,1);
        ClusterNum = 0;
        ClusterFlag = 0;
        while ClusterFlag == 0
            ClusterNum = ClusterNum + 1;
            RefFlag = 0;
            idx = 0;
            while RefFlag == 0 && idx < nPatches
                idx = idx + 1;
                if ClusterIndex(idx) == 0
                    RefFlag = 1;
                end
            end
            RefPoint = ImgPatchesReal(idx,1:2);
            ClusterIndex(idx) = ClusterNum;
            
            ClusterIndex = NeighborhoodCheck(RefPoint,ImgPatchesReal(:,1:2),ClusterIndex,Threshold,ClusterNum);
            
            [nCluster,ClusterLabels,nPatchPerCluster] = class_information(ClusterIndex);
            if ClusterLabels(1) ~= 0
                ClusterFlag = 1;
            end
        end
        
        for i = 1 : nCluster
            if max(nPatchPerCluster) == nPatchPerCluster(i)
                nMaxCluster = i;
            end
        end
        
        FaceLocations = zeros(1,4);
        count = 0;
        for j=1:nPatches
            if ClusterIndex(j)==ClusterLabels(nMaxCluster)
                FaceLocations(1,1) = FaceLocations(1,1) + ImgPatchesReal(j,3)*ImgPatchesReal(j,1);
                FaceLocations(1,2) = FaceLocations(1,2) + ImgPatchesReal(j,3)*ImgPatchesReal(j,2);
                count = count + ImgPatchesReal(j,3);
                WinX = ImgPatches(j,1);
                WinY = ImgPatches(j,2);
                RatioX = Width/WinX;
                RatioY = Height/WinY;
%                 for i=ImgPatchesReal(j,4):ImgPatchesReal(j,6)
%                     ImgMatOutRight2(ImgPatchesReal(j,5),i) = 255;
%                     ImgMatOutRight2(ImgPatchesReal(j,7),i) = 255;
%                 end
%                 for i=ImgPatchesReal(j,5):ImgPatchesReal(j,7)
%                     ImgMatOutRight2(i,ImgPatchesReal(j,4)) = 255;
%                     ImgMatOutRight2(i,ImgPatchesReal(j,6)) = 255;
%                 end
%                 ImgMatOutRight2(ImgPatchesReal(j,2),ImgPatchesReal(j,1)) = 255;
            end
        end
        FaceLocations(1,:) = round(FaceLocations(1,:)/count);
        EyeY = FaceLocations(2);
        EyeX = FaceLocations(1);
        for i = -1 : 1
            for j = -1 : 1
                ImgMatOutRight2(EyeY+i,EyeX+j) = 255;
            end
        end
        ErrorRight = norm([(EyeY-EyeY_Orig) (EyeX-EyeX_Orig)])/Distance;
    else
        ErrorRight = 1;
    end
    
    for i = 0 : 25
        if ErrorRight <= 0.01*i && ErrorLeft <= 0.01*i
            Result(i+1) = Result(i+1) + 1;
        end
    end
    
    if ErrorRight <= 0.15 && ErrorLeft <= 0.15
        nTrue = nTrue + 1;
        imwrite(uint8([ImgMatOutRight2 ImgMatOutLeft2]),[PathTrueResults '\RemainingPatches_' FileName(1:end-9) '_IntgVJ.bmp'],'bmp');
        imwrite(uint8([ImgMatOutRight1 ImgMatOutLeft1]),[PathTrueResults '\RemainingPatches_' FileName(1:end-9) '.bmp'],'bmp');
    else
        nFalse = nFalse + 1;
        imwrite(uint8([ImgMatOutRight2 ImgMatOutLeft2]),[PathFalseResults '\RemainingPatches_' FileName(1:end-9) '_IntgVJ.bmp'],'bmp');
        imwrite(uint8([ImgMatOutRight1 ImgMatOutLeft1]),[PathFalseResults '\RemainingPatches_' FileName(1:end-9) '.bmp'],'bmp');
    end
end
fclose(Fid_Coord);

DetectionRate = nTrue / nFiles * 100;
display([ 'DetectionRate : ' num2str(DetectionRate)]);
display([ 'nTrue : ' num2str(nTrue)]);
display([ 'nFalse : ' num2str(nFalse)]);

Result = Result ./ nFiles .*100;
plot(Result)