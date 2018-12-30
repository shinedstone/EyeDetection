clear all;
close all;
clc;

ExperimentsIndex = '08';
NodeIndex = '08';

% PathFolder = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Training\ResultsOfScanningLAC'];
% PathImg = 'Images-Training';
% PathTrueResults = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Training\DetectionResults'];
% PathFalseResults = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Training\DetectionResults\FalseResults'];
% PathNoRemain = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Training\DetectionResults\NoRemainResults'];
% Fid_Coord = fopen('Tr_Eye_Coord.dat','r');

% PathFolder = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Validation\ResultsOfScanningLAC'];
% PathImg = 'Images-Validation';
% PathTrueResults = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Validation\DetectionResults'];
% PathFalseResults = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Validation\DetectionResults\FalseResults'];
% PathNoRemain = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Training\DetectionResults\NoRemainResults'];
% Fid_Coord = fopen('Val_Eye_Coord.dat','r');

PathFolder = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Training\ResultsOfScanningLAC'];
PathImg = 'TestImages';
PathTrueResults = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Training\DetectionResults'];
PathFalseResults = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Training\DetectionResults\FalseResults'];
PathNoRemain = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Training\DetectionResults\NoRemainResults'];
Fid_Coord = fopen('Total_Eye_Coord.dat','r');

ImgFiles = dir([PathImg '\*.bmp']);
nFiles = size(ImgFiles,1)/2;

nTrue = 0;
nFalse = 0;

