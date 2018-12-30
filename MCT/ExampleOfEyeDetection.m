clear all;
clc ;
close all;

WinY = 24;
WinX = 24;

FeatSelected = load('SelectedMCTFeat.dat');
GTSelected = load('SelectedMCTGT.dat');
[row,col] = size(FeatSelected);

nFeat = row;

FileNames = dir('Validation\Face24x24\*.bmp');
nPos = size(FileNames,1);

ImgPos = zeros(WinY,WinX,nPos);
ImgMCTPos = zeros(WinY-2,WinX-2,nPos);
for i=1:nPos
    FileName = FileNames(i,1).name;
    ImgPos(:,:,i) = imread(['Validation\Face24x24\' FileName],'bmp');
    ImgMCTPos(:,:,i) = MCTImg(ImgPos(:,:,i));
end

FileNames = dir('Validation\NonFace24x24\*.bmp');
nNeg = size(FileNames,1);

ImgNeg = zeros(WinY,WinX,nNeg);
ImgMCTNeg = zeros(WinY-2,WinX-2,nNeg);
for i=1:nNeg
    FileName = FileNames(i,1).name;
    ImgNeg(:,:,i) = imread(['Validation\NonFace24x24\' FileName],'bmp');
    ImgMCTNeg(:,:,i) = MCTImg(ImgNeg(:,:,i));
end

DetectionRate = zeros(100,1);
FalsePositiveRate = zeros(100,1);
WeightedFace = zeros(100,nPos);
WeightedNonFace = zeros(100,nNeg);

for i = 1 : 100
    for j = 1 : nPos
        for t = 1 : nFeat
            r = ImgMCTPos(FeatSelected(t,1),FeatSelected(t,2),j)+1;
            alpha = FeatSelected(t,3);
            if GTSelected(2*t,r) >= GTSelected(2*t-1,r)
                EstClass = 1;
            else
                EstClass = 0;
            end
            WeightedFace(i,j) = WeightedFace(i,j) + alpha * EstClass;
        end
        
        if WeightedFace(i,j) < 0.1 * i
            DetectionRate(i) = DetectionRate(i) + 1;
        end
    end
    DetectionRate(i) = DetectionRate(i) / nPos *100;
    
    for j = 1 : nNeg
        for t = 1 : nFeat
            r = ImgMCTNeg(FeatSelected(t,1),FeatSelected(t,2),j)+1;
            alpha = FeatSelected(t,3);
            if GTSelected(2*t,r) >= GTSelected(2*t-1,r)
                EstClass = 1;
            else
                EstClass = 0;
            end
            WeightedNonFace(i,j) = WeightedNonFace(i,j) + alpha * EstClass;
        end
        
        if WeightedNonFace(i,j) < 0.1 * i
            FalsePositiveRate(i) = FalsePositiveRate(i) + 1;
        end
    end
end

plot(FalsePositiveRate,DetectionRate)
% imwrite(ImgScanColor,['ResultsImage' num2str(1) '.bmp'],'bmp');