for k=1:nFiles
    %Left Image
    FileName = ImgFiles(2*k-1,1).name;
    
    ImgMat = imread([PathImg '\' FileName],'bmp');
    ImgMatOutLeft1 = ImgMat;
    ImgMatOutLeft2 = ImgMat;
    [Height,Width] = size(ImgMat);
    ScoreMat = zeros(Height,Width);
    
    ImgPatches = load([PathFolder '\LAC_RemainingPatches_' NodeIndex '_' FileName '.dat']);
    nPatches = size(ImgPatches,1);
    
    cur_string = fgetl(Fid_Coord);
    coord_vec = str2num(cur_string);
    EyeY_Orig = coord_vec(1);
    EyeX_Orig = coord_vec(2);
    Distance = coord_vec(3);
    
    if nPatches >= 1
        ImgPatchesReal = zeros(nPatches,5);
        PatchSize = zeros(nPatches,1);
        for i=1:nPatches
            WinX = ImgPatches(i,1);
            WinY = ImgPatches(i,2);
            RatioX = Width/WinX;
            RatioY = Height/WinY;
            
            ImgPatchesReal(nPatches-i+1,1) = round(ImgPatches(i,3)*RatioX);
            ImgPatchesReal(nPatches-i+1,2) = round(ImgPatches(i,4)*RatioY);
            ImgPatchesReal(nPatches-i+1,3) = round(ImgPatches(i,5)*RatioX);
            ImgPatchesReal(nPatches-i+1,4) = round(ImgPatches(i,6)*RatioY);
            ImgPatchesReal(nPatches-i+1,5) = ImgPatches(i,8);
            
            TopLeftX = ImgPatchesReal(nPatches-i+1,1);
            TopLeftY = ImgPatchesReal(nPatches-i+1,2);
            BottomRightX = ImgPatchesReal(nPatches-i+1,3);
            BottomRightY = ImgPatchesReal(nPatches-i+1,4);
            PatchSize(nPatches-i+1) = BottomRightX - TopLeftX;
            
%             for j=TopLeftX:BottomRightX
%                 ImgMatOutLeft1(TopLeftY,j) = 255;
%                 ImgMatOutLeft1(BottomRightY,j) = 255;
%             end
%             for j=TopLeftY:BottomRightY
%                 ImgMatOutLeft1(j,TopLeftX) = 255;
%                 ImgMatOutLeft1(j,BottomRightX) = 255;
%             end
%           ImgMatOutLeft1(round((TopLeftY+BottomRightY)/2) , round((TopLeftX+BottomRightX)/2)) = 255;
        end
        
        %display(ImgPatchesReal);
        %Overlap이 되어있는 Patches들을 하나의 cluster에 속하도록 만듦.
        ClusterIndex = zeros(nPatches,1);
        ClusterIndex(1) = 1;
        for i=2:nPatches
            x1 = ImgPatchesReal(i,1);
            y1 = ImgPatchesReal(i,2);
            x2 = ImgPatchesReal(i,3);
            y2 = ImgPatchesReal(i,4);
            
            ClusterCandidates = zeros(max(ClusterIndex(1:i-1)),1);
            Index = 0;
            for j=1:i-1
                if ImgPatchesReal(j,1) <= x1 && ImgPatchesReal(j,3) >= x1 && ImgPatchesReal(j,2) <= y1 && ImgPatchesReal(j,4) >= y1
                    Index = Index + 1;
                    if Index == 1
                        ClusterCandidates(Index) = ClusterIndex(j);
                    elseif ClusterCandidates(Index-1) ~= ClusterIndex(j)
                        ClusterCandidates(Index) = ClusterIndex(j);
                    elseif ClusterCandidates(Index-1) == ClusterIndex(j)
                        Index = Index - 1;
                    end
                elseif ImgPatchesReal(j,1) <= x1 && ImgPatchesReal(j,3) >= x1 && ImgPatchesReal(j,2) <= y2 && ImgPatchesReal(j,4) >= y2
                    Index = Index + 1;
                    if Index == 1
                        ClusterCandidates(Index) = ClusterIndex(j);
                    elseif ClusterCandidates(Index-1) ~= ClusterIndex(j)
                        ClusterCandidates(Index) = ClusterIndex(j);
                    elseif ClusterCandidates(Index-1) == ClusterIndex(j)
                        Index = Index - 1;
                    end
                elseif ImgPatchesReal(j,1) <= x2 && ImgPatchesReal(j,3) >= x2 && ImgPatchesReal(j,2) <= y1 && ImgPatchesReal(j,4) >= y1
                    Index = Index + 1;
                    if Index == 1
                        ClusterCandidates(Index) = ClusterIndex(j);
                    elseif ClusterCandidates(Index-1) ~= ClusterIndex(j)
                        ClusterCandidates(Index) = ClusterIndex(j);
                    elseif ClusterCandidates(Index-1) == ClusterIndex(j)
                        Index = Index - 1;
                    end
                elseif ImgPatchesReal(j,1) <= x2 && ImgPatchesReal(j,3) >= x2 && ImgPatchesReal(j,2) <= y2 && ImgPatchesReal(j,4) >= y2
                    Index = Index + 1;
                    if Index == 1
                        ClusterCandidates(Index) = ClusterIndex(j);
                    elseif ClusterCandidates(Index-1) ~= ClusterIndex(j)
                        ClusterCandidates(Index) = ClusterIndex(j);
                    elseif ClusterCandidates(Index-1) == ClusterIndex(j)
                        Index = Index - 1;
                    end
                end
            end
            if Index == 1
                ClusterIndex(i) = ClusterCandidates(Index);
            elseif Index == 0
                ClusterIndex(i) = max(ClusterIndex) + 1;
            end
        end
        [nCluster,ClusterLabels,nPatchPerCluster] = class_information(ClusterIndex);
        
        for i = 1 : nCluster
            if max(nPatchPerCluster) == nPatchPerCluster(i)
                nMaxCluster = i;
            end
        end

        FaceLocations = zeros(1,4);
        count = 0;
        for j=1:nPatches
            if ClusterIndex(j)==ClusterLabels(nMaxCluster)
                FaceLocations(1,1) = FaceLocations(1,1) + ImgPatchesReal(j,5)*ImgPatchesReal(j,1);
                FaceLocations(1,2) = FaceLocations(1,2) + ImgPatchesReal(j,5)*ImgPatchesReal(j,2);
                FaceLocations(1,3) = FaceLocations(1,3) + ImgPatchesReal(j,5)*ImgPatchesReal(j,3);
                FaceLocations(1,4) = FaceLocations(1,4) + ImgPatchesReal(j,5)*ImgPatchesReal(j,4);
                count = count + ImgPatchesReal(j,5);
                for i=ImgPatchesReal(j,1):ImgPatchesReal(j,3)
                    ImgMatOutLeft1(ImgPatchesReal(j,2),i) = 255;
                    ImgMatOutLeft1(ImgPatchesReal(j,4),i) = 255;
                end
                for i=ImgPatchesReal(j,2):ImgPatchesReal(j,4)
                    ImgMatOutLeft1(i,ImgPatchesReal(j,1)) = 255;
                    ImgMatOutLeft1(i,ImgPatchesReal(j,3)) = 255;
                end
            end
        end
        %             FaceLocations(i,:) = round(FaceLocations(i,:)/nPatchPerCluster(i));
        FaceLocations(1,:) = round(FaceLocations(1,:)/count);
        
        %             TopLeftX = FaceLocations(i,1);
        %             TopLeftY = FaceLocations(i,2);
        %             BottomRightX = FaceLocations(i,3);
        %             BottomRightY = FaceLocations(i,4);
        EyeY = round((FaceLocations(1,2) + FaceLocations(1,4))/2);
        EyeX = round((FaceLocations(1,1) + FaceLocations(1,3))/2);
        
        %             for j=TopLeftX:BottomRightX
        %                 ImgMatOutLeft2(TopLeftY,j) = 255;
        %                 ImgMatOutLeft2(BottomRightY,j) = 255;
        %             end
        %             for j=TopLeftY:BottomRightY
        %                 ImgMatOutLeft2(j,TopLeftX) = 255;
        %                 ImgMatOutLeft2(j,BottomRightX) = 255;
        %             end
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
    ScoreMat = zeros(Height,Width);
    
    ImgPatches = load([PathFolder '\LAC_RemainingPatches_' NodeIndex '_' FileName '.dat']);
    nPatches = size(ImgPatches,1);
    
    cur_string = fgetl(Fid_Coord);
    coord_vec = str2num(cur_string);
    EyeY_Orig = coord_vec(1);
    EyeX_Orig = coord_vec(2);
    Distance = coord_vec(3);
    
    if nPatches >= 1
        ImgPatchesReal = zeros(nPatches,4);
        PatchSize = zeros(nPatches,1);
        for i=1:nPatches
            WinX = ImgPatches(i,1);
            WinY = ImgPatches(i,2);
            RatioX = Width/WinX;
            RatioY = Height/WinY;
            
            ImgPatchesReal(nPatches-i+1,1) = round(ImgPatches(i,3)*RatioX);
            ImgPatchesReal(nPatches-i+1,2) = round(ImgPatches(i,4)*RatioY);
            ImgPatchesReal(nPatches-i+1,3) = round(ImgPatches(i,5)*RatioX);
            ImgPatchesReal(nPatches-i+1,4) = round(ImgPatches(i,6)*RatioY);
            ImgPatchesReal(nPatches-i+1,5) = ImgPatches(i,8);
            
            TopLeftX = ImgPatchesReal(nPatches-i+1,1);
            TopLeftY = ImgPatchesReal(nPatches-i+1,2);
            BottomRightX = ImgPatchesReal(nPatches-i+1,3);
            BottomRightY = ImgPatchesReal(nPatches-i+1,4);
            PatchSize(nPatches-i+1) = BottomRightX - TopLeftX;
            
%             for j=TopLeftX:BottomRightX
%                 ImgMatOutRight1(TopLeftY,j) = 255;
%                 ImgMatOutRight1(BottomRightY,j) = 255;
%             end
%             for j=TopLeftY:BottomRightY
%                 ImgMatOutRight1(j,TopLeftX) = 255;
%                 ImgMatOutRight1(j,BottomRightX) = 255;
%             end
%           ImgMatOutLeft1(round((TopLeftY+BottomRightY)/2) ,round((TopLeftX+BottomRightX)/2)) = 255;
        end
        
        %display(ImgPatchesReal);
        %Overlap이 되어있는 Patches들을 하나의 cluster에 속하도록 만듦.
        ClusterIndex = zeros(nPatches,1);
        ClusterIndex(1) = 1;
        for i=2:nPatches
            x1 = ImgPatchesReal(i,1);
            y1 = ImgPatchesReal(i,2);
            x2 = ImgPatchesReal(i,3);
            y2 = ImgPatchesReal(i,4);
            
            ClusterCandidates = zeros(max(ClusterIndex(1:i-1)),1);
            Index = 0;
            for j=1:i-1
                if ImgPatchesReal(j,1) <= x1 && ImgPatchesReal(j,3) >= x1 && ImgPatchesReal(j,2) <= y1 && ImgPatchesReal(j,4) >= y1
                    Index = Index + 1;
                    if Index == 1
                        ClusterCandidates(Index) = ClusterIndex(j);
                    elseif ClusterCandidates(Index-1) ~= ClusterIndex(j)
                        ClusterCandidates(Index) = ClusterIndex(j);
                    elseif ClusterCandidates(Index-1) == ClusterIndex(j)
                        Index = Index - 1;
                    end
                elseif ImgPatchesReal(j,1) <= x1 && ImgPatchesReal(j,3) >= x1 && ImgPatchesReal(j,2) <= y2 && ImgPatchesReal(j,4) >= y2
                    Index = Index + 1;
                    if Index == 1
                        ClusterCandidates(Index) = ClusterIndex(j);
                    elseif ClusterCandidates(Index-1) ~= ClusterIndex(j)
                        ClusterCandidates(Index) = ClusterIndex(j);
                    elseif ClusterCandidates(Index-1) == ClusterIndex(j)
                        Index = Index - 1;
                    end
                elseif ImgPatchesReal(j,1) <= x2 && ImgPatchesReal(j,3) >= x2 && ImgPatchesReal(j,2) <= y1 && ImgPatchesReal(j,4) >= y1
                    Index = Index + 1;
                    if Index == 1
                        ClusterCandidates(Index) = ClusterIndex(j);
                    elseif ClusterCandidates(Index-1) ~= ClusterIndex(j)
                        ClusterCandidates(Index) = ClusterIndex(j);
                    elseif ClusterCandidates(Index-1) == ClusterIndex(j)
                        Index = Index - 1;
                    end
                elseif ImgPatchesReal(j,1) <= x2 && ImgPatchesReal(j,3) >= x2 && ImgPatchesReal(j,2) <= y2 && ImgPatchesReal(j,4) >= y2
                    Index = Index + 1;
                    if Index == 1
                        ClusterCandidates(Index) = ClusterIndex(j);
                    elseif ClusterCandidates(Index-1) ~= ClusterIndex(j)
                        ClusterCandidates(Index) = ClusterIndex(j);
                    elseif ClusterCandidates(Index-1) == ClusterIndex(j)
                        Index = Index - 1;
                    end
                end
            end
            if Index == 1
                ClusterIndex(i) = ClusterCandidates(Index);
            elseif Index == 0
                ClusterIndex(i) = max(ClusterIndex) + 1;
            end
        end
        [nCluster,ClusterLabels,nPatchPerCluster] = class_information(ClusterIndex);
        
        for i = 1 : nCluster
            if max(nPatchPerCluster) == nPatchPerCluster(i)
                nMaxCluster = i;
            end
        end
        
        FaceLocations = zeros(1,4);
        count = 0;
        for j=1:nPatches
            if ClusterIndex(j)==ClusterLabels(nMaxCluster) 
                FaceLocations(1,1) = FaceLocations(1,1) + ImgPatchesReal(j,5)*ImgPatchesReal(j,1);
                FaceLocations(1,2) = FaceLocations(1,2) + ImgPatchesReal(j,5)*ImgPatchesReal(j,2);
                FaceLocations(1,3) = FaceLocations(1,3) + ImgPatchesReal(j,5)*ImgPatchesReal(j,3);
                FaceLocations(1,4) = FaceLocations(1,4) + ImgPatchesReal(j,5)*ImgPatchesReal(j,4);
                count = count + ImgPatchesReal(j,5);
                for i=ImgPatchesReal(j,1):ImgPatchesReal(j,3)
                    ImgMatOutRight1(ImgPatchesReal(j,2),i) = 255;
                    ImgMatOutRight1(ImgPatchesReal(j,4),i) = 255;
                end
                for i=ImgPatchesReal(j,2):ImgPatchesReal(j,4)
                    ImgMatOutRight1(i,ImgPatchesReal(j,1)) = 255;
                    ImgMatOutRight1(i,ImgPatchesReal(j,3)) = 255;
                end
            end
        end
        %             FaceLocations(i,:) = round(FaceLocations(i,:)/nPatchPerCluster(i));
        FaceLocations(1,:) = round(FaceLocations(1,:)/count);
        
        %             TopLeftX = FaceLocations(i,1);
        %             TopLeftY = FaceLocations(i,2);
        %             BottomRightX = FaceLocations(i,3);
        %             BottomRightY = FaceLocations(i,4);
        EyeY = round((FaceLocations(1,2) + FaceLocations(1,4))/2);
        EyeX = round((FaceLocations(1,1) + FaceLocations(1,3))/2);
        
        %             for j=TopLeftX:BottomRightX
        %                 ImgMatOutRight2(TopLeftY,j) = 255;
        %                 ImgMatOutRight2(BottomRightY,j) = 255;
        %             end
        %             for j=TopLeftY:BottomRightY
        %                 ImgMatOutRight2(j,TopLeftX) = 255;
        %                 ImgMatOutRight2(j,BottomRightX) = 255;
        %             end
        for i = -1 : 1
            for j = -1 : 1
                ImgMatOutRight2(EyeY+i,EyeX+j) = 255;
            end
        end
        ErrorRight = norm([(EyeY-EyeY_Orig) (EyeX-EyeX_Orig)])/Distance;
    else
        ErrorRight = 1;
    end
    
    if ErrorRight <= 0.125 && ErrorLeft <= 0.125
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